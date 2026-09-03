import SwiftUI

struct CartItem: Identifiable, Codable {
    let id: UUID
    let product: Product
    var quantity: Int
    var selectedSize: String

    init(product: Product, quantity: Int = 1, size: String = "M") {
        self.id = UUID()
        self.product = product
        self.quantity = quantity
        self.selectedSize = size
    }
}

// MARK: - Shapes returned by GET /api/cart
private struct ServerCart: Decodable {
    let items: [ServerCartItem]
}

private struct ServerCartItem: Decodable {
    /// nil when the product was deleted after being added to the cart
    let product: Product?
    let size: String?
    let quantity: Int?
}

class CartStore: ObservableObject {
    static let shared = CartStore()

    @Published var items: [CartItem] = []
    @Published var isSyncing = false

    private let baseURL = "https://abbayah-backend.onrender.com/api/cart"

    var totalItems: Int { items.reduce(0) { $0 + $1.quantity } }

    /// Uses displayPrice so discounted items are counted at the price the
    /// customer actually sees — and the price the backend will charge.
    var totalPrice: Double {
        items.reduce(0) { $0 + ($1.product.displayPrice * Double($1.quantity)) }
    }

    var isEmpty: Bool { items.isEmpty }

    // MARK: - Local changes (instant UI, then pushed to the server)

    func add(product: Product, size: String) {
        if let i = items.firstIndex(where: { $0.product.id == product.id && $0.selectedSize == size }) {
            items[i].quantity += 1
        } else {
            items.append(CartItem(product: product, quantity: 1, size: size))
        }
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        pushToServer()
    }

    func remove(item: CartItem) {
        items.removeAll { $0.id == item.id }
        pushToServer()
    }

    func updateQuantity(item: CartItem, delta: Int) {
        guard let i = items.firstIndex(where: { $0.id == item.id }) else { return }
        let newQty = items[i].quantity + delta
        if newQty < 1 { items.remove(at: i) } else { items[i].quantity = newQty }
        pushToServer()
    }

    /// Empties the cart here and on the server (used after an order is placed).
    func clear() {
        items = []
        Task { await clearOnServer() }
    }

    /// Empties only this device — the server cart stays for next sign-in.
    func clearLocalOnly() {
        items = []
    }

    // MARK: - Server sync

    /// Called after sign-in: keeps anything added while signed out,
    /// merges it with whatever is already on the account.
    func mergeAndLoad() async {
        let localItems = items
        await loadFromServer()

        guard !localItems.isEmpty else { return }

        await MainActor.run {
            for local in localItems {
                if let i = items.firstIndex(where: {
                    $0.product.id == local.product.id && $0.selectedSize == local.selectedSize
                }) {
                    items[i].quantity += local.quantity
                } else {
                    items.append(local)
                }
            }
        }
        await syncToServer()
    }

    func loadFromServer() async {
        guard let token = AuthService.shared.token, !token.isEmpty,
              let url = URL(string: baseURL) else { return }

        await MainActor.run { self.isSyncing = true }
        defer { Task { @MainActor in self.isSyncing = false } }

        var req = URLRequest(url: url)
        req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        do {
            let (data, response) = try await URLSession.shared.data(for: req)
            let loadStatus = (response as? HTTPURLResponse)?.statusCode ?? -1
            guard loadStatus == 200 else {
                if loadStatus == 401 {
                    await MainActor.run { AuthService.shared.handleExpiredSession() }
                }
                print("❌ CART LOAD — status \(loadStatus)")
                return
            }

            let cart = try JSONDecoder().decode(ServerCart.self, from: data)
            let rebuilt: [CartItem] = cart.items.compactMap { line in
                guard let product = line.product else { return nil }
                return CartItem(product: product,
                                quantity: line.quantity ?? 1,
                                size: line.size ?? "M")
            }

            await MainActor.run { self.items = rebuilt }
        } catch {
            print("❌ CART LOAD ERROR:", error)
        }
    }

    /// Fire-and-forget wrapper so the UI never waits on the network.
    private func pushToServer() {
        guard AuthService.shared.isLoggedIn else { return }
        Task { await syncToServer() }
    }

    func syncToServer() async {
        guard let token = AuthService.shared.token, !token.isEmpty,
              let url = URL(string: "\(baseURL)/sync") else { return }

        let payload: [[String: Any]] = await MainActor.run {
            items.map { [
                "productId": $0.product.id,
                "quantity": $0.quantity,
                "size": $0.selectedSize
            ] }
        }

        var req = URLRequest(url: url)
        req.httpMethod = "PUT"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        req.httpBody = try? JSONSerialization.data(withJSONObject: ["items": payload])

        do {
            let (_, response) = try await URLSession.shared.data(for: req)
            let status = (response as? HTTPURLResponse)?.statusCode ?? -1
            if status == 401 {
                await MainActor.run { AuthService.shared.handleExpiredSession() }
            } else if status != 200 {
                print("❌ CART SYNC — status \(status)")
            }
        } catch {
            print("❌ CART SYNC ERROR:", error)
        }
    }

    private func clearOnServer() async {
        guard let token = AuthService.shared.token, !token.isEmpty,
              let url = URL(string: baseURL) else { return }

        var req = URLRequest(url: url)
        req.httpMethod = "DELETE"
        req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        _ = try? await URLSession.shared.data(for: req)
    }
}
