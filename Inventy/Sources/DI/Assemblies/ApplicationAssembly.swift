import CoreLocation
import Swinject
import UIKit

class ApplicationAssembly: Assembly {
  
    func assemble(container: Container) {
        
        container
            .register(Network.self) { _ in
                DefaultNetwork()
            }
            .inObjectScope(.container)
    }
}
