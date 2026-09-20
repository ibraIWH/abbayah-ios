import Foundation

class OfferService: ObservableObject {
    @Published var offers: [Offer] = []
    @Published var isLoading = false

    // Ephemeral session — no disk cache, no memory cache.
    // Every fetch hits the network for real.
    private let session: URLSession = {
        let config = URLSessionConfiguration.ephemeral
        config.requestCachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        config.urlCache = nil
        return URLSession(configuration: config)
    }()

    func fetchOffers() async {
        print("🌐 OFFERS fetch start")
        await MainActor.run { self.isLoading = true }

        // Cache-buster — the URL itself is unique on every call
        let t = Int(Date().timeIntervalSince1970)
        let urlString = "https://abbayah-backend.onrender.com/api/offers?t=\(t)"

        guard let url = URL(string: urlString) else {
            print("❌ OFFERS bad URL")
            await MainActor.run { self.isLoading = false }
            return
        }

        do {
            var request = URLRequest(url: url)
            request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
            let (data, response) = try await session.data(for: request)
            let status = (response as? HTTPURLResponse)?.statusCode ?? -1
            print("🌐 OFFERS HTTP \(status) — \(data.count) bytes")

            let decoded = try JSONDecoder().decode([Offer].self, from: data)
            print("🌐 OFFERS decoded \(decoded.count) offers")

            await MainActor.run {
                self.offers = decoded
                self.isLoading = false
                print("🌐 OFFERS state updated → \(decoded.count) offers in memory")
            }
        } catch {
            await MainActor.run { self.isLoading = false }
            print("❌ OFFERS error: \(error)")
        }
    }
}
