import Foundation

struct Quote: Codable {
    
    enum CodingKeys: String, CodingKey {
        case id, protection, quoteApplicationId, selectedProtectionOptions
    }
    
    let id: String
    let protection: Protection
    let quoteApplicationId: String
    
    func priceOffersCount() -> Int {
        return protection.priceOffers.count
    }
    
    func getPriceOffers() -> [PriceOffer] {
        return protection.priceOffers
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        protection = try container.decode(Protection.self, forKey: .protection)
        quoteApplicationId = try container.decode(String.self, forKey: .quoteApplicationId)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(protection, forKey: .protection)
        try container.encode(quoteApplicationId, forKey: .quoteApplicationId)
    }
}
