import Foundation

struct SiteSettings: Codable, Equatable {
    let hero: Hero?
    let newsText: String?
    let newsActive: Bool?
    let promo: Promo?
    let payment: Payment?

    struct Hero: Codable, Equatable {
        let eyebrow: String?
        let title: String?
        let subtitle: String?
        let imageUrl: String?
        let ctaText: String?
        let ctaLink: String?
    }

    struct Promo: Codable, Equatable {
        let code: String?
        let line1: String?
        let line2: String?
        let subtitle: String?
        let active: Bool?
    }

    // Mobile-money numbers the customer sends payment to (Zaad / eDahab).
    struct Payment: Codable, Equatable {
        let zaadNumber: String?
        let edahabNumber: String?
        let note: String?
    }
}
