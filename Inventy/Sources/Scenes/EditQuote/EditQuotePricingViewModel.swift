import RxCocoa
import RxSwift

protocol EditQuotePricingViewModelInput {
    typealias DateItem = (date: Date, index: Int)
    
    var viewDidAppear: AnyObserver<Void> { get }
    var priceOfferSliderIndex: AnyObserver<Int> { get }
    var startDateChanged: AnyObserver<DateItem> { get }
    var updatePolicyTapped: AnyObserver<Void> { get }
    var selectedSupplementChanged: AnyObserver<SelectedSuplementalPriceOffer> { get }
    var discardChanges: AnyObserver<Void> { get }
    
    func updateSelectedPriceOfferExcess(_ excess: Amount)
}

protocol EditQuotePricingViewModelOutput {
    var priceOfferSelected: Driver<PriceOffer> { get }
    var priceOfferIndexPreSelected: Driver<Int> { get }
    var numberOfPriceOffers: Driver<Int> { get }
    var currencySymbol: Driver<String> { get }
    var premiumValue: Driver<String> { get }
    var interval: Driver<String> { get }
    var excessValue: Driver<String> { get }
    var propertiesList: Driver<[QuotePricingProperty]> { get }
    var loading: Driver<Bool> { get }
    var quote: Driver<Quote> { get }
    var finishEditing: Driver<Void> { get }
    var errors: Driver<Error> { get }
    
    func isPolicyChanged() -> Driver<Bool>
}

class EditQuotePricingViewModel: EditQuotePricingViewModelInput, EditQuotePricingViewModelOutput {
    
    struct UserInterfaceStates: Equatable {
        static func == (lhs: UserInterfaceStates, rhs: UserInterfaceStates) -> Bool {
            return lhs.selectedDateIndex == rhs.selectedDateIndex &&
                lhs.selectedOptions.supplementalPriceOffers == rhs.selectedOptions.supplementalPriceOffers &&
                lhs.selectedOptions.excess == rhs.selectedOptions.excess
        }
        
        var selectedOptions = QuoteOptions()
        var selectedDateIndex = 0
    }
    
    // MARK: - Input
    let priceOfferSliderIndex: AnyObserver<Int>
    let startDateChanged: AnyObserver<DateItem>
    let selectedSupplementChanged: AnyObserver<SelectedSuplementalPriceOffer>
    let updatePolicyTapped: AnyObserver<Void>
    let discardChanges: AnyObserver<Void>
    
    // MARK: - Output
    let priceOfferSelected: Driver<PriceOffer>
    let priceOfferIndexPreSelected: Driver<Int>
    let numberOfPriceOffers: Driver<Int>
    let currencySymbol: Driver<String>
    let premiumValue: Driver<String>
    let interval: Driver<String>
    let excessValue: Driver<String>
    let propertiesList: Driver<[QuotePricingProperty]>
    let loading: Driver<Bool>
    let quote: Driver<Quote>
    let finishEditing: Driver<Void>
    let errors: Driver<Error>
    
    // MARK: - Private
    private let excessAmount: Driver<Amount>
    private let userInterfaceStates = BehaviorRelay<UserInterfaceStates>(value: UserInterfaceStates())
    
    private let currentStates: Driver<UserInterfaceStates>
    private let defaultStates: Driver<UserInterfaceStates>
    
    private let analyticsReporter: AnalyticsReporter
    
    // swiftlint:disable function_body_length
    init(fetchQuoteUseCase: FetchQuoteUseCase, updateOptionsUseCase: UpdateQuoteOptionsUseCase, dateTimeFormatter: DateTimeFormatter, analyticsReporter: AnalyticsReporter, formatter: CurrencyFormatter) {
        self.analyticsReporter = analyticsReporter
        
        let activity = ActivityIndicator()
        loading = activity.asDriver()
        
        let errors = Driver<Error>.create()
        self.errors = errors.output
        
        let quote = Driver<Void>.create()
        
        let selectedSupplementChanged = self.selectedSupplementChanged
        
        let userInterfaceStates = self.userInterfaceStates
        currentStates = userInterfaceStates.asDriver()
        
        let defaultDate = (date: Date(), index: 0)
        let startDateChanged = self.startDateChanged
        let startDate = startDateChanged.startWith(defaultDate)
            .do(onNext: {  dateItem in
                var lastStates = userInterfaceStates.value
                lastStates.selectedDateIndex = dateItem.index
                userInterfaceStates.accept(lastStates)
            })
        
        let quoteWithOptions = quote.output
            .flatMapLatest { _ in
                fetchQuoteUseCase.execute()
                    .trackActivity(activity)
                    .asDriver(onErrorEmitTo: errors.input)
            }
        
        self.quote = quoteWithOptions
            .do(onNext: { quoteWithOptions in
                quoteWithOptions.quoteOptions.supplementalPriceOffers.forEach {
                    selectedSupplementChanged.onNext($0)
                }
            })
            .map { $0.quote }
        
        self.defaultStates = quoteWithOptions
            .map { UserInterfaceStates(selectedOptions: $0.quoteOptions, selectedDateIndex: 0) }
        
        self.numberOfPriceOffers = self.quote
            .map { $0.priceOffersCount() }
            .asDriver(onErrorJustReturn: 0)
        
        let indexPreselected = Driver.combineLatest(self.defaultStates, self.quote)
            .map { states, quote -> Int in
                let priceOffers = quote.getPriceOffers()
                return priceOffers.firstIndex(where: { $0.excess == states.selectedOptions.excess }) ?? 0
            }
        
        priceOfferIndexPreSelected = indexPreselected
        
        let priceOfferIndex = Observable.merge(indexPreselected.asObservable(), priceOfferSliderIndex.distinctUntilChanged())
        let priceOfferSliderChanged = priceOfferSliderIndex.withLatestFrom(self.quote)
        
        let priceOfferSelected = Observable.merge(self.quote.asObservable(), priceOfferSliderChanged)
            .withLatestFrom(priceOfferIndex) { (quote, index) -> PriceOffer in
                quote.getPriceOffers()[index]
            }
            .share()
        
        self.priceOfferSelected = priceOfferSelected
            .asDriver(onErrorEmitTo: errors.input)
        
        currencySymbol = priceOfferSelected
            .map { _ in formatter.currencySymbol() }
            .asDriver(onErrorJustReturn: "")
        
        interval = priceOfferSelected
            .map { "/\($0.premiumInterval().toShortString().uppercased())" }
            .asDriver(onErrorJustReturn: "")
        
        excessValue = priceOfferSelected
            .map { "\(formatter.format(from: $0.excessAmount()))" }
            .asDriver(onErrorJustReturn: "")
        
        excessAmount = priceOfferSelected
            .map { $0.excess }
            .asDriver(onErrorEmitTo: errors.input)

        let updatePolicy = Driver<Void>.create()
        updatePolicyTapped = updatePolicy.input
        finishEditing = updatePolicy.output
            .withLatestFrom(excessAmount)
            .flatMapLatest { excessAmount in
                updateOptionsUseCase
                    .execute(with: excessAmount,
                             supplementalPriceOffers: userInterfaceStates.value.selectedOptions.supplementalPriceOffers)
                    .trackActivity(activity)
                    .asDriver(onErrorEmitTo: errors.input)
            }
            .do(onNext: { _ in
                let event = EditQuoteEvent(name: EditQuoteEvent.Constants.Name.proceedMethod,
                                           actionName: EditQuoteEvent.Constants.ActionName.updatePolicy)
                analyticsReporter.report(event.analyticsEvent,
                                         withProperties: event.analitycsParameters)
            })
        
        premiumValue = Observable.combineLatest(priceOfferSelected, userInterfaceStates)
            .map { (priceOffer, states) -> String in
                let selectedOptions = states.selectedOptions.supplementalPriceOffers
                let selectedSupplementalProtectionsSum = priceOffer.supplementalProtections?
                    .filter { supplement in
                        selectedOptions.contains { $0.type == supplement.type }
                    }
                    .compactMap { $0.premiumAmount() }
                    .reduce(0, +) ?? 0
                return "\(NSNumber(value: roundf((priceOffer.premiumAmount() + selectedSupplementalProtectionsSum) * 100) / 100).decimalValue)"
            }
            .asDriver(onErrorJustReturn: "")
        
        propertiesList = Observable.combineLatest(priceOfferSelected, startDate, userInterfaceStates.asObservable())
            .map { (priceOffer, startDate, uiStates) in
                
                var options = priceOffer.supplementalProtections?
                    .compactMap { protection -> QuotePricingProperty? in
                        let selectedOptions = uiStates.selectedOptions.supplementalPriceOffers
                        let isActive = selectedOptions.contains { $0.type == protection.type }
                        guard let option = QuotePricingProperty.Option(protection: protection,
                                                                       currencyFormatter: formatter,
                                                                       isActive: isActive) else { return nil }
                        return QuotePricingProperty.protectionOption(option: option)
                    } ?? []
                
                let dateString = dateTimeFormatter.speechFormat(from: startDate.date)
                let startDateProperty = QuotePricingProperty.startDate(date: startDate.date,
                                                                       dateString: dateString)
                options.append(startDateProperty)
                return options
            }
            .asDriver(onErrorJustReturn: [])
    }
    
    func updateSelectedPriceOfferExcess(_ excess: Amount) {
        var lastStates = userInterfaceStates.value
        lastStates.selectedOptions.excess = excess
        userInterfaceStates.accept(lastStates)
    }
    
    func isPolicyChanged() -> Driver<Bool> {
        return Driver.combineLatest(defaultStates, userInterfaceStates.asDriver())
            .map { (oldStates, newStates) in
                oldStates == newStates ? false : true
            }
    }
}
