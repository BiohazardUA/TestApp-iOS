import Nimble
import RxSwift
import RxCocoa
import RxTest
import XCTest

class EditQuotePricingViewModelTests: XCTestCase {

    var sut: EditQuotePricingViewModel!

    override func setUp() {
        super.setUp()
        let mockDateTimeFormatter = MockDataDateTimeFormatter()
        let mockCurrencyFormatter = MockDataCurrencyFormatter()
        let mockAnalyticsReporter = MockSegmentAnalyticsReporter(environment: Environment(type: .development, market: .au))
        let mockFetchQuoteUseCase = MockFetchQuoteUseCase()
        let mockUpdateQuoteOptionsUseCase = MockUpdateQuoteOptionsUseCase()
        sut = EditQuotePricingViewModel(fetchQuoteUseCase: mockFetchQuoteUseCase,
                                        updateOptionsUseCase: mockUpdateQuoteOptionsUseCase,
                                        dateTimeFormatter: mockDateTimeFormatter,
                                        analyticsReporter: mockAnalyticsReporter,
                                        formatter: mockCurrencyFormatter)
    }
    
    func test_getQuoteOnViewDidAppear() {
        sut.viewDidAppear.onNext(())
        let expectedQuoteId = "6ecf9114-612e-46ff-85cd-ff0d34754ade"
        var quote: Quote!
        _ = sut.quote.drive(onNext: {
            quote = $0
        })
        
        expect(quote.id).toEventually(equal(expectedQuoteId))
    }
    
    func test_getPriceOfferForPreselectedIndex() {
        sut.viewDidAppear.onNext(())
        let expectedProtectionId = "ca87f4e5-c99e-45e2-82e3-b3fbfee5a5f4"
        sut.priceOfferSliderIndex.onNext(0)
        
        var priceOffer: PriceOffer!
        _ = sut.priceOfferSelected.drive(onNext: {
            priceOffer = $0
        })

        expect(priceOffer.id).toEventually(equal(expectedProtectionId))
    }
    
    func test_preselectedIndexOfPriceOffer() {
        sut.viewDidAppear.onNext(())
        let expectedIndex = 1
        var index: Int!
        _ = sut.priceOfferIndexPreSelected.drive(onNext: {
            index = $0
        })
        
        expect(index).toEventually(equal(expectedIndex))
    }
    
    func test_getNumberOfPriceOffers() {
        sut.viewDidAppear.onNext(())
        let expectedCount = 2
        var count: Int!
        _ = sut.numberOfPriceOffers.drive(onNext: {
            count = $0
        })
        
        expect(count).toEventually(equal(expectedCount))
    }
    
    func test_getCurrencySymbol() {
        sut.viewDidAppear.onNext(())
        let expectedCurrencySymbol = "$"
        var currencySymbol: String!
        _ = sut.currencySymbol.drive(onNext: {
            currencySymbol = $0
        })
        
        expect(currencySymbol).toEventually(equal(expectedCurrencySymbol))
    }
    
    func test_getPremiumInterval() {
        sut.viewDidAppear.onNext(())
        let expectedInterval = "/DAY"
        var premiumInterval: String!
        _ = sut.interval.drive(onNext: {
            premiumInterval = $0
        })
        
        expect(premiumInterval).toEventually(equal(expectedInterval))
    }
    
    func test_getPremiumAmountText() {
        sut.viewDidAppear.onNext(())
        let expectedAmountText = "210.13"
        sut.priceOfferSliderIndex.onNext(0)
        var amount: String!
        _ = sut.premiumValue.drive(onNext: {
            amount = $0
        })
        
        expect(amount).toEventually(equal(expectedAmountText))
    }
    
    func test_getDateByIndexSelected() {
        sut.viewDidAppear.onNext(())
        let calendar = Calendar.current
        
        let selectedIndex = 2
        let expectedDate = calendar.date(byAdding: .day, value: selectedIndex, to: Date()) ?? Date()
        
        var selectedDate: Date!
        _ = sut.propertiesList.drive(onNext: { properties in
            properties.forEach {
                if case let QuotePricingProperty.startDate(date, _) = $0 {
                    selectedDate = date
                }
            }
        })
        
        sut.startDateChanged.onNext((expectedDate, selectedIndex))
        let isSameDate = calendar.compare(selectedDate, to: expectedDate, toGranularity: .day) == .orderedSame
        expect(isSameDate).toEventually(beTrue())
    }
    
    func test_getProtectionOptions() {
        sut.viewDidAppear.onNext(())
        let expectedOptions = MockPriceOfferOption.getOptions()
        sut.priceOfferSliderIndex.onNext(0)
        
        var options = [QuotePricingProperty.Option]()
        _ = sut.propertiesList.drive(onNext: { propertiesList in
            propertiesList.forEach {
                if case let QuotePricingProperty.protectionOption(option) = $0 {
                    options.append(option)
                }
            }
        })
        
        expect(options).toEventually(equal(expectedOptions))
    }
    
    func test_activateSuplementalProtectionOption() {
        sut.viewDidAppear.onNext(())
        let expectedSelectedOptionType = "StolenCar"
        sut.selectedSupplementChanged.onNext(SelectedSuplementalPriceOffer(title: "Stolen Car", type: expectedSelectedOptionType))
        
        var options = [QuotePricingProperty.Option]()
        _ = sut.propertiesList.drive(onNext: { propertiesList in
            propertiesList.forEach {
                if case let QuotePricingProperty.protectionOption(option) = $0,
                    option.type == expectedSelectedOptionType {
                    options.append(option)
                }
            }
        })
        
        expect((options.first?.type).orEmpty).toEventually(equal(expectedSelectedOptionType))
    }
    
    func test_discardChanges() {
        sut.discardChanges.onNext(())
        let expectedOptions = MockPriceOfferOption.getOptions()
        let expectedDate = Date()
        
        var options = [QuotePricingProperty.Option]()
        var selectedDate: Date!
        _ = sut.propertiesList.drive(onNext: { propertiesList in
            propertiesList.forEach {
                if case let QuotePricingProperty.protectionOption(option) = $0 {
                    options.append(option)
                } else if case let QuotePricingProperty.startDate(date, _) = $0 {
                    selectedDate = date
                }
            }
        })
        
        let expectedPriceOfferIndex = 1
        var index: Int!
        _ = sut.priceOfferIndexPreSelected.drive(onNext: {
            index = $0
        })
        
        let calendar = Calendar.current
        let isSameDate = calendar.compare(selectedDate, to: expectedDate, toGranularity: .day) == .orderedSame
        
        expect(options).toEventually(equal(expectedOptions))
        expect(index).toEventually(equal(expectedPriceOfferIndex))
        expect(isSameDate).toEventually(beTrue())
    }
}

private class MockPriceOfferOption {
    
    private init() {}
    
    static func getOptions() -> [QuotePricingProperty.Option] {
        let options = [QuotePricingProperty.Option(text: "", price: "", active: false, id: "", type: "StolenCar")]
        return options
    }
}

private class MockDataCurrencyFormatter: CurrencyFormatter {
    
    func format(from amount: Decimal) -> String {
        return "1.00"
    }
    
    func currencySymbol() -> String {
        return "$"
    }
}

private class MockDataDateTimeFormatter: DateTimeFormatter {
    func longFormat(from date: Date) -> String {
        return ""
    }
    
    public func speechFormat(from date: Date) -> String {
        return ""
    }
}

class MockUpdateQuoteOptionsUseCase: UpdateQuoteOptionsUseCase {
    
    func execute(with excess: Amount, supplementalPriceOffers: [SelectedSuplementalPriceOffer]) -> Observable<Void> {
        return Observable<Void>.just(())
    }
}

class MockFetchQuoteUseCase: FetchQuoteUseCase {
    
    func execute() -> Observable<QuoteWithOptions> {
        // swiftlint:disable line_length
        let quoteJson = "{\"quote\":{\"id\":\"6ecf9114-612e-46ff-85cd-ff0d34754ade\",\"quoteApplicationId\":\"1dea37a6-b34a-4e36-801e-011fec57ebed\",\"protection\":{\"type\":\"AutoComprehensive\",\"productDisclosureSummaryId\":\"id or link to Comprehensive pds\",\"priceOffers\":[{\"supplementalProtections\":[{\"type\":\"AutoHireCarCover\",\"productDisclosureSummaryId\":\"Hire Car id\",\"priceOffers\":[{\"id\":\"f80fbbb6-17b5-49a5-ad3d-ada9ccfc1070\",\"premium\":{\"amount\":{\"amount\":1,\"currency\":\"AUD\"},\"premiumInterval\":\"Monthly\"}}]}],\"id\":\"ba87f4e5-c99e-45e2-82e3-b3fbfee5a5f3\",\"excess\":{\"amount\":100,\"currency\":\"AUD\"},\"premium\":{\"amount\":{\"amount\":570.13,\"currency\":\"AUD\"},\"premiumInterval\":\"Monthly\"}},{\"supplementalProtections\":[{\"type\":\"StolenCar\",\"productDisclosureSummaryId\":\"Stole Car id\",\"priceOffers\":[{\"id\":\"f80fbbb6-17b5-49a5-ad3d-ada9ccfc1080\",\"premium\":{\"amount\":{\"amount\":10,\"currency\":\"AUD\"},\"premiumInterval\":\"Monthly\"}}]}],\"id\":\"ca87f4e5-c99e-45e2-82e3-b3fbfee5a5f4\",\"excess\":{\"amount\":1000,\"currency\":\"AUD\"},\"premium\":{\"amount\":{\"amount\":200.13264,\"currency\":\"AUD\"},\"premiumInterval\":\"Daily\"}}]}},\"quoteOptions\":{\"excess\":{\"amount\":1000,\"currency\":\"AUD\"},\"supplementalPriceOffers\":[{\"title\":\"Auto Hire Car Cover\",\"type\":\"StolenCar\"}]}}"
        let data = quoteJson.data(using: .utf8, allowLossyConversion: false)
        let quote = try! JSONDecoder().decode(QuoteWithOptions.self, from: data!)
        
        return .just(quote)
    }
}
