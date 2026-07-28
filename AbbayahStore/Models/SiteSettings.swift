import Foundation

struct SiteSettings: Codable, Equatable {
    let hero: Hero?
    let newsText: String?
    let newsActive: Bool?

    struct Hero: Codable, Equatable {
        let eyebrow: String?
        let title: String?
        let subtitle: String?
        let imageUrl: String?
        let ctaText: String?
        let ctaLink: String?
    }
}
