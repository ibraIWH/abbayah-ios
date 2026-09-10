import SwiftUI

struct OrderDetailView: View {
    let order: Order

    private let inkBlack = Color(hex: "1A1A1A")
    private let goldTan = Color(hex: "8B7355")
    private let sandBg = Color(hex: "FAFAF8")
    private let borderColor = Color(hex: "E8E8E4")
    private let warmCream = Color(hex: "F5F0E8")

    private let steps = ["placed", "confirmed", "shipped", "delivered"]

    private var currentStep: Int {
        steps.firstIndex(of: order.status) ?? 0
    }

    private var orderDateText: String {
        let iso = ISO8601DateFormatter()
        iso.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        let date = iso.date(from: order.createdAt) ?? ISO8601DateFormatter().date(from: order.createdAt)
        guard let date else { return "" }
        let out = DateFormatter()
        out.dateFormat = "MMM d, yyyy"
        return out.string(from: date)
    }

    var body: some View {
        ZStack {
            sandBg.ignoresSafeArea()
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {

                    // Header
                    VStack(alignment: .leading, spacing: 4) {
                        Text("ORDER")
                            .font(.system(size: 9, weight: .medium)).tracking(2).foregroundColor(goldTan)
                        Text(order.orderNumber)
                            .font(.custom("Georgia", size: 22)).italic().foregroundColor(inkBlack)
                    }
                    .padding(.horizontal, 20).padding(.vertical, 20)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.white)

                    Rectangle().frame(height: 8).foregroundColor(sandBg)

                    // Horizontal timeline (line with dots)
                    VStack(alignment: .leading, spacing: 0) {
                        Text("DELIVERY STATUS")
                            .font(.system(size: 9, weight: .medium)).tracking(2).foregroundColor(goldTan)
                            .padding(.horizontal, 20).padding(.top, 20).padding(.bottom, 20)

                        // Dots evenly spaced across a full-width line
                        ZStack(alignment: .center) {
                            // The connecting line, behind the dots
                            Rectangle()
                                .fill(inkBlack)
                                .frame(height: 1.5)
                                .padding(.horizontal, 34)

                            HStack(spacing: 0) {
                                ForEach(Array(steps.enumerated()), id: \.offset) { i, step in
                                    ZStack {
                                        Circle()
                                            .fill(sandBg)
                                            .frame(width: 26, height: 26)
                                        if i == currentStep {
                                            // Current step — solid filled dot
                                            Circle()
                                                .fill(inkBlack)
                                                .frame(width: 22, height: 22)
                                        } else {
                                            // Other steps — hollow ring
                                            Circle()
                                                .stroke(i < currentStep ? inkBlack : Color.gray.opacity(0.4), lineWidth: 1.5)
                                                .frame(width: 22, height: 22)
                                            if i < currentStep {
                                                Circle().fill(inkBlack).frame(width: 8, height: 8)
                                            }
                                        }
                                    }
                                    .frame(maxWidth: .infinity)
                                }
                            }
                        }
                        .padding(.horizontal, 20)

                        // Labels under each dot
                        HStack(spacing: 0) {
                            ForEach(Array(steps.enumerated()), id: \.offset) { i, step in
                                Text(step.capitalized)
                                    .font(.system(size: 12, weight: i == currentStep ? .semibold : .regular))
                                    .foregroundColor(i <= currentStep ? inkBlack : Color.gray.opacity(0.45))
                                    .frame(maxWidth: .infinity)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 12)

                        // Date + CURRENT badge under the active step
                        HStack(spacing: 0) {
                            ForEach(Array(steps.enumerated()), id: \.offset) { i, step in
                                VStack(spacing: 6) {
                                    if i == currentStep {
                                        Text(orderDateText)
                                            .font(.system(size: 11))
                                            .foregroundColor(goldTan)
                                        Text("CURRENT")
                                            .font(.system(size: 8, weight: .semibold)).tracking(1)
                                            .foregroundColor(inkBlack)
                                            .padding(.horizontal, 10).padding(.vertical, 4)
                                            .background(Capsule().fill(goldTan.opacity(0.25)))
                                    }
                                }
                                .frame(maxWidth: .infinity)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 10)
                        .padding(.bottom, 20)
                    }
                    .background(Color.white)

                    Rectangle().frame(height: 8).foregroundColor(sandBg)

                    // Items list
                    VStack(alignment: .leading, spacing: 0) {
                        Text("ITEMS")
                            .font(.system(size: 9, weight: .medium)).tracking(2).foregroundColor(goldTan)
                            .padding(.horizontal, 20).padding(.top, 20).padding(.bottom, 12)

                        ForEach(Array(order.items.enumerated()), id: \.offset) { _, item in
                            HStack(spacing: 12) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(item.name)
                                        .font(.system(size: 12, weight: .medium)).foregroundColor(inkBlack)
                                    Text("Size \(item.size) · Qty \(item.quantity)")
                                        .font(.system(size: 10)).foregroundColor(.secondary)
                                    Text("SAR \(item.price, specifier: "%.2f")")
                                        .font(.custom("Georgia", size: 13)).italic().foregroundColor(goldTan)
                                }
                                Spacer()
                                AsyncImage(url: URL(string: item.imageUrl)) { phase in
                                    if case .success(let image) = phase {
                                        image.resizable().scaledToFill()
                                    } else {
                                        Color(hex: "EDE8E0")
                                    }
                                }
                                .frame(width: 52, height: 64)
                                .clipped()
                            }
                            .padding(.horizontal, 20).padding(.vertical, 12)
                            .overlay(Rectangle().frame(height: 0.5).foregroundColor(borderColor), alignment: .bottom)
                        }
                    }
                    .background(Color.white)

                    Rectangle().frame(height: 8).foregroundColor(sandBg)

                    // Summary
                    VStack(alignment: .leading, spacing: 0) {
                        Text("SUMMARY")
                            .font(.system(size: 9, weight: .medium)).tracking(2).foregroundColor(goldTan)
                            .padding(.horizontal, 20).padding(.top, 20).padding(.bottom, 12)

                        summaryRow("Subtotal", "SAR \(String(format: "%.2f", order.subtotal))")
                        summaryRow("Delivery", order.deliveryFee == 0 ? "Free" : "SAR \(String(format: "%.2f", order.deliveryFee))",
                                   valueColor: order.deliveryFee == 0 ? Color(hex: "1B5E20") : inkBlack)
                        Rectangle().frame(height: 0.5).foregroundColor(borderColor).padding(.horizontal, 20)
                        HStack {
                            Text("Total").font(.system(size: 13, weight: .medium)).foregroundColor(inkBlack)
                            Spacer()
                            Text("SAR \(order.total, specifier: "%.2f")")
                                .font(.custom("Georgia", size: 16)).italic().foregroundColor(goldTan)
                        }
                        .padding(.horizontal, 20).padding(.vertical, 12)
                    }
                    .background(Color.white)
                    .padding(.bottom, 20)

                    // Shipping address
                    VStack(alignment: .leading, spacing: 0) {
                        Text("SHIPPING TO")
                            .font(.system(size: 9, weight: .medium)).tracking(2).foregroundColor(goldTan)
                            .padding(.horizontal, 20).padding(.top, 20).padding(.bottom, 12)
                        VStack(alignment: .leading, spacing: 4) {
                            Text(order.shippingAddress.name).font(.system(size: 12, weight: .medium)).foregroundColor(inkBlack)
                            Text("\(order.shippingAddress.line1), \(order.shippingAddress.city)")
                                .font(.system(size: 11)).foregroundColor(.secondary)
                            if !order.shippingAddress.phone.isEmpty {
                                Text(order.shippingAddress.phone).font(.system(size: 11)).foregroundColor(.secondary)
                            }
                        }
                        .padding(.horizontal, 20).padding(.bottom, 20)
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
                AbyrNavLogo()
            }
        }
    }

    private func summaryRow(_ label: String, _ value: String, valueColor: Color? = nil) -> some View {
        HStack {
            Text(label).font(.system(size: 11)).foregroundColor(.secondary)
            Spacer()
            Text(value).font(.system(size: 11)).foregroundColor(valueColor ?? inkBlack)
        }
        .padding(.horizontal, 20).padding(.vertical, 10)
    }
}
