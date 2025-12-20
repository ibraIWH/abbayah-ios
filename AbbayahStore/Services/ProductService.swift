import Foundation

class ProductService: ObservableObject {
    @Published var products: [Product] = []
    @Published var isLoading = false
    
    func fetchProducts(category: String = "All", search: String = "") async {
        
        await MainActor.run { self.isLoading = true }
        
        // 🔴 USE YOUR DEPLOYED BACKEND
        var urlString = "https://abbayah-backend.onrender.com/api/products?"

        // Category filter
        if category != "All" {
            let encoded = category.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? category
            urlString += "category=\(encoded)&"
        }
        
        // Search filter
        if !search.isEmpty {
            let encodedSearch = search.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? search
            urlString += "search=\(encodedSearch)&"
        }

        // Clean URL
        urlString = urlString.trimmingCharacters(in: CharacterSet(charactersIn: "&?"))

        guard let url = URL(string: urlString) else {
            print("❌ BAD URL:", urlString)
            return
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let decoded = try JSONDecoder().decode([Product].self, from: data)
            
            await MainActor.run {
                self.products = decoded
                self.isLoading = false
            }
        } catch {
            await MainActor.run { self.isLoading = false }
            print("❌ SEARCH API ERROR:", error)
        }
    }
}
