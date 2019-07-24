import Foundation

struct QuoteOptions: Codable {
    
    var excess: Amount
    var supplementalPriceOffers: [SelectedSuplementalPriceOffer]
    
    init() {
        excess = Amount()
        supplementalPriceOffers = [SelectedSuplementalPriceOffer]()
    }
}
