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
        guard http.statusCode == 201 || http.statusCode == 200 else {
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

        if http.statusCode == 401 {
            throw AuthError.invalidCredentials
        }
        guard http.statusCode == 200 else {
            throw AuthError.serverError("Login failed")
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
            CartStore.shared.clearLocalOnly()
            AddressService.shared.clearLocal()
            NotificationService.shared.clearLocal()
        }
    }

    /// Called by any service that receives a 401 — the token expired or is
    /// invalid, so the saved "logged in" state is a lie. Clear it and flip the
    /// app back to signed-out so the user is prompted to sign in again.
    func handleExpiredSession() {
        guard isLoggedIn else { return }
        print("⚠️ Session expired (401) — signing out")
        signOut()
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
            Task { await CartStore.shared.mergeAndLoad() }
            NotificationService.shared.startPolling()
        }
    }

    // MARK: - Update Profile
    func updateProfile(name: String, email: String, phone: String) async throws -> AuthUser {
        guard let token = token, !token.isEmpty else { throw AuthError.networkError }
        let url = URL(string: "\(baseURL)/profile")!
        var req = URLRequest(url: url)
        req.httpMethod = "PUT"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        req.httpBody = try JSONSerialization.data(withJSONObject: [
            "name": name, "email": email, "phone": phone
        ])

        let (data, response) = try await URLSession.shared.data(for: req)
        let status = (response as? HTTPURLResponse)?.statusCode ?? -1

        if status == 409 { throw AuthError.emailTaken }
        guard status == 200 else {
            if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let msg = json["message"] as? String {
                throw AuthError.custom(msg)
            }
            throw AuthError.networkError
        }

        let updated = try JSONDecoder().decode(AuthUser.self, from: data)
        await MainActor.run {
            self.currentUser = updated
            if let userData = try? JSONEncoder().encode(updated) {
                UserDefaults.standard.set(userData, forKey: "abyr_user")
            }
        }
        return updated
    }

    // MARK: - Change Password
    func changePassword(current: String, newPassword: String) async throws {
        guard let token = token, !token.isEmpty else { throw AuthError.networkError }
        let url = URL(string: "\(baseURL)/password")!
        var req = URLRequest(url: url)
        req.httpMethod = "PUT"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        req.httpBody = try JSONSerialization.data(withJSONObject: [
            "currentPassword": current, "newPassword": newPassword
        ])

        let (data, response) = try await URLSession.shared.data(for: req)
        let status = (response as? HTTPURLResponse)?.statusCode ?? -1

        guard status == 200 else {
            if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let msg = json["message"] as? String {
                throw AuthError.custom(msg)
            }
            if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let errs = json["errors"] as? [[String: Any]],
               let first = errs.first?["msg"] as? String {
                throw AuthError.custom(first)
            }
            throw AuthError.networkError
        }
    }
}

// MARK: - Errors
enum AuthError: LocalizedError {
    case custom(String)
    case networkError
    case invalidCredentials
    case emailTaken
    case serverError(String)

    var errorDescription: String? {
        switch self {
        case .custom(let msg): return msg
        case .networkError: return "Network error. Please try again."
        case .invalidCredentials: return "Invalid email or password."
        case .emailTaken: return "That email is already registered."
        case .serverError(let msg): return msg
        }
    }
}
