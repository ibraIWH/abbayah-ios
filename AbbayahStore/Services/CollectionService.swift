import Foundation

class CollectionService: ObservableObject {
    @Published var collections: [AbyrCollection] = []
    @Published var isLoading = false

    func fetchCollections() async {
        await MainActor.run { self.isLoading = true }

        let urlString = "https://abbayah-backend.onrender.com/api/collections"

        guard let url = URL(string: urlString) else {
            print("❌ BAD URL:", urlString)
            await MainActor.run { self.isLoading = false }
            return
        }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let decoded = try JSONDecoder().decode([AbyrCollection].self, from: data)

            await MainActor.run {
                self.collections = decoded
                self.isLoading = false
            }
        } catch {
            await MainActor.run { self.isLoading = false }
            print("❌ COLLECTIONS API ERROR:", error)
        }
    }
}
