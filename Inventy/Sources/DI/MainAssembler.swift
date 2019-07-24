import Swinject
import SwinjectStoryboard

class MainAssembler {
    
    let container: Container
    let assembler: Assembler

    init() {
        container = SwinjectStoryboard.defaultContainer
        assembler = Assembler(container: container)
        assembler.apply(assembly: AnalyticsAssembly())
        assembler.apply(assembly: AppServiceAssembly())
        assembler.apply(assembly: ApplicationAssembly())
        assembler.apply(assembly: FactoryAssembly())
        assembler.apply(assembly: RootAssembly())
        assembler.apply(assembly: StorageAssembly())
        assembler.apply(assembly: UseCaseAssembly())
    }

    func appService() -> AppService {
        return container.resolve(AppService.self)!
    }
}
