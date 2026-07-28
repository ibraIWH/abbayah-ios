import Foundation

struct Offer: Identifiable, Codable, Equatable {
    let id: String
    let title: String
    let badgeText: String?
    let subtitle: String?
    let imageUrl: String?
    let link: String?
    let isActive: Bool?
    let order: Int?

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case title, badgeText, subtitle, imageUrl, link, isActive, order
    }
}
