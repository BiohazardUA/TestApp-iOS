import RxSwift

protocol UpdateQuoteOptionsUseCase {
    
    func execute(with supplementalPriceOffers: [SelectedSuplementalPriceOffer]) -> Observable<Void>
}

// MARK: -
class DefaultUpdateQuoteOptionsUseCase: UpdateQuoteOptionsUseCase {
    
    private let updateOptionsOperation: ([String]) -> Single<Void>
    
    init(sessionManager: UserSession, api: Network) {
        let guestSessionId = sessionManager.guestSessionId
        
        updateOptionsOperation = { priceOffers in
            let request = api.request(target: .updateQuoteOptions(guestSessionId: guestSessionId,
                                                                  supplementalPriceOffers: priceOffers))
            return request
        }
    }
    
    func execute(with supplementalPriceOffers: [SelectedSuplementalPriceOffer]) -> Single<Void> {
        let supplements = supplementalPriceOffers.map { $0.type }
        return updateOptionsOperation(supplements)
    }
}
