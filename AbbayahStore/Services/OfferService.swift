import Foundation

class OfferService: ObservableObject {
    @Published var offers: [Offer] = []
    @Published var isLoading = false

    func fetchOffers() async {
        await MainActor.run { self.isLoading = true }

        let urlString = "https://abbayah-backend.onrender.com/api/offers"

        guard let url = URL(string: urlString) else {
            print("❌ BAD URL:", urlString)
            await MainActor.run { self.isLoading = false }
            return
        }

        do {
            var request = URLRequest(url: url)
            request.cachePolicy = .reloadIgnoringLocalCacheData
            let (data, _) = try await URLSession.shared.data(for: request)
            let decoded = try JSONDecoder().decode([Offer].self, from: data)

            await MainActor.run {
                self.offers = decoded
                self.isLoading = false
            }
        } catch {
            await MainActor.run { self.isLoading = false }
            print("❌ OFFERS API ERROR:", error)
        }
    }
}
