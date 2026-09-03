import SwiftUI

struct NotificationsView: View {
    @StateObject private var service = NotificationService.shared

    private let inkBlack = Color(hex: "1A1A1A")
    private let goldTan = Color(hex: "8B7355")
    private let brandRed = Color(hex: "5C0A14")
    private let sandBg = Color(hex: "FAFAF8")
    private let borderColor = Color(hex: "E8E8E4")

    var body: some View {
        ZStack {
            sandBg.ignoresSafeArea()

            if service.isLoading && service.items.isEmpty {
                ProgressView().tint(inkBlack)
            } else if service.items.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "bell")
                        .font(.system(size: 44)).foregroundColor(goldTan.opacity(0.35))
                    Text("No Notifications")
                        .font(.custom("Georgia", size: 20)).italic().foregroundColor(inkBlack)
                    Text("Order updates and offers will appear here.")
                        .font(.system(size: 11)).foregroundColor(.secondary)
                }
            } else {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        ForEach(service.items) { note in
                            notificationRow(note)
                            Rectangle().frame(height: 0.5).foregroundColor(borderColor)
                        }
                    }
                    .padding(.top, 8)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("NOTIFICATIONS")
                    .font(.system(size: 11, weight: .medium)).tracking(2).foregroundColor(inkBlack)
            }
            if service.unread > 0 {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Mark all read") {
                        Task { await service.markAllRead() }
                    }
                    .font(.system(size: 11)).foregroundColor(goldTan)
                }
            }
        }
        .task { await service.fetch() }
        .refreshable { await service.fetch() }
    }

    private func notificationRow(_ note: AppNotification) -> some View {
        HStack(alignment: .top, spacing: 12) {
            // Unread dot
            Circle()
                .fill(note.read ? Color.clear : brandRed)
                .frame(width: 7, height: 7)
                .padding(.top, 5)

            // Type icon
            Image(systemName: note.type == "order" ? "bag" : "tag")
                .font(.system(size: 15))
                .foregroundColor(goldTan)
                .frame(width: 22)
                .padding(.top, 1)

            VStack(alignment: .leading, spacing: 4) {
                Text(note.title)
                    .font(.system(size: 13, weight: note.read ? .regular : .semibold))
                    .foregroundColor(inkBlack)
                Text(note.message)
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
                    .lineSpacing(3)
                if let when = relativeTime(note.createdAt) {
                    Text(when)
                        .font(.system(size: 10))
                        .foregroundColor(goldTan.opacity(0.7))
                        .padding(.top, 2)
                }
            }
            Spacer()
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 14)
        .background(note.read ? Color.clear : Color.white)
    }

    private func relativeTime(_ iso: String?) -> String? {
        guard let iso = iso else { return nil }
        let fmt = ISO8601DateFormatter()
        fmt.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        let date = fmt.date(from: iso) ?? ISO8601DateFormatter().date(from: iso)
        guard let date = date else { return nil }
        let rel = RelativeDateTimeFormatter()
        rel.unitsStyle = .short
        return rel.localizedString(for: date, relativeTo: Date())
    }
}
