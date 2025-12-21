import SwiftUI

// MARK: - Bottom Bar Tabs
enum BottomTab {
    case home
    case favorites
    case cart
    case profile
}

struct HomeView: View {

    // MARK: - Services
    @StateObject private var service = ProductService()

    // MARK: - UI State
    @State private var selectedTab: BottomTab = .home
    @State private var selectedCategory: String = "All"
    @State private var searchText: String = ""
    @State private var isLoading: Bool = false
    @State private var errorMessage: String?

    private let categories = ["All", "Black", "Gagie", "Occasion"]

    var body: some View {
        NavigationStack {
            ZStack {

                // MARK: - Content Switch
                switch selectedTab {
                case .home:
                    homeContent
                case .favorites:
                    placeholderView(title: "Favorites")
                case .cart:
                    placeholderView(title: "Cart")
                case .profile:
                    placeholderView(title: "Profile")
                }

                // MARK: - Bottom Bar
                VStack {
                    Spacer()
                    bottomBar
                }
            }
            .navigationTitle("Abbayah Store")
        }
        .task {
            await refreshProducts()
        }
    }

    // MARK: - HOME CONTENT
    private var homeContent: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {

                // 🔍 Search
                TextField("Search abbayah...", text: $searchText)
                    .textFieldStyle(.roundedBorder)
                    .padding(.horizontal)
                    .onSubmit {
                        Task { await refreshProducts() }
                    }

                // 🏷 Categories
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(categories, id: \.self) { category in
                            Button {
                                selectedCategory = category
                                Task { await refreshProducts() }
                            } label: {
                                Text(category)
                                    .font(.subheadline)
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 8)
                                    .background(
                                        selectedCategory == category
                                        ? Color.black
                                        : Color.gray.opacity(0.2)
                                    )
                                    .foregroundColor(
                                        selectedCategory == category
                                        ? .white
                                        : .primary
                                    )
                                    .cornerRadius(20)
                            }
                        }
                    }
                    .padding(.horizontal)
                }

                // 📦 STATES
                if isLoading {
                    ProgressView("Loading products...")
                        .frame(maxWidth: .infinity)
                        .padding(.top, 40)
                }
                else if let errorMessage {
                    VStack(spacing: 12) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.largeTitle)
                            .foregroundColor(.orange)

                        Text("Failed to load products")
                            .font(.headline)

                        Text(errorMessage)
                            .font(.caption)
                            .foregroundColor(.secondary)

                        Button("Retry") {
                            Task { await refreshProducts() }
                        }
                        .padding(.top, 8)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 40)
                }
                else if service.products.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "tray")
                            .font(.largeTitle)
                            .foregroundColor(.secondary)

                        Text("No products found")
                            .font(.headline)

                        Text("Try another category or search.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 40)
                }
                else {
                    // 🛍 Products Grid
                    LazyVGrid(
                        columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ],
                        spacing: 16
                    ) {
                        ForEach(service.products) { product in
                            NavigationLink {
                                ProductDetailView(product: product)
                            } label: {
                                ProductCard(product: product)
                            }
                        }
                    }
                    .padding(.horizontal)
                }

                // Spacer for bottom bar
                Color.clear.frame(height: 120)
            }
            .padding(.top)
        }
    }

    // MARK: - BOTTOM BAR
    private var bottomBar: some View {
        HStack {
            Spacer()
            bottomBarButton(icon: "house.fill", tab: .home)
            Spacer()
            bottomBarButton(icon: "heart", tab: .favorites)
            Spacer()
            bottomBarButton(icon: "bag", tab: .cart)
            Spacer()
            bottomBarButton(icon: "person", tab: .profile)
            Spacer()
        }
        .font(.title3)
        .padding(.top, 14)
        .padding(.bottom, 28)
        .background(.ultraThinMaterial)
        .overlay(Divider(), alignment: .top)
        .ignoresSafeArea(edges: .bottom)
    }

    private func bottomBarButton(icon: String, tab: BottomTab) -> some View {
        Button {
            if tab == .home {
                selectedTab = .home
                resetHomeState()
            } else {
                selectedTab = tab
            }
        } label: {
            Image(systemName: icon)
                .foregroundColor(
                    selectedTab == tab ? .primary : .secondary
                )
        }
    }

    // MARK: - PLACEHOLDER
    private func placeholderView(title: String) -> some View {
        VStack(spacing: 12) {
            Spacer()
            Image(systemName: "clock")
                .font(.largeTitle)
                .foregroundColor(.secondary)
            Text("\(title) coming soon")
                .font(.headline)
            Spacer()
        }
    }

    // MARK: - RESET HOME
    private func resetHomeState() {
        selectedCategory = "All"
        searchText = ""
        Task {
            await refreshProducts()
        }
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
