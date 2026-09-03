import SwiftUI

struct CartView: View {
    @EnvironmentObject private var cart: CartStore
    @EnvironmentObject private var auth: AuthService

    @StateObject private var suggestionService = ProductService()

    private let inkBlack = Color(hex: "1A1A1A")
    private let goldTan = Color(hex: "8B7355")
    private let gold = Color(hex: "C4A882")
    private let sandBg = Color(hex: "FAFAF8")
    private let borderColor = Color(hex: "E8E8E4")
    private let warmCream = Color(hex: "F5F0E8")
    private let brandRed = Color(hex: "5C0A14")

    @State private var showCheckout = false
    @State private var showSignIn = false

    private let freeThreshold: Double = 200

    // Suggestions = products not already in the cart, max 6
    private var suggestions: [Product] {
        let cartIds = Set(cart.items.map { $0.product.id })
        return suggestionService.products.filter { !cartIds.contains($0.id) }.prefix(6).map { $0 }
    }

    private var deliveryFee: Double { cart.totalPrice >= freeThreshold ? 0 : 25 }
    private var grandTotal: Double { cart.totalPrice + deliveryFee }
    private var remainingForFree: Double { max(0, freeThreshold - cart.totalPrice) }

    var body: some View {
        ZStack(alignment: .bottom) {
            sandBg.ignoresSafeArea()

            if cart.isEmpty {
                emptyCart
            } else {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {

                        // Free delivery progress
                        if remainingForFree > 0 {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Add SAR \(remainingForFree, specifier: "%.2f") more for ")
                                    .font(.system(size: 10)).foregroundColor(inkBlack)
                                + Text("free delivery")
                                    .font(.system(size: 10, weight: .semibold)).foregroundColor(brandRed)
                                GeometryReader { geo in
                                    ZStack(alignment: .leading) {
                                        Rectangle().fill(borderColor).frame(height: 4)
                                        Rectangle().fill(gold)
                                            .frame(width: geo.size.width * min(1, cart.totalPrice / freeThreshold), height: 4)
                                    }
                                }
                                .frame(height: 4)
                            }
                            .padding(.horizontal, 14).padding(.vertical, 12)
                            .background(Color.white)
                            .overlay(Rectangle().stroke(borderColor, lineWidth: 0.5))
                            .padding(.horizontal, 18).padding(.top, 14)
                        } else {
                            HStack(spacing: 6) {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 12)).foregroundColor(Color(hex: "1B5E20"))
                                Text("You've unlocked free delivery")
                                    .font(.system(size: 10, weight: .medium)).foregroundColor(Color(hex: "1B5E20"))
                                Spacer()
                            }
                            .padding(.horizontal, 14).padding(.vertical, 12)
                            .background(Color.white)
                            .overlay(Rectangle().stroke(borderColor, lineWidth: 0.5))
                            .padding(.horizontal, 18).padding(.top, 14)
                        }

                        // Cart items
                        VStack(spacing: 0) {
                            ForEach(cart.items) { item in
                                cartRow(item: item)
                                Rectangle().frame(height: 0.5).foregroundColor(borderColor).padding(.horizontal, 20)
                            }
                        }
                        .background(Color.white)
                        .padding(.top, 14)

                        // ── YOU MAY ALSO LIKE ──────────────
                        if !suggestions.isEmpty {
                            VStack(alignment: .leading, spacing: 0) {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("ADD TO YOUR ORDER")
                                        .font(.system(size: 9, weight: .medium)).tracking(2).foregroundColor(goldTan)
                                    Text("You May Also Like")
                                        .font(.custom("Georgia", size: 20)).italic().foregroundColor(inkBlack)
                                }
                                .padding(.horizontal, 18).padding(.top, 24).padding(.bottom, 14)

                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 12) {
                                        ForEach(suggestions) { item in
                                            NavigationLink {
                                                ProductDetailView(product: item)
                                            } label: {
                                                HniProductCard(product: item)
                                                    .frame(width: 160)
                                            }
                                            .buttonStyle(.plain)
                                        }
                                    }
                                    .padding(.horizontal, 18)
                                }
                            }
                        }

                        // Summary
                        VStack(spacing: 0) {
                            summaryRow(label: "Subtotal", value: "SAR \(String(format: "%.2f", cart.totalPrice))")
                            Rectangle().frame(height: 0.5).foregroundColor(borderColor).padding(.horizontal, 20)
                            summaryRow(label: "Delivery",
                                       value: deliveryFee == 0 ? "Free" : "SAR 25.00",
                                       valueColor: deliveryFee == 0 ? Color(hex: "1B5E20") : inkBlack)
                            Rectangle().frame(height: 0.5).foregroundColor(borderColor).padding(.horizontal, 20)
                            HStack {
                                Text("Total")
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundColor(inkBlack)
                                Spacer()
                                Text("SAR \(grandTotal, specifier: "%.2f")")
                                    .font(.custom("Georgia", size: 18))
                                    .italic()
                                    .foregroundColor(goldTan)
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 14)
                        }
                        .background(Color.white)
                        .padding(.top, 20)

                        Color.clear.frame(height: 120)
                    }
                }

                // Sticky checkout
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
                AbyrNavLogo()
            }
        }
        .navigationDestination(isPresented: $showCheckout) {
            CheckoutView()
        }
        .navigationDestination(isPresented: $showSignIn) {
            SignInView()
        }
        .task {
            await suggestionService.fetchProducts(category: "All", search: "")
        }
    }

    // MARK: - Empty cart (with suggestions so it's never a dead end)
    private var emptyCart: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                VStack(spacing: 16) {
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
                }
                .padding(.top, 80)
                .padding(.bottom, 34)

                if !suggestions.isEmpty {
                    VStack(alignment: .leading, spacing: 0) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("START HERE")
                                .font(.system(size: 9, weight: .medium)).tracking(2).foregroundColor(goldTan)
                            Text("You May Also Like")
                                .font(.custom("Georgia", size: 20)).italic().foregroundColor(inkBlack)
                        }
                        .padding(.horizontal, 18).padding(.bottom, 14)

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(suggestions) { item in
                                    NavigationLink {
                                        ProductDetailView(product: item)
                                    } label: {
                                        HniProductCard(product: item)
                                            .frame(width: 160)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(.horizontal, 18)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }

                Color.clear.frame(height: 120)
            }
        }
    }

    // MARK: - Cart row
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

    // MARK: - Summary row
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
