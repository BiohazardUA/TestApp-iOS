import UIKit

class IBViewController<T: UIView>: UIViewController {
    
    // swiftlint:disable force_cast
    var customView: T { return self.view as! T }
}
