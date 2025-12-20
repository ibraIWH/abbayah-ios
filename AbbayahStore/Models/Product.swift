struct Product: Identifiable, Codable, Equatable {
    let id: String
    let name: String
    let price: Double
    let imageUrl: String
    let category: String
    let description: String?

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case name
        case price
        case imageUrl
        case category
        case description
    }
}
