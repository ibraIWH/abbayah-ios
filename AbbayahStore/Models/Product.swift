import Foundation

struct Product: Identifiable, Codable, Equatable {
    let id: String
    let name: String
    let price: Double
    let salePrice: Double?
    let imageUrl: String
    let imageUrl2: String?
    let category: String
    let description: String?
    let stock: Int?
    let sizes: [String]?
    let colors: [ProductColor]?

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case name, price, salePrice, imageUrl, imageUrl2
        case category, description, stock, sizes, colors
    }

    var isOnSale: Bool { salePrice != nil }
    var isSoldOut: Bool { (stock ?? 1) == 0 }
    var displayPrice: Double { salePrice ?? price }
}

struct ProductColor: Codable, Equatable {
    let name: String
    let hex: String
    let imageUrl: String?
}
