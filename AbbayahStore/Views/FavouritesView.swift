import SwiftUI

struct FavouritesView: View {
    private let inkBlack = Color(hex: "1A1A1A")
    private let goldTan = Color(hex: "8B7355")
    private let sandBg = Color(hex: "FAFAF8")
    private let borderColor = Color(hex: "E8E8E4")
    private let warmCream = Color(hex: "F5F0E8")

    // Placeholder — will be replaced with real favourites from backend after auth
    let products: [Product] = []

    var body: some View {
        ZStack {
            sandBg.ignoresSafeArea()

            if products.isEmpty {
                VStack(spacing: 20) {
                    Image(systemName: "heart")
                        .font(.system(size: 52))
                        .foregroundColor(goldTan.opacity(0.4))
                    Text("No Favourites Yet")
                        .font(.custom("Georgia", size: 24))
                        .italic()
                        .foregroundColor(inkBlack)
                    Text("Tap the heart on any product\nto save it here.")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                }
            } else {
                ScrollView(showsIndicators: false) {
                    LazyVGrid(
                        columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)],
                        spacing: 16
                    ) {
                        ForEach(products) { product in
                            NavigationLink { ProductDetailView(product: product) } label: {
                                HniProductCard(product: product)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    Color.clear.frame(height: 100)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Image("AbyrLogoDark")
                    .resizable()
                    .renderingMode(.original)
                    .scaledToFit()
                    .frame(width: 160)
                    .scaleEffect(1.5)
            }
        }
    }
}
