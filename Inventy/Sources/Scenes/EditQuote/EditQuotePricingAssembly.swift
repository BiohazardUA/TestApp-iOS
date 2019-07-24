import Swinject

class EditQuotePricingAssembly: Assembly {
    
    func assemble(container: Container) {
        
        container.storyboardInitCompleted(EditQuotePricingViewController.self) { (resolver, controller) in
            let viewModel = resolver.resolve(EditQuotePricingViewModel.self)!
            controller.viewModel = ViewModel(viewModel, viewModel)
        }
        
        container.register(EditQuotePricingViewModel.self) { resolver in
            let fetchQuoteUseCase = resolver.resolve(FetchQuoteUseCase.self)!
            let updateQuoteOptionsUseCase = resolver.resolve(UpdateQuoteOptionsUseCase.self)!
            let dateTimeFormatter = resolver.resolve(DateTimeFormatter.self)!
            let analyticsReporter = resolver.resolve(AnalyticsReporter.self)!
            let currencyFormatter = resolver.resolve(CurrencyFormatter.self)!
            
            let viewModel = EditQuotePricingViewModel(fetchQuoteUseCase: fetchQuoteUseCase,
                                                      updateOptionsUseCase: updateQuoteOptionsUseCase,
                                                      dateTimeFormatter: dateTimeFormatter,
                                                      analyticsReporter: analyticsReporter,
                                                      formatter: currencyFormatter)
            return viewModel
        }
    }
}
