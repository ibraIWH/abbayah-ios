import SwiftUI

struct CheckoutView: View {
    private let brandRed = Color(hex: "5C0A14")
    private let inkBlack = Color(hex: "1A1A1A")
    private let warmCream = Color(hex: "F5F0E8")
    private let goldTan = Color(hex: "8B7355")
    private let sandBg = Color(hex: "FAFAF8")
    private let borderColor = Color(hex: "E8E8E4")
    private let gold = Color(hex: "C4A882")

    @State private var showConfirmed = false

    var body: some View {
        ZStack(alignment: .bottom) {
            sandBg.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {

                    // Steps
                    HStack {
                        ForEach(["Address","Payment","Confirm"].indices, id: \.self) { i in
                            HStack {
                                VStack(spacing: 4) {
                                    ZStack {
                                        Circle()
                                            .fill(i == 0 ? brandRed : i == 1 ? gold : Color(hex: "E8E8E4"))
                                            .frame(width: 24, height: 24)
                                        Text("\(i + 1)")
                                            .font(.system(size: 9, weight: .medium))
                                            .foregroundColor(i < 2 ? warmCream : Color.gray)
                                    }
                                    Text(["Address","Payment","Confirm"][i].uppercased())
                                        .font(.system(size: 7, weight: .medium))
                                        .foregroundColor(i == 0 ? brandRed : Color.gray)
                                        .tracking(0.5)
                                }
                                if i < 2 {
                                    Rectangle()
                                        .frame(height: 0.5)
                                        .foregroundColor(i == 0 ? brandRed : borderColor)
                                        .padding(.bottom, 14)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 16)
                    .background(Color.white)
                    .overlay(Rectangle().frame(height: 0.5).foregroundColor(borderColor), alignment: .bottom)

                    // Address section
                    VStack(alignment: .leading, spacing: 0) {
                        Text("DELIVERY ADDRESS")
                            .font(.system(size: 9, weight: .medium))
                            .tracking(2)
                            .foregroundColor(goldTan)
                            .padding(.horizontal, 20)
                            .padding(.top, 20)
                            .padding(.bottom, 12)

                        // Default address card
                        VStack(alignment: .leading, spacing: 0) {
                            HStack {
                                Text("Home")
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(inkBlack)
                                Text("DEFAULT")
                                    .font(.system(size: 7, weight: .medium))
                                    .tracking(1)
                                    .foregroundColor(warmCream)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 3)
                                    .background(brandRed)
                                Spacer()
                                Text("CHANGE")
                                    .font(.system(size: 9, weight: .medium))
                                    .tracking(1)
                                    .foregroundColor(brandRed)
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 14)

                            Rectangle().frame(height: 0.5).foregroundColor(borderColor).padding(.horizontal, 20)

                            Text("Ibrahim Al-Wahidi\n12 King Fahd Rd, Riyadh\nSaudi Arabia 11564")
                                .font(.system(size: 11))
                                .foregroundColor(.secondary)
                                .lineSpacing(4)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 12)
                        }
                        .background(Color.white)
                        .padding(.horizontal, 20)

                        Button {} label: {
                            Text("+ Add new address")
                                .font(.system(size: 11))
                                .foregroundColor(brandRed)
                        }
                        .buttonStyle(.plain)
                        .padding(.horizontal, 20)
                        .padding(.top, 12)
                        .padding(.bottom, 24)
                    }

                    Rectangle().frame(height: 8).foregroundColor(sandBg)

                    // Order summary
                    VStack(alignment: .leading, spacing: 0) {
                        Text("ORDER SUMMARY")
                            .font(.system(size: 9, weight: .medium))
                            .tracking(2)
                            .foregroundColor(goldTan)
                            .padding(.horizontal, 20)
                            .padding(.top, 20)
                            .padding(.bottom, 12)

                        VStack(spacing: 0) {
                            ForEach([("Fleuri Breeze Abaya", "SAR 55.50"), ("Snow Abaya", "SAR 34.50")], id: \.0) { item in
                                HStack {
                                    Text(item.0)
                                        .font(.system(size: 11))
                                        .foregroundColor(.secondary)
                                    Spacer()
                                    Text(item.1)
                                        .font(.system(size: 11))
                                        .foregroundColor(inkBlack)
                                }
                                .padding(.horizontal, 20)
                                .padding(.vertical, 8)
                            }

                            Rectangle().frame(height: 0.5).foregroundColor(borderColor).padding(.horizontal, 20)

                            HStack {
                                Text("Delivery")
                                    .font(.system(size: 11))
                                    .foregroundColor(.secondary)
                                Spacer()
                                Text("Free")
                                    .font(.system(size: 11))
                                    .foregroundColor(Color(hex: "1B5E20"))
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 8)

                            Rectangle().frame(height: 0.5).foregroundColor(borderColor).padding(.horizontal, 20)

                            HStack {
                                Text("Total")
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundColor(inkBlack)
                                Spacer()
                                Text("SAR 90.00")
                                    .font(.custom("Georgia", size: 16))
                                    .italic()
                                    .foregroundColor(goldTan)
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 12)
                        }
                        .background(Color.white)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 24)
                    }

                    Color.clear.frame(height: 100)
                }
            }

            // Sticky CTA
            VStack(spacing: 0) {
                Rectangle().frame(height: 0.5).foregroundColor(borderColor)
                Button {
                    showConfirmed = true
                } label: {
                    Text("PLACE ORDER")
                        .font(.system(size: 11, weight: .medium))
                        .tracking(3)
                        .foregroundColor(warmCream)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(brandRed)
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .padding(.bottom, 24)
                .background(Color(UIColor.systemBackground).ignoresSafeArea(edges: .bottom))
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .tint(.black)
        .toolbar {
            ToolbarItem(placement: .principal) {
                AbyrNavLogo()
            }
        }
        .navigationDestination(isPresented: $showConfirmed) {
            OrderConfirmedView()
        }
    }
}
