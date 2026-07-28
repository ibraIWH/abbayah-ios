import SwiftUI

// MARK: - CATEGORY SCREEN (editorial 2-column grid)
struct CategoryView: View {

    private let inkBlack = Color(hex: "1A1A1A")
    private let goldTan = Color(hex: "8B7355")
    private let gold = Color(hex: "C4A882")
    private let sandBg = Color(hex: "FAFAF8")
    private let warmCream = Color(hex: "F5F0E8")

    // Each tile: display title, the real category to filter by, eyebrow, image, and whether it spans full width
    private let tiles: [CategoryTile] = [
        CategoryTile(title: "The Full Collection", category: "All", eyebrow: "Explore All",
                     image: "https://images.unsplash.com/photo-1591369822096-ffd140ec948f?w=600&q=80", wide: true),
        CategoryTile(title: "Black Abayas", category: "Abaya", eyebrow: "Timeless",
                     image: "https://images.unsplash.com/photo-1610030469983-98e550d6193c?w=400&q=80", wide: false),
        CategoryTile(title: "Jalabiya", category: "Jalabiya", eyebrow: "Everyday",
                     image: "https://images.unsplash.com/photo-1551163943-3f6a855d1153?w=400&q=80", wide: false),
        CategoryTile(title: "Occasion", category: "Occasion", eyebrow: "Special",
                     image: "https://images.unsplash.com/photo-1581338834647-b0fb40704e21?w=400&q=80", wide: false),
        CategoryTile(title: "Bisht", category: "Bisht", eyebrow: "Heritage",
                     image: "https://images.unsplash.com/photo-1564257631407-3deb25e91c4c?w=400&q=80", wide: false),
        CategoryTile(title: "The Summer Edit", category: "All", eyebrow: "Seasonal",
                     image: "https://images.unsplash.com/photo-1594633312681-425c7b97ccd1?w=600&q=80", wide: true)
    ]

    var body: some View {
        ZStack {
            sandBg.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {

                    // Page title
                    Text("Categories")
                        .font(.custom("Georgia", size: 28))
                        .italic()
                        .foregroundColor(inkBlack)
                        .padding(.horizontal, 18)
                        .padding(.top, 14)
                        .padding(.bottom, 16)

                    VStack(spacing: 12) {
                        ForEach(rows.indices, id: \.self) { r in
                            let row = rows[r]
                            if row.count == 1, let tile = row.first, tile.wide {
                                // Full-width editorial tile
                                tileLink(tile, height: 170)
                            } else {
                                HStack(spacing: 12) {
                                    ForEach(row) { tile in
                                        tileLink(tile, height: 210)
                                    }
                                    // Keep a lone tile at half width instead of stretching
                                    if row.count == 1 {
                                        Color.clear.frame(maxWidth: .infinity)
                                    }
                                }
                            }
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
                Image("AbyrLogoDark")
                    .resizable().renderingMode(.original).scaledToFit()
                    .frame(width: 120).scaleEffect(1.5)
            }
        }
    }

    /// Wide tiles get a row to themselves; the rest are paired two-up.
    private var rows: [[CategoryTile]] {
        var result: [[CategoryTile]] = []
        var pending: [CategoryTile] = []

        for tile in tiles {
            if tile.wide {
                if !pending.isEmpty { result.append(pending); pending = [] }
                result.append([tile])
            } else {
                pending.append(tile)
                if pending.count == 2 { result.append(pending); pending = [] }
            }
        }
        if !pending.isEmpty { result.append(pending) }
        return result
    }

    private func tileLink(_ tile: CategoryTile, height: CGFloat) -> some View {
        NavigationLink {
            CategoryProductsView(categoryTitle: tile.title, category: tile.category)
        } label: {
            categoryTile(tile, height: height)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Tile
    private func categoryTile(_ tile: CategoryTile, height: CGFloat) -> some View {
        ZStack(alignment: .bottomLeading) {
            AsyncImage(url: URL(string: tile.image)) { phase in
                if case .success(let img) = phase {
                    img.resizable().scaledToFill()
                } else {
                    Color(hex: "D8CFC2")
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: height)
            .clipped()

            LinearGradient(colors: [Color.clear, Color.black.opacity(0.55)],
                           startPoint: .center, endPoint: .bottom)
                .frame(height: height)

            VStack(alignment: .leading, spacing: 3) {
                Text(tile.eyebrow.uppercased())
                    .font(.system(size: 8, weight: .medium))
                    .tracking(2)
                    .foregroundColor(gold)
                Text(tile.title)
                    .font(.custom("Georgia", size: tile.wide ? 24 : 19))
                    .italic()
                    .foregroundColor(.white)
                    .lineLimit(1)
            }
            .padding(14)
        }
        .frame(height: height)
    }
}

// MARK: - Category Tile Model
struct CategoryTile: Identifiable {
    let id = UUID()
    let title: String
    let category: String
    let eyebrow: String
    let image: String
    let wide: Bool
}

// MARK: - CATEGORY PRODUCTS (filtered list)
struct CategoryProductsView: View {
    let categoryTitle: String
    let category: String

    @StateObject private var service = ProductService()
    @State private var isLoading = true

    private let inkBlack = Color(hex: "1A1A1A")
    private let goldTan = Color(hex: "8B7355")
    private let sandBg = Color(hex: "FAFAF8")

    private let columns = [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)]

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
                    }
                    .padding(.horizontal, 18).padding(.top, 14).padding(.bottom, 4)

                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(service.products) { product in
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
