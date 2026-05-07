import SwiftUI

struct OrderDetailView: View {
    let order: OrderItem

    private let inkBlack = Color(hex: "1A1A1A")
    private let goldTan = Color(hex: "8B7355")
    private let sandBg = Color(hex: "FAFAF8")
    private let borderColor = Color(hex: "E8E8E4")
    private let warmCream = Color(hex: "F5F0E8")

    let steps = ["Order Placed", "Confirmed", "Shipped", "Delivered"]

    var body: some View {
        ZStack {
            sandBg.ignoresSafeArea()
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    // Order ID header
                    VStack(alignment: .leading, spacing: 4) {
                        Text("ORDER")
                            .font(.system(size: 9, weight: .medium))
                            .tracking(2)
                            .foregroundColor(goldTan)
                        Text(order.id)
                            .font(.custom("Georgia", size: 22))
                            .italic()
                            .foregroundColor(inkBlack)
                        Text(order.date)
                            .font(.system(size: 11))
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 20)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.white)

                    Rectangle().frame(height: 8).foregroundColor(sandBg)

                    // Timeline
                    VStack(alignment: .leading, spacing: 0) {
                        Text("DELIVERY STATUS")
                            .font(.system(size: 9, weight: .medium))
                            .tracking(2)
                            .foregroundColor(goldTan)
                            .padding(.horizontal, 20)
                            .padding(.top, 20)
                            .padding(.bottom, 16)

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(alignment: .top, spacing: 0) {
                                ForEach(Array(steps.enumerated()), id: \.offset) { i, step in
                                    HStack(spacing: 0) {
                                        VStack(spacing: 8) {
                                            // Circle + line row
                                            HStack(spacing: 0) {
                                                if i > 0 {
                                                    Rectangle()
                                                        .frame(height: 1)
                                                        .foregroundColor(i <= 2 ? inkBlack : borderColor)
                                                        .frame(width: 40)
                                                }
                                                ZStack {
                                                    Circle()
                                                        .fill(i < 3 ? inkBlack : Color(hex: "E8E8E4"))
                                                        .frame(width: 24, height: 24)
                                                    if i < 3 {
                                                        Image(systemName: "checkmark")
                                                            .font(.system(size: 9, weight: .bold))
                                                            .foregroundColor(.white)
                                                    }
                                                }
                                                if i < steps.count - 1 {
                                                    Rectangle()
                                                        .frame(height: 1)
                                                        .foregroundColor(i < 2 ? inkBlack : borderColor)
                                                        .frame(width: 40)
                                                }
                                            }

                                            // Label
                                            VStack(spacing: 2) {
                                                Text(step)
                                                    .font(.system(size: 10, weight: i < 3 ? .medium : .regular))
                                                    .foregroundColor(i < 3 ? inkBlack : Color.gray.opacity(0.4))
                                                    .multilineTextAlignment(.center)
                                                Text(i < 3 ? "Apr \(10 + i)" : "Est. Apr 14")
                                                    .font(.system(size: 9))
                                                    .foregroundColor(.secondary)
                                                    .multilineTextAlignment(.center)
                                            }
                                            .frame(width: 80)
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 16)
                        }
                    }
                    .background(Color.white)

                    Rectangle().frame(height: 8).foregroundColor(sandBg)

                    // ── ITEMS LIST ──────────────────────────
                    VStack(alignment: .leading, spacing: 0) {
                        Text("ITEMS")
                            .font(.system(size: 9, weight: .medium))
                            .tracking(2)
                            .foregroundColor(goldTan)
                            .padding(.horizontal, 20)
                            .padding(.top, 20)
                            .padding(.bottom, 12)

                        VStack(spacing: 0) {
                            ForEach([
                                ("Fleuri Breeze Abaya", "SAR 55.50", "EDE8E0"),
                                ("Snow Abaya", "SAR 34.50", "F5F5F3"),
                                ("Turkish Classic", "SAR 45.60", "E8E4DC"),
                            ], id: \.0) { name, price, bg in
                                HStack(spacing: 12) {
                                    // Item info
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(name)
                                            .font(.system(size: 12, weight: .medium))
                                            .foregroundColor(inkBlack)
                                        Text(price)
                                            .font(.custom("Georgia", size: 13))
                                            .italic()
                                            .foregroundColor(goldTan)
                                    }
                                    Spacer()
                                    // Small image placeholder
                                    ZStack {
                                        Color(hex: bg)
                                        Image(systemName: "photo")
                                            .font(.system(size: 10))
                                            .foregroundColor(Color(hex: "C4A882").opacity(0.4))
                                    }
                                    .frame(width: 52, height: 64)
                                }
                                .padding(.horizontal, 20)
                                .padding(.vertical, 12)
                                .overlay(
                                    Rectangle()
                                        .frame(height: 0.5)
                                        .foregroundColor(borderColor),
                                    alignment: .bottom
                                )
                            }
                        }
                        .background(Color.white)
                        .padding(.bottom, 8)
                    }
                    .background(Color.white)

                    Rectangle().frame(height: 8).foregroundColor(sandBg)

                    // Order summary

                    // Order summary
                    VStack(alignment: .leading, spacing: 0) {
                        Text("ORDER SUMMARY")
                            .font(.system(size: 9, weight: .medium))
                            .tracking(2)
                            .foregroundColor(goldTan)
                            .padding(.horizontal, 20)
                            .padding(.top, 20)
                            .padding(.bottom, 16)

                        VStack(spacing: 0) {
                            ForEach(["Subtotal", "Delivery", "Total"], id: \.self) { label in
                                HStack {
                                    Text(label)
                                        .font(.system(size: label == "Total" ? 13 : 11, weight: label == "Total" ? .medium : .regular))
                                        .foregroundColor(label == "Total" ? inkBlack : .secondary)
                                    Spacer()
                                    Text(label == "Delivery" ? "Free" : label == "Total" ? order.total : order.total)
                                        .font(label == "Total" ? .custom("Georgia", size: 15) : .system(size: 11))
                                        .italic(label == "Total")
                                        .foregroundColor(label == "Delivery" ? Color(hex: "1B5E20") : label == "Total" ? goldTan : .secondary)
                                }
                                .padding(.horizontal, 20)
                                .padding(.vertical, 12)
                                if label != "Total" {
                                    Rectangle().frame(height: 0.5).foregroundColor(borderColor).padding(.horizontal, 20)
                                }
                            }
                        }
                        .background(Color.white)
                        .padding(.bottom, 20)
                    }
                    .background(Color.white)

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
}
