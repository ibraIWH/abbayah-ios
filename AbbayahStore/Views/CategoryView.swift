import SwiftUI

// MARK: - CATEGORY SCREEN (driven by backend categories)
struct CategoryView: View {
    @StateObject private var collectionService = CollectionService()

    private let inkBlack = Color(hex: "1A1A1A")
    private let goldTan = Color(hex: "8B7355")
    private let gold = Color(hex: "C4A882")
    private let sandBg = Color(hex: "FAFAF8")
    private let warmCream = Color(hex: "F5F0E8")

    private let columns = [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)]

    var body: some View {
        ZStack {
            sandBg.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {

                    Text("Categories")
                        .font(.custom("Georgia", size: 28))
                        .italic()
                        .foregroundColor(inkBlack)
                        .padding(.horizontal, 18)
                        .padding(.top, 14)
                        .padding(.bottom, 16)

                    if collectionService.isLoading && collectionService.collections.isEmpty {
                        ProgressView().tint(inkBlack)
                            .frame(maxWidth: .infinity).padding(.top, 60)
                    } else if collectionService.collections.isEmpty {
                        VStack(spacing: 12) {
                            Image(systemName: "square.grid.2x2")
                                .font(.system(size: 40)).foregroundColor(goldTan.opacity(0.35))
                            Text("No categories yet")
                                .font(.custom("Georgia", size: 20)).italic().foregroundColor(inkBlack)
                            Text("Browse the full collection instead.")
                                .font(.system(size: 11)).foregroundColor(.secondary)
                            NavigationLink {
                                CategoryProductsView(categoryTitle: "All Products", category: "All")
                            } label: {
                                Text("SHOP ALL")
                                    .font(.system(size: 10, weight: .medium)).tracking(2)
                                    .foregroundColor(warmCream)
                                    .padding(.horizontal, 24).padding(.vertical, 12)
                                    .background(inkBlack)
                            }
                            .buttonStyle(.plain)
                            .padding(.top, 6)
                        }
                        .frame(maxWidth: .infinity).padding(.top, 50)
                    } else {
                        // "Shop All" always first, then one tile per backend category
                        LazyVGrid(columns: columns, spacing: 12) {
                            NavigationLink {
                                CategoryProductsView(categoryTitle: "All Products", category: "All")
                            } label: {
                                shopAllTile()
                            }
                            .buttonStyle(.plain)

                            ForEach(collectionService.collections) { cat in
                                NavigationLink {
                                    CategoryProductsView(categoryTitle: cat.name, category: cat.name)
                                } label: {
                                    categoryTile(name: cat.name, image: cat.imageUrl ?? "")
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal, 18)
                    }

                    Color.clear.frame(height: 110)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) { AbyrNavLogo() }
        }
        .task { await collectionService.fetchCollections() }
        .refreshable { await collectionService.fetchCollections() }
    }

    private func shopAllTile() -> some View {
        ZStack(alignment: .bottomLeading) {
            LinearGradient(colors: [Color(hex: "3D0608"), Color(hex: "5C0A14")],
                           startPoint: .topLeading, endPoint: .bottomTrailing)
                .frame(maxWidth: .infinity)
                .frame(height: 210)

            VStack(alignment: .leading, spacing: 3) {
                Text("EVERYTHING")
                    .font(.system(size: 8, weight: .medium)).tracking(2).foregroundColor(gold)
                Text("Shop All")
                    .font(.custom("Georgia", size: 21)).italic().foregroundColor(.white)
            }
            .padding(14)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 210)
        .clipped()
        .contentShape(Rectangle())
    }

    private func categoryTile(name: String, image: String) -> some View {
        let hasImage = !image.trimmingCharacters(in: .whitespaces).isEmpty

        return ZStack(alignment: .bottomLeading) {
            // Background layer — identical frame for every tile
            Group {
                if hasImage {
                    AsyncImage(url: URL(string: image)) { phase in
                        switch phase {
                        case .success(let img):
                            img.resizable().scaledToFill()
                        case .empty:
                            ZStack { brandTile; ProgressView().tint(warmCream) }
                        default:
                            brandTile
                        }
                    }
                } else {
                    brandTile
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 210)
            .clipped()

            // Dark gradient so the name is readable on any tile
            LinearGradient(colors: [Color.clear, Color.black.opacity(0.55)],
                           startPoint: .center, endPoint: .bottom)
                .frame(maxWidth: .infinity)
                .frame(height: 210)

            VStack(alignment: .leading, spacing: 3) {
                if !hasImage {
                    Text("COLLECTION")
                        .font(.system(size: 8, weight: .medium)).tracking(2).foregroundColor(gold)
                }
                Text(name)
                    .font(.custom("Georgia", size: 19))
                    .italic()
                    .foregroundColor(.white)
                    .lineLimit(1)
            }
            .padding(14)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 210)
        .clipped()
    }

    // Branded gradient used when a category has no photo (matches Shop All)
    private var brandTile: some View {
        LinearGradient(
            colors: [Color(hex: "6b5444"), Color(hex: "3D0608")],
            startPoint: .topLeading, endPoint: .bottomTrailing
        )
    }
}


// MARK: - CATEGORY PRODUCTS (filtered list)
struct CategoryProductsView: View {
    let categoryTitle: String
    let category: String

    @StateObject private var service = ProductService()
    @State private var isLoading = true
    @State private var sort: ProductSort = .newest

    private let inkBlack = Color(hex: "1A1A1A")
    private let goldTan = Color(hex: "8B7355")
    private let sandBg = Color(hex: "FAFAF8")

    private let columns = [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)]

    // Products sorted by the chosen option
    private var sortedProducts: [Product] {
        switch sort {
        case .newest:      return service.products
        case .priceLow:    return service.products.sorted { $0.displayPrice < $1.displayPrice }
        case .priceHigh:   return service.products.sorted { $0.displayPrice > $1.displayPrice }
        case .name:        return service.products.sorted { $0.name.lowercased() < $1.name.lowercased() }
        }
    }

    var body: some View {
        ZStack {
            sandBg.ignoresSafeArea()

            if isLoading {
                ScrollView(showsIndicators: false) {
                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(0..<6, id: \.self) { _ in SkeletonCard() }
                    }
                    .padding(.horizontal, 18).padding(.top, 16)
                }
            } else if service.products.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "tray")
                        .font(.system(size: 44)).foregroundColor(goldTan.opacity(0.4))
                    Text("Nothing here yet")
                        .font(.custom("Georgia", size: 20)).italic().foregroundColor(inkBlack)
                    Text("Check back soon for new pieces.")
                        .font(.system(size: 11)).foregroundColor(.secondary)
                }
            } else {
                ScrollView(showsIndicators: false) {
                    HStack {
                        Text("\(service.products.count) piece\(service.products.count == 1 ? "" : "s")")
                            .font(.system(size: 10)).foregroundColor(.secondary)
                        Spacer()
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
                            HStack(spacing: 5) {
                                Image(systemName: "arrow.up.arrow.down")
                                    .font(.system(size: 10))
                                Text(sort.label)
                                    .font(.system(size: 10, weight: .medium))
                            }
                            .foregroundColor(inkBlack)
                            .padding(.horizontal, 12).padding(.vertical, 7)
                            .overlay(Rectangle().stroke(Color(hex: "E8E8E4"), lineWidth: 0.5))
                        }
                    }
                    .padding(.horizontal, 18).padding(.top, 14).padding(.bottom, 8)

                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(sortedProducts) { product in
                            NavigationLink {
                                ProductDetailView(product: product)
                            } label: {
                                HniProductCard(product: product)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 18)

                    Color.clear.frame(height: 110)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                VStack(spacing: 1) {
                    Text(categoryTitle.uppercased())
                        .font(.system(size: 11, weight: .medium))
                        .tracking(2)
                        .foregroundColor(inkBlack)
                }
            }
        }
        .task {
            isLoading = true
            await service.fetchProducts(category: category, search: "")
            isLoading = false
        }
    }
}

#Preview {
    NavigationStack { CategoryView() }
}

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
