import SwiftUI

struct MyOrdersView: View {
    @EnvironmentObject private var auth: AuthService

    private let inkBlack = Color(hex: "1A1A1A")
    private let goldTan = Color(hex: "8B7355")
    private let sandBg = Color(hex: "FAFAF8")
    private let borderColor = Color(hex: "E8E8E4")
    private let warmCream = Color(hex: "F5F0E8")

    @State private var orders: [Order] = []
    @State private var isLoading = true

    var body: some View {
        ZStack {
            sandBg.ignoresSafeArea()

            if !auth.isLoggedIn {
                emptyState(title: "Sign In to View Orders", subtitle: "Your order history will appear here.")
            } else if isLoading {
                ProgressView().tint(inkBlack)
            } else if orders.isEmpty {
                emptyState(title: "No Orders Yet", subtitle: "When you place an order,\nit will appear here.")
            } else {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 12) {
                        ForEach(orders) { order in
                            NavigationLink { OrderDetailView(order: order) } label: {
                                orderRow(order: order)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    Color.clear.frame(height: 100)
                }
                .refreshable { await load() }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .tint(.black)
        .toolbar {
            ToolbarItem(placement: .principal) {
                AbyrNavLogo()
            }
        }
        .task { await load() }
    }

    private func load() async {
        guard auth.isLoggedIn else { isLoading = false; return }
        isLoading = true
        do {
            orders = try await OrderService.shared.fetchOrders()
        } catch {
            print("Orders fetch error:", error)
        }
        isLoading = false
    }

    private func emptyState(title: String, subtitle: String) -> some View {
        VStack(spacing: 20) {
            Image(systemName: "bag")
                .font(.system(size: 52)).foregroundColor(goldTan.opacity(0.3))
            Text(title).font(.custom("Georgia", size: 24)).italic().foregroundColor(inkBlack)
            Text(subtitle).font(.system(size: 12)).foregroundColor(.secondary)
                .multilineTextAlignment(.center).lineSpacing(4)
        }
    }

    private func orderRow(order: Order) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(order.orderNumber)
                        .font(.system(size: 12, weight: .medium)).foregroundColor(inkBlack)
                    Text(formatDate(order.createdAt))
                        .font(.system(size: 10)).foregroundColor(.secondary)
                }
                Spacer()
                statusBadge(status: order.status)
            }
            .padding(.horizontal, 16).padding(.top, 14)

            Rectangle().frame(height: 0.5).foregroundColor(borderColor).padding(.horizontal, 16).padding(.vertical, 10)

            HStack {
                Text("\(order.items.count) item\(order.items.count == 1 ? "" : "s")")
                    .font(.system(size: 11)).foregroundColor(.secondary)
                Spacer()
                Text("SAR \(order.total, specifier: "%.2f")")
                    .font(.custom("Georgia", size: 14)).italic().foregroundColor(goldTan)
            }
            .padding(.horizontal, 16).padding(.bottom, 14)
        }
        .background(Color.white)
        .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 2)
    }

    private func statusBadge(status: String) -> some View {
        let color: Color
        let bg: Color
        switch status {
        case "delivered": color = Color(hex: "1B5E20"); bg = Color(hex: "E8F5E9")
        case "shipped":   color = Color(hex: "E65100"); bg = Color(hex: "FFF3E0")
        case "cancelled": color = Color(hex: "C62828"); bg = Color(hex: "FFEBEE")
        default:          color = Color(hex: "8B7355"); bg = Color(hex: "F5F0E8")
        }
        return Text(status.uppercased())
            .font(.system(size: 8, weight: .medium)).tracking(0.5)
            .foregroundColor(color)
            .padding(.horizontal, 10).padding(.vertical, 4)
            .background(bg)
            .clipShape(Capsule())
    }

    private func formatDate(_ iso: String) -> String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        let date = formatter.date(from: iso) ?? ISO8601DateFormatter().date(from: iso)
        guard let d = date else { return "" }
        let out = DateFormatter()
        out.dateFormat = "MMM d, yyyy"
        return out.string(from: d)
    }
}
