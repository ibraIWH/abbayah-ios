import SwiftUI

struct FavouriteItem: Decodable {
    let id: String
    let product: Product
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case product
    }
}

class FavouritesService: ObservableObject {
    static let shared = FavouritesService()

    @Published var products: [Product] = []
    @Published var favouriteIds: Set<String> = []
    @Published var isLoading = false

    private let baseURL = "https://abbayah-backend.onrender.com/api/favourites"

    private func authedRequest(path: String = "", method: String) -> URLRequest? {
        guard let url = URL(string: baseURL + path) else { return nil }
        var req = URLRequest(url: url)
        req.httpMethod = method
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if let token = AuthService.shared.token {
            req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        return req
    }

    func fetch() async {
        await MainActor.run { isLoading = true }
        guard let req = authedRequest(method: "GET") else { return }
        do {
            let (data, _) = try await URLSession.shared.data(for: req)
            let items = try JSONDecoder().decode([FavouriteItem].self, from: data)
            let fetched = items.map { $0.product }
            await MainActor.run {
                self.products = fetched
                self.favouriteIds = Set(fetched.map { $0.id })
                self.isLoading = false
            }
        } catch {
            await MainActor.run { isLoading = false }
            print("Favourites fetch error:", error)
        }
    }

    func toggle(product: Product) async {
        let id = product.id
        if favouriteIds.contains(id) {
            guard let req = authedRequest(path: "/\(id)", method: "DELETE") else { return }
            _ = try? await URLSession.shared.data(for: req)
            await MainActor.run {
                favouriteIds.remove(id)
                products.removeAll { $0.id == id }
            }
        } else {
            guard var req = authedRequest(method: "POST") else { return }
            req.httpBody = try? JSONSerialization.data(withJSONObject: ["productId": id])
            _ = try? await URLSession.shared.data(for: req)
            await MainActor.run {
                favouriteIds.insert(id)
                products.append(product)
            }
        }
        await MainActor.run {
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                }
    }

    func isFavourite(_ id: String) -> Bool { favouriteIds.contains(id) }
}
