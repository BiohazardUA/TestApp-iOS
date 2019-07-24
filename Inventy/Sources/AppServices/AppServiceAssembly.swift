import Swinject
import CoreLocation
import CoreMotion

class AppServiceAssembly: Assembly {
 
    func assemble(container: Container) {
        
        container
            .register(TelematicPrerequisitesValidator.self) { resolver in
                let locationManager = CLLocationManager()
                let motionManager = CMMotionActivityManager()
                return TelematicPrerequisitesValidator(locationManager: locationManager, motionManager: motionManager)
            }
            .inObjectScope(.container)
        
        container.register(AppService.self) { resolver in
            var services = [AppService]()
            services.append(AppearancesService())
            services.append(resolver.resolve(TelematicPrerequisitesValidator.self)!)
            
            return AppServiceComposite(services: services)
        }
    }
}
