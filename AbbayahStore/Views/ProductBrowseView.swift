import SwiftUI

// MARK: - Sort options
enum ProductSort: CaseIterable {
    case newest, priceLow, priceHigh, name

    var label: String {
        switch self {
        case .newest:    return "Newest"
        case .priceLow:  return "Price: Low to High"
        case .priceHigh: return "Price: High to Low"
        case .name:      return "Name"
        }
    }
}

// MARK: - Unified product browsing screen
// Used by Search, category tiles, and offers. Has search bar, category chips,
// a sort dropdown, and the product grid — one consistent experience everywhere.
struct ProductBrowseView: View {
    // Configuration
    var initialCategory: String = "All"
    var initialSearch: String = ""
    var showSearchBar: Bool = true
    var showCategoryChips: Bool = true
    var navTitle: String? = nil   // when set, shows a text title instead of the logo

    @StateObject private var service = ProductService()
    @StateObject private var collectionService = CollectionService()

    @State private var searchText = ""
    @State private var selectedCategory = "All"
    @State private var sort: ProductSort = .newest
    @State private var isLoading = false
    @State private var didLoad = false

    private let inkBlack = Color(hex: "1A1A1A")
    private let goldTan = Color(hex: "8B7355")
    private let sandBg = Color(hex: "FAFAF8")
    private let borderColor = Color(hex: "E8E8E4")
    private let warmCream = Color(hex: "F5F0E8")

    private var categories: [String] {
        ["All"] + collectionService.collections.map { $0.name }
    }

    private var sortedProducts: [Product] {
        switch sort {
        case .newest:    return service.products
        case .priceLow:  return service.products.sorted { $0.displayPrice < $1.displayPrice }
        case .priceHigh: return service.products.sorted { $0.displayPrice > $1.displayPrice }
        case .name:      return service.products.sorted { $0.name.lowercased() < $1.name.lowercased() }
        }
    }

    private let grid = [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)]

    var body: some View {
        ZStack {
            sandBg.ignoresSafeArea()
            VStack(spacing: 0) {

                if showSearchBar {
                    HStack(spacing: 10) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 13)).foregroundColor(Color.gray.opacity(0.5))
                        TextField("Search abayas, jalabiya...", text: $searchText)
                            .font(.system(size: 13))
                            .onSubmit { Task { await load() } }
                        if !searchText.isEmpty {
                            Button { searchText = ""; Task { await load() } } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(Color.gray.opacity(0.4))
                            }
                        }
                    }
                    .padding(.horizontal, 14).padding(.vertical, 11)
                    .background(Color(hex: "F2F0EB"))
                    .padding(.horizontal, 20).padding(.vertical, 14)
                    .background(Color.white)
                }

                // Chips + sort row
                HStack(spacing: 0) {
                    if showCategoryChips {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(categories, id: \.self) { cat in
                                    Button {
                                        selectedCategory = cat
                                        Task { await load() }
                                    } label: {
                                        Text(cat.uppercased())
                                            .font(.system(size: 9, weight: .medium)).tracking(1)
                                            .padding(.horizontal, 14).padding(.vertical, 7)
                                            .background(selectedCategory == cat ? inkBlack : Color.clear)
                                            .foregroundColor(selectedCategory == cat ? warmCream : Color.gray)
                                            .overlay(Rectangle().stroke(selectedCategory == cat ? inkBlack : borderColor, lineWidth: 0.5))
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(.leading, 20).padding(.trailing, 10)
                        }
                    } else {
                        Spacer()
                    }

                    // Sort dropdown
                    Menu {
                        ForEach(ProductSort.allCases, id: \.self) { option in
                            Button {
                                sort = option
                            } label: {
                                HStack {
                                    Text(option.label)
                                    if sort == option { Image(systemName: "checkmark") }
                                }
                            }
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "arrow.up.arrow.down").font(.system(size: 10))
                            Text("Sort").font(.system(size: 9, weight: .medium))
                        }
                        .foregroundColor(inkBlack)
                        .padding(.horizontal, 12).padding(.vertical, 7)
                        .overlay(Rectangle().stroke(borderColor, lineWidth: 0.5))
                    }
                    .padding(.trailing, 20)
                }
                .padding(.vertical, 12)
                .background(Color.white)
                .overlay(Rectangle().frame(height: 0.5).foregroundColor(borderColor), alignment: .bottom)

                // Results
                if isLoading {
                    Spacer(); ProgressView().tint(inkBlack); Spacer()
                } else if service.products.isEmpty {
                    Spacer()
                    VStack(spacing: 12) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 36)).foregroundColor(goldTan.opacity(0.4))
                        Text(searchText.isEmpty ? "Nothing here yet" : "No results found")
                            .font(.custom("Georgia", size: 18)).italic().foregroundColor(inkBlack)
                        if !searchText.isEmpty {
                            Text("Try a different search term")
                                .font(.system(size: 11)).foregroundColor(.secondary)
                        }
                    }
                    Spacer()
                } else {
                    ScrollView(showsIndicators: false) {
                        HStack {
                            Text("\(sortedProducts.count) \(sortedProducts.count == 1 ? "piece" : "pieces")")
                                .font(.system(size: 10)).foregroundColor(.secondary)
                            Spacer()
                        }
                        .padding(.horizontal, 20).padding(.top, 12)

                        LazyVGrid(columns: grid, spacing: 16) {
                            ForEach(sortedProducts) { product in
                                NavigationLink { ProductDetailView(product: product) } label: {
                                    HniProductCard(product: product)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal, 20).padding(.top, 8)

                        Color.clear.frame(height: 100)
                    }
                    .refreshable { await load() }
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                if let navTitle {
                    Text(navTitle.uppercased())
                        .font(.system(size: 11, weight: .medium)).tracking(2).foregroundColor(inkBlack)
                } else {
                    AbyrNavLogo()
                }
            }
        }
        .task {
            guard !didLoad else { return }
            didLoad = true
            selectedCategory = initialCategory
            searchText = initialSearch
            await collectionService.fetchCollections()
            await load()
        }
    }

    private func load() async {
        isLoading = true
        await service.fetchProducts(category: selectedCategory, search: searchText)
        isLoading = false
    }
}
