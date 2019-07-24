import Foundation

struct Amount: Codable, Equatable {
    
    static func == (lhs: Amount, rhs: Amount) -> Bool {
        return lhs.amount == rhs.amount
    }
    
	let amount: Float
	private let currency: String
    
    init() {
        amount = 0
        currency = "AUD"
    }
    
    func currencyType() -> CurrencyType {
        return CurrencyType(rawValue: currency) ?? .AUD
    }
}
