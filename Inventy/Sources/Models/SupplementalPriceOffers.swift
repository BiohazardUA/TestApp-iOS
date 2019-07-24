import Foundation

struct SupplementalPriceOffers: Codable {
    
    let priceOfferAmount: Float
    var supplementalPriceOffers: [String]?
    
    enum CodingKeys: String, CodingKey {
        case priceOfferAmount
        case supplementalPriceOffers
    }
    
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        priceOfferAmount = try values.decodeIfPresent(Float.self, forKey: .priceOfferAmount) ?? 0
        supplementalPriceOffers = try values.decodeIfPresent([String].self, forKey: .supplementalPriceOffers)
    }
}
