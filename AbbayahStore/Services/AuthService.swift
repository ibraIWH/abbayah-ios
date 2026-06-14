import Foundation

// MARK: - Response Models
struct AuthResponse: Codable {
    let token: String
    let user: AuthUser
}

struct AuthUser: Codable {
    let id: String
    let name: String
    let email: String
    let role: String

    enum CodingKeys: String, CodingKey {
        case id = "id"
        case name, email, role
    }
}

// MARK: - Auth Service
class AuthService: ObservableObject {
    static let shared = AuthService()

    private let baseURL = "https://abbayah-backend.onrender.com/api/auth"

    @Published var currentUser: AuthUser? = nil
    @Published var isLoggedIn: Bool = false

    init() {
        // Load saved user on app start
        if let data = UserDefaults.standard.data(forKey: "abyr_user"),
           let user = try? JSONDecoder().decode(AuthUser.self, from: data) {
            self.currentUser = user
            self.isLoggedIn = true
        }
    }

    // MARK: - Register
    func register(name: String, email: String, password: String) async throws -> AuthResponse {
        let url = URL(string: "\(baseURL)/register")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: [
            "name": name,
            "email": email,
            "password": password
        ])

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let http = response as? HTTPURLResponse else {
            throw AuthError.networkError
        }

        if http.statusCode == 409 {
            throw AuthError.emailTaken
        }

        guard http.statusCode == 201 else {
            if let body = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let message = body["message"] as? String {
                throw AuthError.serverError(message)
            }
            throw AuthError.serverError("Registration failed")
        }

        let authResponse = try JSONDecoder().decode(AuthResponse.self, from: data)
        saveSession(authResponse)
        return authResponse
    }

    // MARK: - Login
    func login(email: String, password: String) async throws -> AuthResponse {
        let url = URL(string: "\(baseURL)/login")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: [
            "email": email,
            "password": password
        ])

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let http = response as? HTTPURLResponse else {
            throw AuthError.networkError
        }

        guard http.statusCode == 200 else {
            throw AuthError.invalidCredentials
        }

        let authResponse = try JSONDecoder().decode(AuthResponse.self, from: data)
        saveSession(authResponse)
        return authResponse
    }

    // MARK: - Sign Out
    func signOut() {
        UserDefaults.standard.removeObject(forKey: "abyr_token")
        UserDefaults.standard.removeObject(forKey: "abyr_user")
        DispatchQueue.main.async {
            self.currentUser = nil
            self.isLoggedIn = false
        }
    }

    // MARK: - Token
    var token: String? {
        UserDefaults.standard.string(forKey: "abyr_token")
    }

    // MARK: - Save Session
    private func saveSession(_ response: AuthResponse) {
        UserDefaults.standard.set(response.token, forKey: "abyr_token")
        if let userData = try? JSONEncoder().encode(response.user) {
            UserDefaults.standard.set(userData, forKey: "abyr_user")
        }
        DispatchQueue.main.async {
            self.currentUser = response.user
            self.isLoggedIn = true
        }
    }
}

// MARK: - Errors
enum AuthError: LocalizedError {
    case networkError
    case invalidCredentials
    case emailTaken
    case serverError(String)

    var errorDescription: String? {
        switch self {
        case .networkError: return "Network error. Please try again."
        case .invalidCredentials: return "Invalid email or password."
        case .emailTaken: return "This email is already registered."
        case .serverError(let msg): return msg
        }
    }
}
