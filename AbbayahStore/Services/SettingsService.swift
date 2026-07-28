import Foundation

class SettingsService: ObservableObject {
    @Published var settings: SiteSettings?
    @Published var isLoading = false

    func fetchSettings() async {
        await MainActor.run { self.isLoading = true }

        let urlString = "https://abbayah-backend.onrender.com/api/settings"

        guard let url = URL(string: urlString) else {
            print("❌ BAD URL:", urlString)
            await MainActor.run { self.isLoading = false }
            return
        }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let decoded = try JSONDecoder().decode(SiteSettings.self, from: data)

            await MainActor.run {
                self.settings = decoded
                self.isLoading = false
            }
        } catch {
            await MainActor.run { self.isLoading = false }
            print("❌ SETTINGS API ERROR:", error)
        }
    }
}
