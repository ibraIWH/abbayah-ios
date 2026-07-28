import SwiftUI

struct CreatedOrder: Decodable {
    let orderNumber: String
    let total: Double
}

// Full order from the backend
struct Order: Identifiable, Decodable, Hashable {
    let id: String
    let orderNumber: String
    let items: [OrderLineItem]
    let shippingAddress: ShippingAddress
    let subtotal: Double
    let deliveryFee: Double
    let total: Double
    let status: String
    let createdAt: String

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case orderNumber, items, shippingAddress, subtotal, deliveryFee, total, status, createdAt
    }

    static func == (lhs: Order, rhs: Order) -> Bool { lhs.id == rhs.id }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
}

struct OrderLineItem: Decodable, Hashable {
    let name: String
    let price: Double
    let imageUrl: String
    let size: String
    let quantity: Int
}

struct ShippingAddress: Decodable, Hashable {
    let name: String
    let line1: String
    let city: String
    let phone: String
}

enum OrderError: LocalizedError {
    case notSignedIn
    case server(status: Int, message: String)

    var errorDescription: String? {
        switch self {
        case .notSignedIn:
            return "You're not signed in. Please sign in and try again."
        case .server(let status, let message):
            switch status {
            case 401:
                return "Your session expired. Please sign out and sign in again."
            case 400:
                return message.isEmpty ? "Some order details are missing." : message
            case 404:
                return "A product in your cart is no longer available."
            default:
                return message.isEmpty ? "Server error (\(status)). Please try again." : message
            }
        }
    }
}

class OrderService: ObservableObject {
    static let shared = OrderService()

    private let baseURL = "https://abbayah-backend.onrender.com/api/orders"

    // MARK: - Place an order
    func placeOrder(items: [CartItem], name: String, line1: String, city: String, phone: String) async throws -> CreatedOrder {
        guard let url = URL(string: baseURL) else { throw URLError(.badURL) }
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        guard let token = AuthService.shared.token, !token.isEmpty else {
            throw OrderError.notSignedIn
        }
        req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let itemsPayload = items.map { item in
            return [
                "productId": item.product.id,
                "quantity": item.quantity,
                "size": item.selectedSize
            ] as [String: Any]
        }

        let body: [String: Any] = [
            "items": itemsPayload,
            "shippingAddress": [
                "name": name,
                "line1": line1,
                "city": city,
                "phone": phone
            ],
            "paymentMethod": "cod"
        ]
        req.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await URLSession.shared.data(for: req)
        let status = (response as? HTTPURLResponse)?.statusCode ?? -1

        guard status == 201 else {
            // Pull the backend's own { "message": ... } so we see the real reason
            var serverMessage = ""
            if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                serverMessage = (json["message"] as? String) ?? (json["error"] as? String) ?? ""
            }
            print("❌ PLACE ORDER FAILED — status \(status): \(serverMessage)")
            print("❌ RAW RESPONSE:", String(data: data, encoding: .utf8) ?? "none")
            throw OrderError.server(status: status, message: serverMessage)
        }
        return try JSONDecoder().decode(CreatedOrder.self, from: data)
    }

    // MARK: - Fetch my orders
    func fetchOrders() async throws -> [Order] {
        guard let url = URL(string: baseURL) else { throw URLError(.badURL) }
        var req = URLRequest(url: url)
        req.httpMethod = "GET"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if let token = AuthService.shared.token {
            req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        let (data, response) = try await URLSession.shared.data(for: req)
        guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        return try JSONDecoder().decode([Order].self, from: data)
    }
}
