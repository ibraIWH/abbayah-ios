import SwiftUI

struct ProductCard: View {
    let product: Product
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {

            AsyncImage(url: URL(string: product.imageUrl)) { image in
                image
                    .resizable()
                    .scaledToFill()
            } placeholder: {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(.systemGray6))
            }
            .frame(maxWidth: 150)
            .frame(height: 200)
            .clipped()

            Text(product.name)
                .font(.headline)
                .lineLimit(1)

            Text("SAR \(product.price, specifier: "%.0f")")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(10)
        .frame(maxWidth: 200)
        .frame(height: 300)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(
                    colorScheme == .dark
                    ? AnyShapeStyle(.ultraThinMaterial)   // 🌙 glass
                    : AnyShapeStyle(Color(.systemBackground)) // ☀️ solid
                )
        )
        .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 4)
    }
}
