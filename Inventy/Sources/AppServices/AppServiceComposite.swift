import Foundation
import UIKit

class AppServiceComposite: NSObject, AppService {
    private var services = [AppService]()
    
    init(services: [AppService]) {
        super.init()
        self.services.append(contentsOf: services)
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        return services.reduce(true) { (result, service) in
            let success = service.application?(application, didFinishLaunchingWithOptions: launchOptions) ?? true
            return success && result
        }
    }
    
    //swiftlint:disable - colon
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        return services.reduce(true) { (result, service) in
            let success = service.application?(app, open: url, options: options) ?? true
            return success && result
        }
    }
}
