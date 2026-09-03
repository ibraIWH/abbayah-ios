import Foundation

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

    private let baseURL = "https://abbayah-backend.onrender.com/api/notifications"

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
    }
}
