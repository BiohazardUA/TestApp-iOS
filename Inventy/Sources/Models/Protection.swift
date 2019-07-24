import Foundation

struct Protection: Codable {
    
    let priceOffers: [PriceOffer]
    let productDisclosureSummaryId: String
    let type: String
    let title: String?
    
    func firstProtectionId() -> String {
        return (priceOffers.first?.id).orEmpty
    }
    
    func premiumAmount() -> Float {
        return priceOffers[0].premium.amount.amount
    }
}
