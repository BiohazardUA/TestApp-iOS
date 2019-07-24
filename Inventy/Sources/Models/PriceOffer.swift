import Foundation

struct PriceOffer: Codable {

	let excess: Amount
	let id: String
	let premium: Premium
	let supplementalProtections: [SupplementalProtection]?
    
    func premiumInterval() -> PremiumInterval {
        return PremiumInterval(rawValue: premium.premiumInterval) ?? .unknown
    }
    
    func excessAmount() -> Decimal {
        let amount = excess.amount
        return NSNumber(value: roundf(amount * 100) / 100).decimalValue
    }
    
    func premiumAmount() -> Float {
        return premium.amount.amount
    }
}
