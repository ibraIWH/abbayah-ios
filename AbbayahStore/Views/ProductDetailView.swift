import SwiftUI

struct ProductDetailView: View {
    let product: Product
    @Environment(\.colorScheme) private var colorScheme
    @State private var selectedSize: String = "M"
    @State private var isFavourite: Bool = false

    // MARK: - Design Tokens
    private let inkBlack = Color(hex: "1A1A1A")
    private let warmCream = Color(hex: "F5F0E8")
    private let goldTan = Color(hex: "8B7355")
    private let sandBg = Color(hex: "FAFAF8")
    private let borderColor = Color(hex: "E8E8E4")

    private let sizes = ["XS", "S", "M", "L", "XL"]

    var body: some View {
        ZStack(alignment: .bottom) {
            sandBg.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {

                    // ── HERO IMAGE ──────────────────────
                    ZStack(alignment: .topTrailing) {
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
                                        .font(.system(size: 40))
                                        .foregroundColor(Color(hex: "C4A882").opacity(0.4))
                                }
                            @unknown default:
                                Color(hex: "EDE8E0")
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 420)
                        .clipped()

                        // Favourite button
                        Button {
                            isFavourite.toggle()
                        } label: {
                            Image(systemName: isFavourite ? "heart.fill" : "heart")
                                .font(.system(size: 16))
                                .foregroundColor(isFavourite ? .red : .white)
                                .padding(10)
                                .background(Color.black.opacity(0.3))
                                .clipShape(Circle())
                        }
                        .padding(16)
                    }

                    // ── PRODUCT INFO ────────────────────
                    VStack(alignment: .leading, spacing: 0) {

                        // Category + Name + Price
                        HStack(alignment: .top) {
                            VStack(alignment: .leading, spacing: 6) {
                                Text(product.category.uppercased())
                                    .font(.system(size: 9, weight: .medium))
                                    .tracking(2)
                                    .foregroundColor(goldTan)

                                Text(product.name)
                                    .font(.custom("Georgia", size: 24))
                                    .italic()
                                    .foregroundColor(inkBlack)
                                    .lineLimit(2)
                            }
                            Spacer()
                            Text("SAR \(product.price, specifier: "%.2f")")
                                .font(.custom("Georgia", size: 22))
                                .italic()
                                .foregroundColor(goldTan)
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                        .padding(.bottom, 16)

                        // Divider
                        Rectangle()
                            .frame(height: 0.5)
                            .foregroundColor(borderColor)
                            .padding(.horizontal, 20)

                        // Size selector
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("SIZE")
                                    .font(.system(size: 9, weight: .medium))
                                    .tracking(2)
                                    .foregroundColor(.secondary)
                                Spacer()
                                Text("Size Guide")
                                    .font(.system(size: 10))
                                    .foregroundColor(goldTan)
                                    .underline()
                            }

                            HStack(spacing: 8) {
                                ForEach(sizes, id: \.self) { size in
                                    Button {
                                        selectedSize = size
                                    } label: {
                                        Text(size)
                                            .font(.system(size: 11, weight: .medium))
                                            .frame(width: 44, height: 44)
                                            .background(
                                                selectedSize == size
                                                ? inkBlack
                                                : Color.clear
                                            )
                                            .foregroundColor(
                                                selectedSize == size
                                                ? warmCream
                                                : inkBlack
                                            )
                                            .overlay(
                                                Rectangle()
                                                    .stroke(
                                                        selectedSize == size
                                                        ? inkBlack
                                                        : borderColor,
                                                        lineWidth: 0.5
                                                    )
                                            )
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 16)

                        // Divider
                        Rectangle()
                            .frame(height: 0.5)
                            .foregroundColor(borderColor)
                            .padding(.horizontal, 20)

                        // Description
                        VStack(alignment: .leading, spacing: 8) {
                            Text("DESCRIPTION")
                                .font(.system(size: 9, weight: .medium))
                                .tracking(2)
                                .foregroundColor(.secondary)

                            Text(product.description ?? "A beautifully crafted piece from the Abyr Line collection.")
                                .font(.system(size: 13))
                                .foregroundColor(Color.gray.opacity(0.8))
                                .lineSpacing(6)
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 16)

                        // Divider
                        Rectangle()
                            .frame(height: 0.5)
                            .foregroundColor(borderColor)
                            .padding(.horizontal, 20)

                        // Delivery info
                        VStack(alignment: .leading, spacing: 12) {
                            deliveryRow(
                                icon: "shippingbox",
                                title: "Free Delivery",
                                subtitle: "On orders over SAR 200"
                            )
                            deliveryRow(
                                icon: "arrow.uturn.left",
                                title: "Free Returns",
                                subtitle: "Within 14 days"
                            )
                            deliveryRow(
                                icon: "storefront",
                                title: "Click & Collect",
                                subtitle: "Available in Riyadh"
                            )
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 16)

                        // Bottom spacer for CTA button
                        Color.clear.frame(height: 100)
                    }
                }
            }

            // ── STICKY CTA ──────────────────────────
            VStack(spacing: 0) {
                Rectangle()
                    .frame(height: 0.5)
                    .foregroundColor(borderColor)

                HStack(spacing: 12) {
                    // Add to Favourites
                    Button {
                        isFavourite.toggle()
                    } label: {
                        Image(systemName: isFavourite ? "heart.fill" : "heart")
                            .font(.system(size: 18))
                            .foregroundColor(inkBlack)
                            .frame(width: 52, height: 52)
                            .overlay(
                                Rectangle()
                                    .stroke(borderColor, lineWidth: 0.5)
                            )
                    }
                    .buttonStyle(.plain)

                    // Add to Cart
                    Button {
                        // TODO: add to cart
                    } label: {
                        Text("ADD TO CART")
                            .font(.system(size: 11, weight: .medium))
                            .tracking(3)
                            .foregroundColor(warmCream)
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)
                            .background(inkBlack)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .padding(.bottom, 24)
                .background(
                    Color(UIColor.systemBackground)
                        .ignoresSafeArea(edges: .bottom)
                )
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Image("AbyrLogoDark")
                    .resizable()
                    .renderingMode(.original)
                    .scaledToFit()
                    .frame(width: 100)
                    .scaleEffect(1.5)
            }
        }
    }

    // MARK: - Delivery Row
    private func deliveryRow(icon: String, title: String, subtitle: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(goldTan)
                .frame(width: 20)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(inkBlack)
                Text(subtitle)
                    .font(.system(size: 10))
                    .foregroundColor(.secondary)
            }
        }
    }
}

