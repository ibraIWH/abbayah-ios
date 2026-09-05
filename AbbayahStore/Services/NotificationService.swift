import Foundation
import UserNotifications

struct AppNotification: Identifiable, Codable, Equatable {
    let id: String
    let type: String
    let title: String
    let message: String
    let link: String?
    let read: Bool
    let createdAt: String?

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case type, title, message, link, read, createdAt
    }
}

private struct NotificationResponse: Decodable {
    let items: [AppNotification]
    let unread: Int
}

@MainActor
class NotificationService: ObservableObject {
    static let shared = NotificationService()

    @Published var items: [AppNotification] = []
    @Published var unread: Int = 0
    @Published var isLoading = false

    // Ids we've already shown a banner for — prevents re-bannering on every refresh
    private var seenIDs: Set<String> = []
    private var hasLoadedOnce = false
    private var pollTask: Task<Void, Never>?

    private let baseURL = "https://abbayah-backend.onrender.com/api/notifications"

    /// Ask iOS for permission to show banners. Safe to call repeatedly.
    func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
            print("🔔 Notification permission granted:", granted)
        }
    }

    /// Re-check the server every 30s so new notifications arrive on their own,
    /// banner included, without the user navigating anywhere.
    func startPolling() {
        guard pollTask == nil else { return }
        pollTask = Task { [weak self] in
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: 30_000_000_000) // 30s
                guard let self else { break }
                if AuthService.shared.isLoggedIn {
                    await self.fetch()
                }
            }
        }
    }

    func stopPolling() {
        pollTask?.cancel()
        pollTask = nil
    }

    /// Show a real iOS banner for a notification (works while app is open).
    private func showBanner(_ note: AppNotification) {
        let content = UNMutableNotificationContent()
        content.title = note.title
        content.body = note.message
        content.sound = .default

        let request = UNNotificationRequest(
            identifier: note.id,
            content: content,
            trigger: nil // fire immediately
        )
        UNUserNotificationCenter.current().add(request)
    }

    func fetch() async {
        guard let token = AuthService.shared.token, !token.isEmpty,
              let url = URL(string: baseURL) else { return }

        isLoading = true
        defer { isLoading = false }

        var req = URLRequest(url: url)
        req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        do {
            let (data, response) = try await URLSession.shared.data(for: req)
            let status = (response as? HTTPURLResponse)?.statusCode ?? -1
            if status == 401 { AuthService.shared.handleExpiredSession(); return }
            guard status == 200 else { return }

            let decoded = try JSONDecoder().decode(NotificationResponse.self, from: data)

            // On the very first load, just remember what exists — don't banner history.
            // After that, banner anything new + unread.
            if hasLoadedOnce {
                for note in decoded.items where !note.read && !seenIDs.contains(note.id) {
                    showBanner(note)
                }
            }
            for note in decoded.items { seenIDs.insert(note.id) }
            hasLoadedOnce = true

            self.items = decoded.items
            self.unread = decoded.unread
        } catch {
            print("❌ NOTIFICATIONS ERROR:", error)
        }
    }

    func markAllRead() async {
        guard let token = AuthService.shared.token, !token.isEmpty,
              let url = URL(string: "\(baseURL)/read-all") else { return }

        // Optimistic: clear the badge immediately
        unread = 0
        items = items.map {
            AppNotification(id: $0.id, type: $0.type, title: $0.title,
                            message: $0.message, link: $0.link, read: true, createdAt: $0.createdAt)
        }

        var req = URLRequest(url: url)
        req.httpMethod = "PUT"
        req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        _ = try? await URLSession.shared.data(for: req)
    }

    func clearLocal() {
        items = []
        unread = 0
        seenIDs = []
        hasLoadedOnce = false
        stopPolling()
    }
}
