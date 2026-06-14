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

class CartStore: ObservableObject {
    static let shared = CartStore()

    @Published var items: [CartItem] = []

    var totalItems: Int { items.reduce(0) { $0 + $1.quantity } }
    var totalPrice: Double { items.reduce(0) { $0 + ($1.product.price * Double($1.quantity)) } }
    var isEmpty: Bool { items.isEmpty }

    func add(product: Product, size: String) {
        if let i = items.firstIndex(where: { $0.product.id == product.id && $0.selectedSize == size }) {
            items[i].quantity += 1
        } else {
            items.append(CartItem(product: product, quantity: 1, size: size))
        }
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }

    func remove(item: CartItem) {
        items.removeAll { $0.id == item.id }
    }

    func updateQuantity(item: CartItem, delta: Int) {
        guard let i = items.firstIndex(where: { $0.id == item.id }) else { return }
        let newQty = items[i].quantity + delta
        if newQty < 1 { items.remove(at: i) } else { items[i].quantity = newQty }
    }

    func clear() { items = [] }
}
