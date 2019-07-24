import Foundation
import UIKit

class AppearancesService: NSObject, AppService {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {

        UINavigationBar.appearance().tintColor = .green
        UINavigationBar.appearance().shadowImage = UIImage()
        UINavigationBar.appearance().titleTextAttributes = [
            .font: FontFamily.Oswald.regular.font(size: 20),
            .foregroundColor: UIColor.white
        ]

        UITabBar.appearance().barTintColor = .green
        UITabBar.appearance().tintColor = .white
        UITabBar.appearance().unselectedItemTintColor = UIColor.white.withAlphaComponent(0.5)
        return true
    }
}
