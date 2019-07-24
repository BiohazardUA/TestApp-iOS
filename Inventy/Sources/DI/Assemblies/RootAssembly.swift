import Swinject

class RootAssembly: Assembly {
    
    func assemble(container: Container) {
        
        container.storyboardInitCompleted(RootNavigationController.self) { resolver, controller in
            controller.viewModel = resolver.resolve(RootNavigationController.ViewModelType.self)
        }
        
        container.register(RootNavigationController.ViewModelType.self) { resolver in
            let appState = resolver.resolve(ApplicationStateMachine.self)!
            let dataStore = resolver.resolve(DataStore.self)!
            let viewModel = RootNavigationViewModel(stateMachine: appState.readOnly(), dataStore: dataStore)
            return .init(viewModel, viewModel)
        }
        
    }
    
}
