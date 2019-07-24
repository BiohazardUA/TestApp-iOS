import Foundation

struct SelectedSuplementalPriceOffer: Codable, Equatable {
    
    public static func == (lhs: SelectedSuplementalPriceOffer, rhs: SelectedSuplementalPriceOffer) -> Bool {
        return lhs.type == rhs.type
    }
    
    var title: String
    var type: String
    
    init(title: String, type: String) {
        self.title = title
        self.type = type
    }
}
