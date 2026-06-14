import SwiftUI

struct CartView: View {
    @EnvironmentObject private var cart: CartStore
    @EnvironmentObject private var auth: AuthService

    private let inkBlack = Color(hex: "1A1A1A")
    private let goldTan = Color(hex: "8B7355")
    private let sandBg = Color(hex: "FAFAF8")
    private let borderColor = Color(hex: "E8E8E4")
    private let warmCream = Color(hex: "F5F0E8")
    private let brandRed = Color(hex: "5C0A14")

    @State private var showCheckout = false
    @State private var showSignIn = false

    var body: some View {
        ZStack(alignment: .bottom) {
            sandBg.ignoresSafeArea()

            if cart.isEmpty {
                VStack(spacing: 20) {
                    Spacer()
                    Image(systemName: "bag")
                        .font(.system(size: 52))
                        .foregroundColor(goldTan.opacity(0.3))
                    Text("Your Cart is Empty")
                        .font(.custom("Georgia", size: 24))
                        .italic()
                        .foregroundColor(inkBlack)
                    Text("Add products to get started.")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                    Spacer()
                }
            } else {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        VStack(spacing: 0) {
                            ForEach(cart.items) { item in
                                cartRow(item: item)
                                Rectangle().frame(height: 0.5).foregroundColor(borderColor).padding(.horizontal, 20)
                            }
                        }
                        .background(Color.white)
                        .padding(.top, 16)

                        VStack(spacing: 0) {
                            Text("SAR \(String(format: "%.2f", cart.totalPrice >= 200 ? cart.totalPrice : cart.totalPrice + 25))")
                            Rectangle().frame(height: 0.5).foregroundColor(borderColor).padding(.horizontal, 20)
                            summaryRow(label: "Delivery", value: cart.totalPrice >= 200 ? "Free" : "SAR 25.00", valueColor: cart.totalPrice >= 200 ? Color(hex: "1B5E20") : inkBlack)
                            Rectangle().frame(height: 0.5).foregroundColor(borderColor).padding(.horizontal, 20)
                            HStack {
                                Text("Total")
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundColor(inkBlack)
                                Spacer()
                                Text("SAR \(cart.totalPrice >= 200 ? cart.totalPrice : cart.totalPrice + 25, specifier: "%.2f")")
                                    .font(.custom("Georgia", size: 18))
                                    .italic()
                                    .foregroundColor(goldTan)
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 14)
                        }
                        .background(Color.white)
                        .padding(.top, 8)

                        Color.clear.frame(height: 120)
                    }
                }

                VStack(spacing: 0) {
                    Rectangle().frame(height: 0.5).foregroundColor(borderColor)
                    Button {
                                            if auth.isLoggedIn {
                                                showCheckout = true
                                            } else {
                                                showSignIn = true
                                            }
                                        } label: {
                            Text(auth.isLoggedIn ? "PROCEED TO CHECKOUT" : "SIGN IN TO CHECKOUT")
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
                            .padding(.bottom, 90)
                            .background(Color(UIColor.systemBackground).ignoresSafeArea(edges: .bottom))
                    }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Image("AbyrLogoDark")
                    .resizable().renderingMode(.original).scaledToFit()
                    .frame(width: 160).scaleEffect(1.5)
            }
        }
        .navigationDestination(isPresented: $showCheckout) {
            CheckoutView()
        }
        .navigationDestination(isPresented: $showSignIn) {
                    SignInView()
        }
    }

    private func cartRow(item: CartItem) -> some View {
        HStack(spacing: 12) {
            AsyncImage(url: URL(string: item.product.imageUrl)) { phase in
                if case .success(let image) = phase {
                    image.resizable().scaledToFill()
                } else {
                    Color(hex: "EDE8E0")
                }
            }
            .frame(width: 76, height: 96)
            .clipped()

            VStack(alignment: .leading, spacing: 4) {
                Text(item.product.name)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(inkBlack)
                    .lineLimit(1)
                Text("Size \(item.selectedSize)")
                    .font(.system(size: 10))
                    .foregroundColor(.secondary)
                Text("SAR \(item.product.displayPrice, specifier: "%.2f")")
                    .font(.custom("Georgia", size: 14))
                    .italic()
                    .foregroundColor(goldTan)
                    .padding(.top, 4)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 12) {
                Button {
                    cart.remove(item: item)
                } label: {
                    Text("×").font(.system(size: 18)).foregroundColor(Color.gray.opacity(0.4))
                }
                .buttonStyle(.plain)

                HStack(spacing: 0) {
                    Button { cart.updateQuantity(item: item, delta: -1) } label: {
                        Text("−").font(.system(size: 16)).frame(width: 30, height: 30).foregroundColor(inkBlack)
                    }.buttonStyle(.plain)
                    Text("\(item.quantity)")
                        .font(.system(size: 11)).frame(width: 30, height: 30).foregroundColor(inkBlack)
                        .overlay(Rectangle().stroke(borderColor, lineWidth: 0.5))
                    Button { cart.updateQuantity(item: item, delta: 1) } label: {
                        Text("+").font(.system(size: 16)).frame(width: 30, height: 30).foregroundColor(inkBlack)
                    }.buttonStyle(.plain)
                }
                .overlay(Rectangle().stroke(borderColor, lineWidth: 0.5))
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
    }

    private func summaryRow(label: String, value: String, valueColor: Color? = nil) -> some View {
        HStack {
            Text(label).font(.system(size: 11)).foregroundColor(.secondary)
            Spacer()
            Text(value).font(.system(size: 11)).foregroundColor(valueColor ?? inkBlack)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
    }
}
