import SwiftUI

// MARK: - Bottom Bar Tabs
enum BottomTab {
    case home, search, categories, favorites, cart, profile
}

struct HomeView: View {

    @StateObject private var service = ProductService()
    @StateObject private var collectionService = CollectionService()
    @StateObject private var offerService = OfferService()
    @ObservedObject private var notifications = NotificationService.shared
    @StateObject private var settingsService = SettingsService()
    @EnvironmentObject private var nav: NavigationCoordinator
    @EnvironmentObject private var cart: CartStore
    @Environment(\.colorScheme) private var colorScheme

    @State private var selectedTab: BottomTab = .home
    @State private var selectedCategory: String = "All"
    @State private var searchText: String = ""
    @State private var isLoading: Bool = false
    @State private var errorMessage: String?

    private let categories = ["All", "Abaya", "Jalabiya", "Niqab", "Bisht", "School"]

    private let inkBlack = Color(hex: "1A1A1A")
    private let warmCream = Color(hex: "F5F0E8")
    private let goldTan = Color(hex: "8B7355")
    private let gold = Color(hex: "C4A882")
    private let sandBg = Color(hex: "FAFAF8")
    private let borderColor = Color(hex: "E8E8E4")
    private let brandRed = Color(hex: "5C0A14")
    private let deepRed = Color(hex: "3D0608")

    var body: some View {
        ZStack {
            NavigationStack {
                ZStack(alignment: .bottom) {
                    sandBg.ignoresSafeArea()

                    switch selectedTab {
                    case .home:
                        homeContent
                    case .search:
                        SearchView()
                    case .categories:
                        CategoryView()
                    case .cart:
                        CartView()
                    case .favorites:
                        FavouritesView()
                    case .profile:
                        MyAccountView()
                    }

                    bottomBar
                }
                .onChange(of: selectedTab) { _, newTab in
                    if newTab == .home {
                        Task { await refreshAll() }
                    }
                }
                .ignoresSafeArea(edges: .bottom)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button {
                            selectedTab = .search
                        } label: {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(inkBlack)
                        }
                        .accessibilityLabel("Search products")
                    }
                    ToolbarItem(placement: .principal) {
                        AbyrNavLogo()
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        HStack(spacing: 16) {
                            NavigationLink {
                                NotificationsView()
                            } label: {
                                ZStack(alignment: .topTrailing) {
                                    Image(systemName: "bell")
                                        .foregroundColor(inkBlack)
                                    if notifications.unread > 0 {
                                        Text("\(min(notifications.unread, 99))")
                                            .font(.system(size: 10, weight: .bold))
                                            .foregroundColor(.white)
                                            .padding(.horizontal, 5)
                                            .frame(minWidth: 18, minHeight: 18)
                                            .background(Color(hex: "5C0A14"))
                                            .clipShape(Capsule())
                                            .offset(x: 12, y: -10)
                                    }
                                }
                                .frame(height: 28)
                            }
                            .accessibilityLabel("Notifications")

                            Button {
                                selectedTab = .cart
                            } label: {
                                ZStack(alignment: .topTrailing) {
                                    Image(systemName: "bag")
                                        .foregroundColor(inkBlack)
                                    if cart.totalItems > 0 {
                                        Text("\(min(cart.totalItems, 99))")
                                            .font(.system(size: 10, weight: .bold))
                                            .foregroundColor(.white)
                                            .padding(.horizontal, 5)
                                            .frame(minWidth: 18, minHeight: 18)
                                            .background(Color(hex: "5C0A14"))
                                            .clipShape(Capsule())
                                            .offset(x: 12, y: -10)
                                    }
                                }
                                .frame(height: 28)
                            }
                            .accessibilityLabel("Cart")
                        }
                    }
                }
            }
            .tint(.black)
            .task {
                // Settings first (controls hero + banner), all concurrent so nothing staggers in
                async let s: Void = settingsService.fetchSettings()
                async let c: Void = collectionService.fetchCollections()
                async let o: Void = offerService.fetchOffers()
                async let p: Void = refreshProducts()
                async let n: Void = notifications.fetch()
                _ = await (s, c, o, p, n)
            }
            .id(nav.rootID)
        }
        .onChange(of: nav.rootID) { _, _ in
            selectedTab = .home
        }
    }

    private var homeContent: some View {
        VStack(spacing: 0) {

            // Pinned so it stays visible and never slides under the nav bar
            if let news = settingsService.settings?.newsText, !news.isEmpty {
                MarqueeText(
                    text: news,
                    gold: gold,
                    textColor: warmCream
                )
                .padding(.vertical, 7)
                .frame(maxWidth: .infinity)
                .background(inkBlack)
                .clipped()
            }

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {

                    ZStack(alignment: .bottomLeading) {
                        AsyncImage(url: URL(string: heroImageURL)) { phase in
                            switch phase {
                            case .success(let image):
                                image.resizable().scaledToFill()
                            default:
                                ZStack {
                                    LinearGradient(colors: [Color(hex: "6b5444"), Color(hex: "4a3a2e")],
                                                   startPoint: .topLeading, endPoint: .bottomTrailing)
                                    ProgressView().tint(gold)
                                }
                            }
                        }
                        .frame(height: 480)
                        .frame(maxWidth: .infinity)
                        .clipped()

                        LinearGradient(
                            colors: [Color.clear, Color.clear, Color.black.opacity(0.55)],
                            startPoint: .top, endPoint: .bottom
                        )
                        .frame(height: 480)

                        // Hero text — only once settings have loaded (prevents placeholder flash)
                        if let hero = settingsService.settings?.hero {
                            VStack(alignment: .leading, spacing: 0) {
                                Text(hero.eyebrow ?? "")
                                    .font(.system(size: 9, weight: .semibold))
                                    .tracking(3)
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 5)
                                    .background(Color.black.opacity(0.35))
                                    .padding(.bottom, 10)
                                Text(hero.title ?? "")
                                    .font(.custom("Georgia", size: heroTitleSize(hero.title ?? "")))
                                    .italic()
                                    .foregroundColor(.white)
                                    .lineLimit(2)
                                    .minimumScaleFactor(0.5)
                                    .fixedSize(horizontal: false, vertical: true)
                                    .padding(.bottom, 4)
                                Text(hero.subtitle ?? "")
                                    .font(.system(size: 11))
                                    .foregroundColor(.white.opacity(0.85))
                                    .padding(.bottom, 18)

                                Button {
                                    selectedTab = .search
                                } label: {
                                    Text(hero.ctaText ?? "SHOP NOW")
                                        .font(.system(size: 10, weight: .semibold))
                                        .tracking(3)
                                        .foregroundColor(inkBlack)
                                        .padding(.horizontal, 34)
                                        .padding(.vertical, 13)
                                        .background(warmCream)
                                }
                                .buttonStyle(.plain)
                            }
                            .padding(.horizontal, 24)
                            .padding(.bottom, 32)
                        }
                    }

                    sectionHeader(eyebrow: "Curated", title: "Shop by Collection", showLink: false)
                    if collectionService.isLoading {
                        HStack {
                            Spacer()
                            ProgressView().tint(inkBlack)
                            Spacer()
                        }
                        .frame(height: 158)
                    } else {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 9) {
                                ForEach(collectionService.collections) { coll in
                                    collectionPill(title: coll.name, image: coll.imageUrl ?? "")
                                }
                            }
                            .padding(.horizontal, 18)
                        }
                        .padding(.bottom, 6)
                    }

                    if offerService.isLoading {
                        HStack {
                            Spacer()
                            ProgressView().tint(inkBlack)
                            Spacer()
                        }
                        .frame(height: 220)
                    } else if !offerService.offers.isEmpty {
                        sectionHeader(eyebrow: "Don't Miss", title: "Offers", showLink: false)
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 14) {
                                ForEach(offerService.offers) { offer in
                                    NavigationLink {
                                        CategoryProductsView(categoryTitle: offer.title, category: "All")
                                    } label: {
                                        offerBanner(title: offer.title,
                                                    badge: offer.badgeText ?? "",
                                                    subtitle: offer.subtitle ?? "",
                                                    image: offer.imageUrl ?? "")
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(.horizontal, 18)
                        }
                        .padding(.bottom, 6)
                    }

                    sectionHeader(eyebrow: "Just In", title: "New Arrivals", showLink: true)
                    horizontalProducts

                    if let promo = settingsService.settings?.promo, promo.active != false {
                        sectionHeader(eyebrow: "Limited", title: "The Summer Edit", showLink: false)
                        promoBanner(promo)
                            .padding(.horizontal, 18)
                            .padding(.top, 2)
                    }

                    sectionHeader(eyebrow: "Loved by You", title: "Trending Now", showLink: true)
                    horizontalProducts

                    Color.clear.frame(height: 110)
                }
            }
            .refreshable {
                await refreshAll()
            }
        }
    }

    private var horizontalProducts: some View {
        Group {
            if isLoading {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(0..<3, id: \.self) { _ in
                            SkeletonCard().frame(width: 160)
                        }
                    }
                    .padding(.horizontal, 18)
                }
            } else if service.products.isEmpty {
                Text("No products yet")
                    .font(.system(size: 11)).foregroundColor(.secondary)
                    .padding(.horizontal, 18).padding(.vertical, 20)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(service.products) { product in
                            NavigationLink {
                                ProductDetailView(product: product)
                            } label: {
                                HniProductCard(product: product)
                                    .frame(width: 160)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 18)
                }
            }
        }
    }

    // Side-scrolling editorial offer banner (web-style card)
    private func offerBanner(title: String, badge: String, subtitle: String, image: String) -> some View {
        let cardWidth = UIScreen.main.bounds.width - 48
        let cardHeight: CGFloat = 260

        return HStack(spacing: 0) {
            // LEFT: image half
            AsyncImage(url: URL(string: image)) { phase in
                switch phase {
                case .success(let img):
                    img.resizable().scaledToFill()
                default:
                    LinearGradient(colors: [Color(hex: "6b5444"), Color(hex: "4a3a2e")],
                                   startPoint: .topLeading, endPoint: .bottomTrailing)
                }
            }
            .frame(width: cardWidth * 0.5, height: cardHeight)
            .clipped()

            // RIGHT: dark text panel
            VStack(alignment: .leading, spacing: 0) {
                if !badge.isEmpty {
                    Text(badge)
                        .font(.system(size: 10, weight: .semibold))
                        .tracking(1)
                        .foregroundColor(inkBlack)
                        .padding(.horizontal, 12).padding(.vertical, 7)
                        .background(gold)
                }
                Spacer()
                Text(title)
                    .font(.custom("Georgia", size: 26))
                    .italic()
                    .foregroundColor(warmCream)
                    .lineLimit(3)
                    .fixedSize(horizontal: false, vertical: true)
                if !subtitle.isEmpty {
                    Text(subtitle)
                        .font(.system(size: 11))
                        .foregroundColor(warmCream.opacity(0.7))
                        .padding(.top, 8)
                }
                Spacer()
                Rectangle().fill(gold.opacity(0.5)).frame(height: 0.5)
                    .padding(.bottom, 12)
                HStack(spacing: 8) {
                    Text("SHOP NOW")
                        .font(.system(size: 10, weight: .semibold)).tracking(2)
                        .foregroundColor(gold)
                    Image(systemName: "arrow.right").font(.system(size: 10)).foregroundColor(gold)
                }
            }
            .padding(18)
            .frame(width: cardWidth * 0.5, height: cardHeight, alignment: .leading)
            .background(inkBlack)
        }
        .frame(width: cardWidth, height: cardHeight)
        .clipped()
    }

    private func sectionHeader(eyebrow: String, title: String, showLink: Bool) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(eyebrow.uppercased())
                    .font(.system(size: 9, weight: .medium))
                    .tracking(2)
                    .foregroundColor(goldTan)
                Text(title)
                    .font(.custom("Georgia", size: 22))
                    .italic()
                    .foregroundColor(inkBlack)
            }
            Spacer()
            if showLink {
                Text("VIEW ALL →")
                    .font(.system(size: 9, weight: .medium))
                    .tracking(1)
                    .foregroundColor(inkBlack)
                    .padding(.bottom, 2)
                    .overlay(
                        Rectangle().frame(height: 0.5).foregroundColor(inkBlack),
                        alignment: .bottom
                    )
            }
        }
        .padding(.horizontal, 18)
        .padding(.top, 28)
        .padding(.bottom, 14)
    }

    private func collectionPill(title: String, image: String) -> some View {
        Button {
            selectedTab = .search
        } label: {
            ZStack(alignment: .bottom) {
                AsyncImage(url: URL(string: image)) { phase in
                    if case .success(let img) = phase {
                        img.resizable().scaledToFill()
                    } else {
                        Color(hex: "D8CFC2")
                    }
                }
                .frame(width: 120, height: 158)
                .clipped()

                LinearGradient(colors: [Color.clear, Color.black.opacity(0.55)],
                               startPoint: .center, endPoint: .bottom)
                    .frame(width: 120, height: 158)

                Text(title)
                    .font(.custom("Georgia", size: 15))
                    .italic()
                    .foregroundColor(.white)
                    .padding(.bottom, 11)
            }
            .frame(width: 120, height: 158)
        }
        .buttonStyle(.plain)
    }

    private func promoBanner(_ promo: SiteSettings.Promo) -> some View {
        ZStack(alignment: .leading) {
            LinearGradient(colors: [deepRed, brandRed],
                           startPoint: .topLeading, endPoint: .bottomTrailing)

            VStack(alignment: .leading, spacing: 0) {
                if let code = promo.code, !code.isEmpty {
                    Text("CODE \(code)")
                        .font(.system(size: 9, weight: .bold))
                        .tracking(2)
                        .foregroundColor(deepRed)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(gold)
                        .padding(.bottom, 10)
                }
                Text(promo.line1 ?? "")
                    .font(.custom("Georgia", size: 25))
                    .italic()
                    .foregroundColor(warmCream)
                Text(promo.line2 ?? "")
                    .font(.custom("Georgia", size: 25))
                    .italic()
                    .foregroundColor(warmCream)
                    .padding(.bottom, 3)
                if let subtitle = promo.subtitle, !subtitle.isEmpty {
                    Text(subtitle)
                        .font(.system(size: 9))
                        .foregroundColor(.white.opacity(0.7))
                }
            }
            .padding(.horizontal, 22)
        }
        .frame(height: 140)
    }

    private var bottomBar: some View {
        HStack {
            bottomBarBtn(icon: "house", label: "Home", tab: .home)
            bottomBarBtn(icon: "square.grid.2x2", label: "Shop", tab: .categories)
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
            Rectangle().frame(height: 0.5).foregroundColor(borderColor),
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

    private func resetHomeState() {
        selectedCategory = "All"
        searchText = ""
        Task { await refreshAll() }
    }

    /// Reload everything the home screen shows, live from the server.
    private func refreshAll() async {
        async let s: Void = settingsService.fetchSettings()
        async let c: Void = collectionService.fetchCollections()
        async let o: Void = offerService.fetchOffers()
        async let p: Void = refreshProducts()
        _ = await (s, c, o, p)
    }

    /// The hero title is set from the admin panel, so its length varies a lot.
    /// Short titles get a smaller size so a single word can't swallow the hero.
    private func heroTitleSize(_ title: String) -> CGFloat {
        switch title.count {
        case 0...6:   return 28
        case 7...14:  return 34
        case 15...24: return 40
        default:      return 44
        }
    }

    // Hero image: only the backend image. Empty → shows the gradient placeholder (no stock photo).
    private var heroImageURL: String {
        settingsService.settings?.hero?.imageUrl ?? ""
    }

    private func refreshProducts() async {
        isLoading = true
        errorMessage = nil
        await service.fetchProducts(category: selectedCategory, search: searchText)
        isLoading = false
    }
}

// MARK: - PRODUCT CARD
struct HniProductCard: View {
    let product: Product
    @ObservedObject private var favourites = FavouritesService.shared
    @Environment(\.colorScheme) private var colorScheme

    private let inkBlack = Color(hex: "1A1A1A")
    private let goldTan = Color(hex: "8B7355")
    private let gold = Color(hex: "C4A882")
    private let brandRed = Color(hex: "5C0A14")
    private let warmCream = Color(hex: "F5F0E8")

    var body: some View {
        ZStack(alignment: .bottom) {
            // Image
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
                            .font(.system(size: 28))
                            .foregroundColor(gold.opacity(0.4))
                    }
                @unknown default:
                    Color(hex: "EDE8E0")
                }
            }
            .frame(height: 280)
            .frame(maxWidth: .infinity)
            .clipped()

            // Bottom gradient for text legibility
            LinearGradient(
                colors: [Color.clear, Color.black.opacity(0.15), Color.black.opacity(0.65)],
                startPoint: .center, endPoint: .bottom
            )
            .frame(height: 280)

            // Text overlay (category, name, price)
            VStack(alignment: .leading, spacing: 4) {
                Text(product.category.uppercased())
                    .font(.system(size: 8, weight: .semibold))
                    .tracking(1.5)
                    .foregroundColor(.white)
                    .padding(.horizontal, 7)
                    .padding(.vertical, 3)
                    .background(Color.black.opacity(0.4))

                Text(product.name)
                    .font(.custom("Georgia", size: 16))
                    .italic()
                    .foregroundColor(.white)
                    .lineLimit(1)
                    .shadow(color: .black.opacity(0.5), radius: 3, x: 0, y: 1)

                HStack(alignment: .firstTextBaseline, spacing: 6) {
                    Text("SAR \(product.displayPrice, specifier: "%.2f")")
                        .font(.custom("Georgia", size: 15))
                        .italic()
                        .foregroundColor(.white)
                    if product.isOnSale {
                        Text("SAR \(product.price, specifier: "%.2f")")
                            .font(.system(size: 10))
                            .strikethrough()
                            .foregroundColor(.white.opacity(0.6))
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 12)
            .padding(.bottom, 12)

            // Top row: discount/tag (left) + heart (right)
            VStack {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 5) {
                        if product.isOnSale {
                            tagLabel(text: salePercentText, bg: brandRed)
                        }
                        if let t = product.productTag {
                            tagLabel(text: t.label, bg: t.color)
                        }
                    }

                    Spacer()

                    Button {
                        Task { await favourites.toggle(product: product) }
                    } label: {
                        Image(systemName: favourites.isFavourite(product.id) ? "heart.fill" : "heart")
                            .font(.system(size: 14))
                            .foregroundColor(favourites.isFavourite(product.id) ? Color(hex: "5C0A14") : .white)
                            .padding(9)
                            .background(Color.black.opacity(0.3))
                            .clipShape(Circle())
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(favourites.isFavourite(product.id) ? "Remove \(product.name) from favourites" : "Add \(product.name) to favourites")
                }
                Spacer()
            }
            .padding(10)
        }
        .frame(height: 280)
        .clipped()
        .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
        .accessibilityElement(children: .combine)
    }

    private var salePercentText: String {
        guard let sale = product.salePrice, product.price > 0 else { return "SALE" }
        let pct = Int(round((1 - sale / product.price) * 100))
        return "\(pct)% OFF"
    }

    private func tagLabel(text: String, bg: Color) -> some View {
        Text(text)
            .font(.system(size: 8, weight: .semibold))
            .tracking(0.5)
            .foregroundColor(warmCream)
            .padding(.horizontal, 9)
            .padding(.vertical, 5)
            .background(bg)
    }
}

// MARK: - Product Tag
enum ProductTag {
    case bestSeller
    case sellingFast

    var label: String {
        switch self {
        case .bestSeller: return "BEST SELLER"
        case .sellingFast: return "SELLING FAST"
        }
    }

    var color: Color {
        switch self {
        case .bestSeller: return Color(hex: "1A1A1A")
        case .sellingFast: return Color(hex: "5C0A14")
        }
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

// MARK: - Marquee (scrolling news ticker)
struct MarqueeText: View {
    let text: String
    let gold: Color
    let textColor: Color

    @State private var animate = false
    @State private var contentWidth: CGFloat = 0

    // One repetition of the message
    private func unit() -> some View {
        HStack(spacing: 10) {
            Text(text)
                .font(.system(size: 8, weight: .medium))
                .tracking(1.5)
                .foregroundColor(textColor)
                .fixedSize()
            Text("✦")
                .font(.system(size: 8))
                .foregroundColor(gold)
                .padding(.horizontal, 14)
        }
    }

    var body: some View {
        GeometryReader { geo in
            let screenW = geo.size.width
            // How many repetitions to fill one screen width (at least 1)
            let repsPerScreen = contentWidth > 0 ? Int((screenW / contentWidth).rounded(.up)) + 1 : 4

            HStack(spacing: 0) {
                // Track A
                HStack(spacing: 0) {
                    ForEach(0..<max(repsPerScreen, 1), id: \.self) { _ in unit() }
                }
                .background(
                    GeometryReader { p in
                        Color.clear.onAppear {
                            // width of ONE unit = trackA width / reps
                            contentWidth = p.size.width / CGFloat(max(repsPerScreen, 1))
                        }
                    }
                )
                // Track B (identical) — sits right after A for seamless wrap
                HStack(spacing: 0) {
                    ForEach(0..<max(repsPerScreen, 1), id: \.self) { _ in unit() }
                }
            }
            .offset(x: animate ? -(contentWidth * CGFloat(max(repsPerScreen, 1))) : 0)
            .animation(
                contentWidth > 0
                ? .linear(duration: Double(contentWidth * CGFloat(max(repsPerScreen, 1)) / 35))
                    .repeatForever(autoreverses: false)
                : nil,
                value: animate
            )
            .onAppear {
                // Kick the animation on next runloop, once layout is measured
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    animate = true
                }
            }
        }
        .frame(height: 12)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(text)
    }
}

#Preview {
    HomeView()
}
