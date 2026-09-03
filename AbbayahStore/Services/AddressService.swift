import Foundation

// Matches the address subdocument on the backend User model.
struct Address: Identifiable, Codable, Equatable {
    let id: String
    var name: String
    var line1: String
    var city: String
    var phone: String?
    var isDefault: Bool?

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case name, line1, city, phone, isDefault
    }
}

@MainActor
class AddressService: ObservableObject {
    static let shared = AddressService()

    @Published var addresses: [Address] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let baseURL = "https://abbayah-backend.onrender.com/api/addresses"

    private func request(_ path: String = "", method: String) -> URLRequest? {
        guard let token = AuthService.shared.token, !token.isEmpty,
              let url = URL(string: baseURL + path) else { return nil }
        var req = URLRequest(url: url)
        req.httpMethod = method
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return req
    }

    /// Every write endpoint returns the full updated list, so they all funnel here.
    private func run(_ req: URLRequest) async -> Bool {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        do {
            let (data, response) = try await URLSession.shared.data(for: req)
            let status = (response as? HTTPURLResponse)?.statusCode ?? -1
            guard (200...299).contains(status) else {
                if status == 401 {
                    AuthService.shared.handleExpiredSession()
                    errorMessage = "Your session expired. Please sign in again."
                    return false
                }
                if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                    errorMessage = json["message"] as? String ?? "Something went wrong."
                }
                print("❌ ADDRESS \(req.httpMethod ?? "") — status \(status)")
                return false
            }
            let list = try JSONDecoder().decode([Address].self, from: data)
            self.addresses = list
            return true
        } catch {
            errorMessage = "Network error. Please try again."
            print("❌ ADDRESS ERROR:", error)
            return false
        }
    }

    func fetch() async {
        guard let req = request(method: "GET") else { return }
        _ = await run(req)
    }

    @discardableResult
    func add(name: String, line1: String, city: String, phone: String, isDefault: Bool) async -> Bool {
        guard var req = request(method: "POST") else { return false }
        req.httpBody = try? JSONSerialization.data(withJSONObject: [
            "name": name, "line1": line1, "city": city,
            "phone": phone, "isDefault": isDefault
        ])
        return await run(req)
    }

    @discardableResult
    func update(id: String, name: String, line1: String, city: String, phone: String, isDefault: Bool) async -> Bool {
        guard var req = request("/\(id)", method: "PUT") else { return false }
        req.httpBody = try? JSONSerialization.data(withJSONObject: [
            "name": name, "line1": line1, "city": city,
            "phone": phone, "isDefault": isDefault
        ])
        return await run(req)
    }

    @discardableResult
    func setDefault(id: String) async -> Bool {
        guard var req = request("/\(id)", method: "PUT") else { return false }
        req.httpBody = try? JSONSerialization.data(withJSONObject: ["isDefault": true])
        return await run(req)
    }

    @discardableResult
    func delete(id: String) async -> Bool {
        guard let req = request("/\(id)", method: "DELETE") else { return false }
        return await run(req)
    }

    func clearLocal() {
        addresses = []
    }
}
