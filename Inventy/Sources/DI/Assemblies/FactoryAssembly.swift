import Swinject

class FactoryAssembly: Assembly {
    
    func assemble(container: Container) {
        container.register(AttributedLinkFactory.self) { _ in
            DefaultAttributedLinkFactory()
        }
    }
}
