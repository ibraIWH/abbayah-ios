import Foundation

struct AbyrCollection: Identifiable, Codable, Equatable {
    let id: String
    let name: String
    let slug: String?
    let imageUrl: String?
    let description: String?
    let isActive: Bool?
    let order: Int?

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case name, slug, imageUrl, description, isActive, order
    }
}
