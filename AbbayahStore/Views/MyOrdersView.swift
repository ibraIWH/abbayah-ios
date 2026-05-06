import SwiftUI

struct MyOrdersView: View {
    private let inkBlack = Color(hex: "1A1A1A")
    private let goldTan = Color(hex: "8B7355")
    private let sandBg = Color(hex: "FAFAF8")
    private let borderColor = Color(hex: "E8E8E4")
    private let warmCream = Color(hex: "F5F0E8")

    @State private var selectedFilter = "All"
    private let filters = ["All", "Ongoing", "Delivered"]

    // Placeholder orders — will come from backend after auth
    let orders = [
        OrderItem(id: "ABR-20260001", items: "2 items", total: "SAR 145.00", status: "Shipped", date: "Apr 10"),
        OrderItem(id: "ABR-20259998", items: "1 item", total: "SAR 55.50", status: "Delivered", date: "Mar 28"),
        OrderItem(id: "ABR-20259990", items: "3 items", total: "SAR 210.00", status: "Delivered", date: "Mar 10"),
    ]

    var body: some View {
        ZStack {
            sandBg.ignoresSafeArea()
            VStack(spacing: 0) {
                // Filter chips
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(filters, id: \.self) { filter in
                            Button { selectedFilter = filter } label: {
                                Text(filter.uppercased())
                                    .font(.system(size: 9, weight: .medium))
                                    .tracking(1)
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 7)
                                    .background(selectedFilter == filter ? inkBlack : Color.clear)
                                    .foregroundColor(selectedFilter == filter ? warmCream : Color.gray)
                                    .overlay(Rectangle().stroke(selectedFilter == filter ? inkBlack : borderColor, lineWidth: 0.5))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 20)
                }
                .padding(.vertical, 12)
                .background(Color.white)
                .overlay(Rectangle().frame(height: 0.5).foregroundColor(borderColor), alignment: .bottom)

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
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .tint(.black)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Image("AbyrLogoDark")
                    .resizable()
                    .renderingMode(.original)
                    .scaledToFit()
                    .frame(width: 160)
                    .scaleEffect(1.5)
            }
        }
    }

    private func orderRow(order: OrderItem) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(order.id)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(inkBlack)
                    Text(order.date)
                        .font(.system(size: 10))
                        .foregroundColor(.secondary)
                }
                Spacer()
                statusBadge(status: order.status)
            }
            .padding(.horizontal, 16)
            .padding(.top, 14)

            Rectangle().frame(height: 0.5).foregroundColor(borderColor).padding(.horizontal, 16).padding(.vertical, 10)

            HStack {
                Text(order.items)
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
                Spacer()
                Text(order.total)
                    .font(.custom("Georgia", size: 14))
                    .italic()
                    .foregroundColor(goldTan)
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 14)
        }
        .background(Color.white)
        .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 2)
    }

    private func statusBadge(status: String) -> some View {
        let color: Color = status == "Delivered" ? Color(hex: "1B5E20") : Color(hex: "E65100")
        let bg: Color = status == "Delivered" ? Color(hex: "E8F5E9") : Color(hex: "FFF3E0")
        return Text(status.uppercased())
            .font(.system(size: 8, weight: .medium))
            .tracking(0.5)
            .foregroundColor(color)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(bg)
            .clipShape(Capsule())
    }
}

// MARK: - Order Model (placeholder)
struct OrderItem: Identifiable {
    let id: String
    let items: String
    let total: String
    let status: String
    let date: String
}
