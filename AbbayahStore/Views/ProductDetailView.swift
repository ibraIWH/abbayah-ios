import SwiftUI

struct ProductDetailView: View {
    let product: Product

    @EnvironmentObject private var cart: CartStore
    @EnvironmentObject private var favourites: FavouritesService
    @EnvironmentObject private var auth: AuthService

    @StateObject private var suggestionService = ProductService()

    @State private var selectedSize: String = "M"
    @State private var addedToCart: Bool = false

    private let sizes = ["XS", "S", "M", "L", "XL"]
    private let inkBlack = Color(hex: "1A1A1A")
    private let warmCream = Color(hex: "F5F0E8")
    private let goldTan = Color(hex: "8B7355")
    private let sandBg = Color(hex: "FAFAF8")
    private let borderColor = Color(hex: "E8E8E4")
    private let brandRed = Color(hex: "5C0A14")

    var isFavourite: Bool { favourites.isFavourite(product.id) }

    // Suggestions = other products, excluding this one, max 6
    private var suggestions: [Product] {
        suggestionService.products.filter { $0.id != product.id }.prefix(6).map { $0 }
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            sandBg.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    // Hero image
                    ZStack(alignment: .topTrailing) {
                        AsyncImage(url: URL(string: product.imageUrl)) { phase in
                            switch phase {
                            case .success(let image):
                                image.resizable().scaledToFill()
                            case .empty:
                                ZStack { Color(hex: "EDE8E0"); ProgressView().tint(goldTan) }
                            default:
                                ZStack {
                                    Color(hex: "EDE8E0")
                                    Image(systemName: "photo").font(.system(size: 40)).foregroundColor(goldTan.opacity(0.4))
                                }
                            }
                        }
                        .frame(maxWidth: .infinity).frame(height: 420).clipped()

                        if product.isOnSale {
                            Text("SALE")
                                .font(.system(size: 8, weight: .medium)).tracking(1)
                                .foregroundColor(warmCream)
                                .padding(.horizontal, 10).padding(.vertical, 4)
                                .background(brandRed).padding(16)
                        }
                    }

                    VStack(alignment: .leading, spacing: 0) {
                        // Category + name + price
                        HStack(alignment: .top) {
                            VStack(alignment: .leading, spacing: 6) {
                                Text(product.category.uppercased())
                                    .font(.system(size: 9, weight: .medium)).tracking(2).foregroundColor(goldTan)
                                Text(product.name)
                                    .font(.custom("Georgia", size: 24)).italic().foregroundColor(inkBlack).lineLimit(2)
                            }
                            Spacer()
                            VStack(alignment: .trailing, spacing: 4) {
                                Text("SAR \(product.displayPrice, specifier: "%.2f")")
                                    .font(.custom("Georgia", size: 22)).italic().foregroundColor(goldTan)
                                if product.isOnSale {
                                    Text("SAR \(product.price, specifier: "%.2f")")
                                        .font(.system(size: 11)).strikethrough().foregroundColor(.secondary)
                                }
                            }
                        }
                        .padding(.horizontal, 20).padding(.top, 20).padding(.bottom, 16)

                        Rectangle().frame(height: 0.5).foregroundColor(borderColor).padding(.horizontal, 20)

                        // Size selector
                        VStack(alignment: .leading, spacing: 12) {
                            Text("SIZE")
                                .font(.system(size: 9, weight: .medium)).tracking(2).foregroundColor(.secondary)
                            HStack(spacing: 8) {
                                ForEach(sizes, id: \.self) { size in
                                    Button {
                                        selectedSize = size
                                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                    } label: {
                                        Text(size)
                                            .font(.system(size: 11, weight: .medium))
                                            .frame(width: 44, height: 44)
                                            .background(selectedSize == size ? inkBlack : Color.clear)
                                            .foregroundColor(selectedSize == size ? warmCream : inkBlack)
                                            .overlay(Rectangle().stroke(selectedSize == size ? inkBlack : borderColor, lineWidth: 0.5))
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                        .padding(.horizontal, 20).padding(.vertical, 16)

                        Rectangle().frame(height: 0.5).foregroundColor(borderColor).padding(.horizontal, 20)

                        // Description
                        VStack(alignment: .leading, spacing: 8) {
                            Text("DESCRIPTION")
                                .font(.system(size: 9, weight: .medium)).tracking(2).foregroundColor(.secondary)
                            Text(product.description ?? "A beautifully crafted piece from the Abyr Line collection.")
                                .font(.system(size: 13)).foregroundColor(Color.gray.opacity(0.8)).lineSpacing(6)
                        }
                        .padding(.horizontal, 20).padding(.vertical, 16)

                        // ── COMPLETE THE LOOK ──────────────
                        if !suggestions.isEmpty {
                            Rectangle().frame(height: 0.5).foregroundColor(borderColor).padding(.horizontal, 20)

                            VStack(alignment: .leading, spacing: 0) {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("STYLE IT WITH")
                                        .font(.system(size: 9, weight: .medium)).tracking(2).foregroundColor(goldTan)
                                    Text("Complete the Look")
                                        .font(.custom("Georgia", size: 20)).italic().foregroundColor(inkBlack)
                                }
                                .padding(.horizontal, 20).padding(.top, 20).padding(.bottom, 14)

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
                                    .padding(.horizontal, 20)
                                }
                            }
                        }

                        Color.clear.frame(height: 100)
                    }
                }
            }

            // Sticky CTA
            VStack(spacing: 0) {
                Rectangle().frame(height: 0.5).foregroundColor(borderColor)
                HStack(spacing: 12) {
                    Button {
                        Task {
                            if auth.isLoggedIn { await favourites.toggle(product: product) }
                        }
                    } label: {
                        Image(systemName: isFavourite ? "heart.fill" : "heart")
                            .font(.system(size: 18))
                            .foregroundColor(isFavourite ? brandRed : inkBlack)
                            .frame(width: 52, height: 52)
                            .overlay(Rectangle().stroke(borderColor, lineWidth: 0.5))
                    }
                    .buttonStyle(.plain)

                    Button {
                        guard !product.isSoldOut else { return }
                        cart.add(product: product, size: selectedSize)
                        withAnimation { addedToCart = true }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            withAnimation { addedToCart = false }
                        }
                    } label: {
                        Text(product.isSoldOut ? "SOLD OUT" : addedToCart ? "ADDED ✓" : "ADD TO CART")
                            .font(.system(size: 11, weight: .medium)).tracking(3)
                            .foregroundColor(warmCream)
                            .frame(maxWidth: .infinity).frame(height: 52)
                            .background(product.isSoldOut ? Color.gray : addedToCart ? Color(hex: "1B5E20") : inkBlack)
                    }
                    .buttonStyle(.plain)
                    .disabled(product.isSoldOut)
                }
                .padding(.horizontal, 20).padding(.vertical, 12).padding(.bottom, 24)
                .background(Color(UIColor.systemBackground).ignoresSafeArea(edges: .bottom))
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .tint(.black)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Image("AbyrLogoDark")
                    .resizable().renderingMode(.original).scaledToFit()
                    .frame(width: 100).scaleEffect(1.5)
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink {
                    CartView()
                } label: {
                    ZStack(alignment: .topTrailing) {
                        Image(systemName: "bag")
                            .foregroundColor(inkBlack)
                        if cart.totalItems > 0 {
                            Text("\(cart.totalItems)")
                                .font(.system(size: 8, weight: .bold))
                                .foregroundColor(warmCream)
                                .frame(width: 14, height: 14)
                                .background(brandRed)
                                .clipShape(Circle())
                                .offset(x: 7, y: -7)
                        }
                    }
                }
            }
        }
        .task {
            await suggestionService.fetchProducts(category: "All", search: "")
        }
    }
}
