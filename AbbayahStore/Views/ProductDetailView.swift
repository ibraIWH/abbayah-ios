import SwiftUI

struct ProductDetailView: View {
    let product: Product
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                
                // Image
                AsyncImage(url: URL(string: product.imageUrl)) { image in
                    image
                        .resizable()
                        .scaledToFit()
                } placeholder: {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color(.systemGray6))
                }
                .frame(maxWidth: .infinity)
                .background(Color(.systemGray6))
                
                // Title & price
                VStack(alignment: .leading, spacing: 8) {
                    Text(product.name)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("SAR \(product.price, specifier: "%.0f")")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                }
                
                Divider()
                
                // Description
                VStack(alignment: .leading, spacing: 6) {
                    Text("Description")
                        .font(.headline)
                    
                    Text(product.category)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text(product.description ?? "No description available.")
                        .font(.body)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Add to Cart Button
                Button {
                    // later: add to cart
                } label: {
                    Text("Add to Cart")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.black)
                        .cornerRadius(12)
                }
            }
            .padding()
        }
        .navigationTitle("Details")
        .navigationBarTitleDisplayMode(.inline)
        .background(.ultraThinMaterial)
    }
}
