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
    private let tileHeight: CGFloat = 210

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
                        .padding(.top, 8)
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
                                ProductBrowseView(initialCategory: "All", showSearchBar: false, showCategoryChips: false, navTitle: "All Products")
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
                        LazyVGrid(columns: columns, spacing: 12) {
                            NavigationLink {
                                ProductBrowseView(initialCategory: "All", showSearchBar: false, showCategoryChips: false, navTitle: "All Products")
                            } label: {
                                shopAllTile()
                            }
                            .buttonStyle(.plain)

                            ForEach(collectionService.collections) { cat in
                                NavigationLink {
                                    ProductBrowseView(initialCategory: cat.name, showSearchBar: false, showCategoryChips: false, navTitle: cat.name)
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

    // MARK: - Shop All tile
    private func shopAllTile() -> some View {
        ZStack(alignment: .bottomLeading) {
            LinearGradient(colors: [Color(hex: "3D0608"), Color(hex: "5C0A14")],
                           startPoint: .topLeading, endPoint: .bottomTrailing)

            VStack(alignment: .leading, spacing: 3) {
                Text("EVERYTHING")
                    .font(.system(size: 8, weight: .medium)).tracking(2).foregroundColor(gold)
                Text("Shop All")
                    .font(.custom("Georgia", size: 21)).italic().foregroundColor(.white)
                    .shadow(color: .black.opacity(0.5), radius: 3, x: 0, y: 1)
            }
            .padding(14)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
        }
        .frame(maxWidth: .infinity)
        .frame(height: tileHeight)
        .contentShape(Rectangle())
    }

    // MARK: - Category tile (bulletproof layout)
    //
    // The pattern: a Color.clear of the exact tile size owns the layout,
    // and the AsyncImage is drawn on top with .overlay(). Because the
    // Color.clear is the only thing that determines the layout size,
    // the image can NEVER overflow into neighbouring cells.
    // .clipped() then trims anything that goes past the tile bounds.
    private func categoryTile(name: String, image: String) -> some View {
        let hasImage = !image.trimmingCharacters(in: .whitespaces).isEmpty

        return ZStack(alignment: .bottomLeading) {

            // 1. Fixed-size layout owner + image overlay
            Color.clear
                .frame(maxWidth: .infinity)
                .frame(height: tileHeight)
                .overlay(
                    Group {
                        if hasImage {
                            AsyncImage(url: URL(string: image)) { phase in
                                switch phase {
                                case .success(let img):
                                    img.resizable()
                                        .scaledToFill()
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
                )
                .clipped()

            // 2. Dark gradient for text legibility
            LinearGradient(colors: [Color.clear, Color.black.opacity(0.25), Color.black.opacity(0.75)],
                           startPoint: .top, endPoint: .bottom)
                .frame(maxWidth: .infinity)
                .frame(height: tileHeight)
                .allowsHitTesting(false)

            // 3. Category name
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
                    .shadow(color: .black.opacity(0.6), radius: 4, x: 0, y: 1)
            }
            .padding(14)
        }
        .frame(maxWidth: .infinity)
        .frame(height: tileHeight)
        .contentShape(Rectangle())
    }

    private var brandTile: some View {
        LinearGradient(
            colors: [Color(hex: "6b5444"), Color(hex: "3D0608")],
            startPoint: .topLeading, endPoint: .bottomTrailing
        )
    }
}


// MARK: - CATEGORY PRODUCTS (filtered list)
