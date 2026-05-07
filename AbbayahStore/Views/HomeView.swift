import SwiftUI

// MARK: - Bottom Bar Tabs
enum BottomTab {
    case home, search, favorites, cart, profile
}

struct HomeView: View {

    // MARK: - Services
    @StateObject private var service = ProductService()
    @Environment(\.colorScheme) private var colorScheme

    // MARK: - UI State
    @State private var selectedTab: BottomTab = .home
    @State private var selectedCategory: String = "All"
    @State private var searchText: String = ""
    @State private var isLoading: Bool = false
    @State private var errorMessage: String?

    private let categories = ["All", "Abaya", "Jalabiya", "Niqab", "Bisht", "School"]

    // MARK: - Design Tokens
    private let inkBlack = Color(hex: "1A1A1A")
    private let warmCream = Color(hex: "F5F0E8")
    private let goldTan = Color(hex: "8B7355")
    private let sandBg = Color(hex: "FAFAF8")
    private let borderColor = Color(hex: "E8E8E4")

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                sandBg.ignoresSafeArea()

                switch selectedTab {
                case .home:
                    homeContent
                case .search:
                    SearchView()
                case .cart:
                    CartView()
                case .favorites:
                    FavouritesView()
                case .profile:
                    MyAccountView()
                }

                bottomBar
            }
            .ignoresSafeArea(edges: .bottom)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Image("AbyrLogoDark")
                        .resizable()
                        .renderingMode(.original)
                        .scaledToFit()
                        .frame(width: 120)
                        .scaleEffect(1.5)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        selectedTab = .cart
                    } label: {
                        Image(systemName: "bag")
                            .foregroundColor(inkBlack)
                    }
                }
            }
        }
        .tint(.black)
        .task {
            await refreshProducts()
        }
    }

    // MARK: - HOME CONTENT
    private var homeContent: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 0) {

                // ── HERO STRIP ──────────────────────────
                ZStack {
                    inkBlack
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Abyr Line")
                                .font(.custom("Georgia", size: 18))
                                .italic()
                                .foregroundColor(warmCream)
                            Text("SPRING 2026")
                                .font(.system(size: 9, weight: .medium))
                                .tracking(3)
                                .foregroundColor(goldTan)
                        }
                        Spacer()
                        Text("SHOP →")
                            .font(.system(size: 9, weight: .medium))
                            .tracking(2)
                            .foregroundColor(Color(hex: "C4A882"))
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .overlay(
                                Rectangle()
                                    .stroke(Color(hex: "C4A882").opacity(0.5), lineWidth: 0.5)
                            )
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                }
                .frame(height: 64)

                // ── SEARCH ──────────────────────────────
                HStack(spacing: 10) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 13))
                        .foregroundColor(Color.gray.opacity(0.5))
                    TextField("Search abayas, jalabiya...", text: $searchText)
                        .font(.system(size: 13))
                        .onSubmit {
                            Task { await refreshProducts() }
                        }
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 11)
                .background(Color(hex: "F2F0EB"))
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 12)

                // ── CATEGORY CHIPS ──────────────────────
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(categories, id: \.self) { category in
                            Button {
                                selectedCategory = category
                                Task { await refreshProducts() }
                            } label: {
                                Text(category.uppercased())
                                    .font(.system(size: 9, weight: .medium))
                                    .tracking(1)
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 7)
                                    .background(
                                        selectedCategory == category
                                        ? inkBlack
                                        : Color.clear
                                    )
                                    .foregroundColor(
                                        selectedCategory == category
                                        ? warmCream
                                        : Color.gray
                                    )
                                    .overlay(
                                        Rectangle()
                                            .stroke(
                                                selectedCategory == category
                                                ? inkBlack
                                                : borderColor,
                                                lineWidth: 0.5
                                            )
                                    )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 20)
                }
                .padding(.bottom, 16)

                // ── SECTION HEADER ──────────────────────
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("NEW ARRIVALS")
                            .font(.system(size: 9, weight: .medium))
                            .tracking(2)
                            .foregroundColor(goldTan)
                        Text("Featured Pieces")
                            .font(.custom("Georgia", size: 22))
                            .italic()
                            .foregroundColor(inkBlack)
                    }
                    Spacer()
                    Text("VIEW ALL →")
                        .font(.system(size: 9, weight: .medium))
                        .tracking(1)
                        .foregroundColor(inkBlack)
                        .padding(.bottom, 2)
                        .overlay(
                            Rectangle()
                                .frame(height: 0.5)
                                .foregroundColor(inkBlack),
                            alignment: .bottom
                        )
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 16)

                // ── PRODUCT STATES ──────────────────────
                if isLoading {
                    VStack(spacing: 12) {
                        ProgressView()
                            .tint(inkBlack)
                        Text("Loading...")
                            .font(.system(size: 11))
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 60)

                } else if let errorMessage {
                    VStack(spacing: 16) {
                        Image(systemName: "exclamationmark.circle")
                            .font(.system(size: 36))
                            .foregroundColor(goldTan)
                        Text("Could not load products")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(inkBlack)
                        Text(errorMessage)
                            .font(.system(size: 11))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                        Button("Try Again") {
                            Task { await refreshProducts() }
                        }
                        .font(.system(size: 10, weight: .medium))
                        .tracking(2)
                        .foregroundColor(warmCream)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(inkBlack)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 20)
                    .padding(.top, 60)

                } else if service.products.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "tray")
                            .font(.system(size: 36))
                            .foregroundColor(goldTan)
                        Text("No products found")
                            .font(.custom("Georgia", size: 18))
                            .italic()
                            .foregroundColor(inkBlack)
                        Text("Try a different category or search.")
                            .font(.system(size: 11))
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 60)

                } else {
                    LazyVGrid(
                        columns: [
                            GridItem(.flexible(), spacing: 12),
                            GridItem(.flexible(), spacing: 12)
                        ],
                        spacing: 16
                    ) {
                        ForEach(service.products) { product in
                            NavigationLink {
                                ProductDetailView(product: product)
                            } label: {
                                HniProductCard(product: product)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 20)
                    .animation(.easeIn(duration: 0.25), value: service.products)
                }

                Color.clear.frame(height: 100)
            }
        }
        .refreshable {
            await refreshProducts()
        }
    }

    // MARK: - BOTTOM BAR
    private var bottomBar: some View {
        HStack {
            bottomBarBtn(icon: "house", label: "Home", tab: .home)
            bottomBarBtn(icon: "magnifyingglass", label: "Search", tab: .search)
            bottomBarBtn(icon: "bag", label: "Cart", tab: .cart)
            bottomBarBtn(icon: "heart", label: "Fav", tab: .favorites)
            bottomBarBtn(icon: "person", label: "Profile", tab: .profile)
        }
        .padding(.top, 12)
        .padding(.bottom, 28)
        .background(
            Color(UIColor.systemBackground)
                .opacity(0.97)
                .ignoresSafeArea(edges: .bottom)
        )
        .overlay(
            Rectangle()
                .frame(height: 0.5)
                .foregroundColor(borderColor),
            alignment: .top
        )
    }

    private func bottomBarBtn(icon: String, label: String, tab: BottomTab) -> some View {
        let isActive = selectedTab == tab
        return Button {
            selectedTab = tab
            if tab == .home { resetHomeState() }
        } label: {
            VStack(spacing: 4) {
                Image(systemName: isActive ? icon + ".fill" : icon)
                    .font(.system(size: 18))
                    .foregroundColor(isActive ? inkBlack : Color.gray.opacity(0.5))
                Text(label.uppercased())
                    .font(.system(size: 7, weight: .medium))
                    .tracking(0.5)
                    .foregroundColor(isActive ? inkBlack : Color.gray.opacity(0.5))
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
    }

    // MARK: - PLACEHOLDER
    private func placeholderView(icon: String, title: String) -> some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: icon)
                .font(.system(size: 36))
                .foregroundColor(goldTan)
            Text(title)
                .font(.custom("Georgia", size: 24))
                .italic()
                .foregroundColor(inkBlack)
            Text("Coming soon")
                .font(.system(size: 11))
                .tracking(1)
                .foregroundColor(.secondary)
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .background(sandBg)
    }

    // MARK: - RESET
    private func resetHomeState() {
        selectedCategory = "All"
        searchText = ""
        Task { await refreshProducts() }
    }

    // MARK: - FETCH
    private func refreshProducts() async {
        isLoading = true
        errorMessage = nil
        do {
            try await service.fetchProducts(
                category: selectedCategory,
                search: searchText
            )
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}

// MARK: - PRODUCT CARD
struct HniProductCard: View {
    let product: Product
    @Environment(\.colorScheme) private var colorScheme

    private let inkBlack = Color(hex: "1A1A1A")
    private let goldTan = Color(hex: "8B7355")

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            AsyncImage(url: URL(string: product.imageUrl)) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                case .failure, .empty:
                    ZStack {
                        Color(hex: "EDE8E0")
                        Image(systemName: "photo")
                            .font(.system(size: 24))
                            .foregroundColor(Color(hex: "C4A882").opacity(0.4))
                    }
                @unknown default:
                    Color(hex: "EDE8E0")
                }
            }
            .frame(height: 200)
            .clipped()
            .overlay(
                Button {
                    // TODO: add to favourites
                } label: {
                    Image(systemName: "heart")
                        .font(.system(size: 13))
                        .foregroundColor(.white)
                        .padding(8)
                        .background(Color.black.opacity(0.25))
                        .clipShape(Circle())
                }
                .padding(8),
                alignment: .topTrailing
            )

            VStack(alignment: .leading, spacing: 4) {
                Text(product.category.uppercased())
                    .font(.system(size: 8, weight: .medium))
                    .tracking(1)
                    .foregroundColor(goldTan)

                Text(product.name)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(inkBlack)
                    .lineLimit(1)

                Text("SAR \(product.price, specifier: "%.2f")")
                    .font(.custom("Georgia", size: 14))
                    .italic()
                    .foregroundColor(goldTan)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(UIColor.systemBackground))
        }
        .background(Color(UIColor.systemBackground))
        .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 4)
    }
}

// MARK: - Color Hex Extension
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

#Preview {
    HomeView()
}
