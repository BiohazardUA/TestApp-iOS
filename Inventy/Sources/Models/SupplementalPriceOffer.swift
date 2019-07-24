import Foundation

struct SupplementalPriceOffer: Codable {
    
    let id: String
    let premium: Premium
    
    func premiumInterval() -> PremiumInterval {
        return PremiumInterval(rawValue: premium.premiumInterval) ?? .unknown
    }
    
    func premiumAmount() -> Decimal {
        let amount = premium.amount.amount
        return NSNumber(value: roundf(amount * 100) / 100).decimalValue
    }
}
