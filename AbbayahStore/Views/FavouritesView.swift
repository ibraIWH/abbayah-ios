import SwiftUI

struct FavouritesView: View {
    @EnvironmentObject private var auth: AuthService
    @EnvironmentObject private var favourites: FavouritesService

    private let inkBlack = Color(hex: "1A1A1A")
    private let goldTan = Color(hex: "8B7355")
    private let sandBg = Color(hex: "FAFAF8")

    var body: some View {
        ZStack {
            sandBg.ignoresSafeArea()

            if !auth.isLoggedIn {
                emptyState(icon: "heart", title: "Sign In to View Favourites", subtitle: "Save pieces you love\nand find them here.")
            } else if favourites.isLoading {
                ScrollView(showsIndicators: false) {
                    LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)], spacing: 16) {
                        ForEach(0..<4, id: \.self) { _ in SkeletonCard() }
                    }
                    .padding(.horizontal, 20).padding(.top, 16)
                }
            } else if favourites.products.isEmpty {
                emptyState(icon: "heart", title: "No Favourites Yet", subtitle: "Tap the heart on any product\nto save it here.")
            } else {
                ScrollView(showsIndicators: false) {
                    HStack {
                        Text("\(favourites.products.count) pieces saved")
                            .font(.system(size: 10)).foregroundColor(.secondary)
                        Spacer()
                    }
                    .padding(.horizontal, 20).padding(.top, 16).padding(.bottom, 8)

                    LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)], spacing: 16) {
                        ForEach(favourites.products) { product in
                            NavigationLink { ProductDetailView(product: product) } label: {
                                HniProductCard(product: product)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 20)
                    Color.clear.frame(height: 100)
                }
                .refreshable { await favourites.fetch() }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Image("AbyrLogoDark")
                    .resizable().renderingMode(.original).scaledToFit()
                    .frame(width: 160).scaleEffect(1.5)
            }
        }
        .task {
            if auth.isLoggedIn { await favourites.fetch() }
        }
    }

    private func emptyState(icon: String, title: String, subtitle: String) -> some View {
        VStack(spacing: 20) {
            Spacer()
            Image(systemName: icon).font(.system(size: 52)).foregroundColor(goldTan.opacity(0.3))
            Text(title).font(.custom("Georgia", size: 24)).italic().foregroundColor(inkBlack)
            Text(subtitle).font(.system(size: 12)).foregroundColor(.secondary)
                .multilineTextAlignment(.center).lineSpacing(4)
            Spacer()
        }
    }
}
