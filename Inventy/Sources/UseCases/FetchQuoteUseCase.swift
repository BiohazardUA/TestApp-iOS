import RxSwift

protocol FetchQuoteUseCase {
    
    func execute() -> Single<QuoteWithOptions>
}

// MARK: -
class DefaultFetchQuoteUseCase: FetchQuoteUseCase {
    
    private let fetchQuoteOperation: () -> Single<QuoteWithOptions>
    
    init(sessionManager: UserSession, api: Network) {
        let quoteApplicationId = sessionManager.quoteApplicationId
        let guestSessionId = sessionManager.guestSessionId
        
        fetchQuoteOperation = {
            let request = api.request(target: .fetchQuote(guestSessionId: guestSessionId,
                                                          quoteApplicationId: quoteApplicationId))
            
            return request
        }
    }
    
    func execute() -> Single<QuoteWithOptions> {
        return fetchQuoteOperation()
    }
}
