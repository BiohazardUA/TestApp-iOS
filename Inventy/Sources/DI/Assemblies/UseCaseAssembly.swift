import Swinject

class UseCaseAssembly: Assembly {

    // swiftlint:disable:next function_body_length
    func assemble(container: Container) {
        
        container.register(CreateAccountUseCase.self) { _ in
            DefaultCreateAccountUseCase()
        }

        container.register(SignInUseCase.self) { _ in
            DefaultSignInUseCase()
        }

        container.register(FetchDashboardWidgetsUseCase.self) { resolver in
            let sessionManager = resolver.resolve(UserSession.self)!
            let restAPI = resolver.resolve(RestAPI.self)!
            return FetchDashboardWidgetsUseCase(sessionManager: sessionManager, api: restAPI)
        }

        container.register(FetchQuoteUseCase.self) { resolver in
            let sessionManager = resolver.resolve(UserSession.self)!
            let restAPI = resolver.resolve(RestAPI.self)!
            return DefaultFetchQuoteUseCase(sessionManager: sessionManager, api: restAPI)
        }

        container.register(UpdateQuoteOptionsUseCase.self) { resolver in
            let sessionManager = resolver.resolve(UserSession.self)!
            let restAPI = resolver.resolve(RestAPI.self)!
            return DefaultUpdateQuoteOptionsUseCase(sessionManager: sessionManager, api: restAPI)
        }

        container.register(FetchPaymentDetailUseCase.self) { resolver in
            let sessionManager = resolver.resolve(UserSession.self)!
            let restAPI = resolver.resolve(RestAPI.self)!

            return DefaultFetchPaymentDetailUseCase(sessionManager: sessionManager, api: restAPI)
        }
    }
}
