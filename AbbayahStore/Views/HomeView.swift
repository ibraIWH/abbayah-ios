import SwiftUI

struct HomeView: View {

    @StateObject private var service = ProductService()

    // UI State
    @State private var selectedCategory: String = "All"
    @State private var searchText: String = ""
    @State private var isLoading = true

    private let categories = ["All", "Black", "Gagie", "Occasion"]

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {

                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {

                        // 🔍 Search
                        TextField("Search abbayah...", text: $searchText)
                            .textFieldStyle(.roundedBorder)
                            .padding(.horizontal)

                        // 🏷 Categories
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(categories, id: \.self) { category in
                                    categoryButton(category)
                                }
                            }
                            .padding(.horizontal)
                        }

                        // 📦 Content
                        if isLoading {
                            ProgressView()
                                .frame(maxWidth: .infinity)
                                .padding(.top, 50)
                        } else {
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

                        // ⬇️ Spacer so bottom bar does NOT cover last item
                        Color.clear.frame(height: 110)
                    }
                    .padding(.top)
                }
                .refreshable {
                    await refreshProducts()
                }
                .task {
                    await refreshProducts()
                }

                // ⬇️ Bottom Bar
                bottomBar
            }
            .navigationTitle("Abbayah Store")
        }
    }

    // MARK: - Category Button
    private func categoryButton(_ category: String) -> some View {
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
                    ? Color.primary
                    : Color(.systemGray5)
                )
                .foregroundColor(
                    selectedCategory == category
                    ? Color(.systemBackground)
                    : .primary
                )
                .clipShape(Capsule())
        }
    }

    // MARK: - Bottom Bar (Dark-mode friendly)
    private var bottomBar: some View {
        HStack {
            Spacer()
            Image(systemName: "house.fill")
            Spacer()
            Image(systemName: "heart")
            Spacer()
            Image(systemName: "bag")
            Spacer()
            Image(systemName: "person")
            Spacer()
        }
        .font(.title3)
        .padding(.top, 14)
        .padding(.bottom, 28)
        .background(.ultraThinMaterial) // ✅ dark mode friendly
        .overlay(Divider(), alignment: .top)
        .ignoresSafeArea(edges: .bottom)
    }

    // MARK: - Data
    private func refreshProducts() async {
        isLoading = true
        await service.fetchProducts(
            category: selectedCategory,
            search: searchText
        )
        isLoading = false
    }
}
