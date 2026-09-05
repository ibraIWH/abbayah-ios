import SwiftUI

struct SearchView: View {
    @StateObject private var service = ProductService()
    @StateObject private var collectionService = CollectionService()
    @State private var searchText = ""
    @State private var selectedCategory = "All"
    @State private var isLoading = false

    // "All" plus the real categories from the backend
    private var categories: [String] {
        ["All"] + collectionService.collections.map { $0.name }
    }
    private let inkBlack = Color(hex: "1A1A1A")
    private let goldTan = Color(hex: "8B7355")
    private let sandBg = Color(hex: "FAFAF8")
    private let borderColor = Color(hex: "E8E8E4")
    private let warmCream = Color(hex: "F5F0E8")

    var body: some View {
        ZStack {
            sandBg.ignoresSafeArea()
            VStack(spacing: 0) {
                // Search bar
                HStack(spacing: 10) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 13))
                        .foregroundColor(Color.gray.opacity(0.5))
                    TextField("Search abayas, jalabiya...", text: $searchText)
                        .font(.system(size: 13))
                        .onSubmit { Task { await search() } }
                    if !searchText.isEmpty {
                        Button { searchText = "" } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(Color.gray.opacity(0.4))
                        }
                    }
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 11)
                .background(Color(hex: "F2F0EB"))
                .padding(.horizontal, 20)
                .padding(.vertical, 14)
                .background(Color.white)

                // Category chips
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(categories, id: \.self) { cat in
                            Button {
                                selectedCategory = cat
                                Task { await search() }
                            } label: {
                                Text(cat.uppercased())
                                    .font(.system(size: 9, weight: .medium))
                                    .tracking(1)
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 7)
                                    .background(selectedCategory == cat ? inkBlack : Color.clear)
                                    .foregroundColor(selectedCategory == cat ? warmCream : Color.gray)
                                    .overlay(Rectangle().stroke(selectedCategory == cat ? inkBlack : borderColor, lineWidth: 0.5))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 20)
                }
                .padding(.vertical, 12)
                .background(Color.white)
                .overlay(Rectangle().frame(height: 0.5).foregroundColor(borderColor), alignment: .bottom)

                // Results
                if isLoading {
                    Spacer()
                    ProgressView().tint(inkBlack)
                    Spacer()
                } else if service.products.isEmpty && !searchText.isEmpty {
                    Spacer()
                    VStack(spacing: 12) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 36))
                            .foregroundColor(goldTan)
                        Text("No results found")
                            .font(.custom("Georgia", size: 18))
                            .italic()
                            .foregroundColor(inkBlack)
                        Text("Try a different search term")
                            .font(.system(size: 11))
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                } else if service.products.isEmpty {
                    Spacer()
                    VStack(spacing: 12) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 36))
                            .foregroundColor(goldTan.opacity(0.4))
                        Text("Search for abayas")
                            .font(.custom("Georgia", size: 18))
                            .italic()
                            .foregroundColor(inkBlack)
                    }
                    Spacer()
                } else {
                    ScrollView(showsIndicators: false) {
                        if !searchText.isEmpty {
                            HStack {
                                Text("\(service.products.count) results for \"\(searchText)\"")
                                    .font(.system(size: 10))
                                    .foregroundColor(.secondary)
                                Spacer()
                            }
                            .padding(.horizontal, 20)
                            .padding(.top, 12)
                        }
                        LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)], spacing: 16) {
                            ForEach(service.products) { product in
                                NavigationLink { ProductDetailView(product: product) } label: {
                                    HniProductCard(product: product)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 8)
                        Color.clear.frame(height: 100)
                    }
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                AbyrNavLogo()
            }
        }
        .task {
            await collectionService.fetchCollections()
            await search()
        }
    }

    private func search() async {
        isLoading = true
        await service.fetchProducts(category: selectedCategory, search: searchText)
        isLoading = false
    }
}
