import CoreLocation
import CoreMotion
import RxSwift
import RxCocoa

enum TelematicsPrequisitesStatus {
    case notEnoughPermissions
    case canRequestPermissions
    case needLocationPermissions
    case needMotionPermissions
    case allPermissionsGranted
}

enum TelematicsPrequisitesError: Error {
    case locationRequestFailed
    case motionRequestFailed
}

class TelematicPrerequisitesValidator: NSObject, AppService, CLLocationManagerDelegate, Loggable {
    
    private let locationAuthorizationSubject: PublishSubject<CLAuthorizationStatus> = PublishSubject()
    private let motionAuthorizationSubject: PublishSubject<CMAuthorizationStatus> = PublishSubject()
    private let locationManager: CLLocationManager
    private let motionManager: CMMotionActivityManager
    
    init(locationManager: CLLocationManager, motionManager: CMMotionActivityManager) {
        self.locationManager = locationManager
        self.motionManager = motionManager
        super.init()
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        return true
    }
    
    func checkLocationPermissions() -> TelematicsPrequisitesStatus {
        let locationAuthorizationStatus = CLLocationManager.authorizationStatus()
        let motionAuthorizationStatus = CMMotionActivityManager.authorizationStatus()
        
        switch (locationAuthorizationStatus, motionAuthorizationStatus) {
        case (.notDetermined, _),
             (_, .notDetermined):
            return .canRequestPermissions
        case (.authorizedAlways, .authorized):
            return .allPermissionsGranted
        case (.authorizedAlways, _):
            return .needMotionPermissions
        case ( _, .authorized):
            return .needLocationPermissions
        default:
            return .notEnoughPermissions
        }
    }
    
    func requestPermissions() -> Observable<TelematicsPrequisitesStatus> {
        let permissionsNeeded = checkLocationPermissions()
        switch permissionsNeeded {
        case .allPermissionsGranted:
            return Observable<TelematicsPrequisitesStatus>.just(.allPermissionsGranted)
        case .canRequestPermissions:
            return requestLocationPermissions().flatMapLatest { permissions -> Observable<TelematicsPrequisitesStatus> in
                if permissions == TelematicsPrequisitesStatus.allPermissionsGranted {
                    return Observable<TelematicsPrequisitesStatus>.just(.allPermissionsGranted)
                } else {
                    return self.requestMotionPermissions()
                }
            }
        default:
            return Observable<TelematicsPrequisitesStatus>.just(.notEnoughPermissions)
        }
    }
    
    private func requestLocationPermissions() -> Observable<TelematicsPrequisitesStatus> {
        let locationAuthorizationStatus = CLLocationManager.authorizationStatus()
        switch locationAuthorizationStatus {
        case .notDetermined:
            return Observable<TelematicsPrequisitesStatus>.create { [weak self] observer in
                guard let self = self else {
                    return observer.onError(TelematicsPrequisitesError.locationRequestFailed) as! Disposable
                }
                
                _ = self.locationAuthorizationSubject.subscribe(onNext: { authorizationStatus in
                    let permissionsNeeded = self.checkLocationPermissions()
                    switch authorizationStatus {
                    case.authorizedAlways:
                        observer.onNext(permissionsNeeded)
                        if permissionsNeeded == .allPermissionsGranted {
                            observer.onCompleted()
                        }
                    default:
                        observer.onNext(permissionsNeeded)
                    }
                })
                
                self.locationManager.delegate = self
                self.locationManager.requestAlwaysAuthorization()
                return Disposables.create()
            }
        case .authorizedAlways:
            return Observable<TelematicsPrequisitesStatus>.just(.needLocationPermissions)
        default:
            return Observable<TelematicsPrequisitesStatus>.just(self.checkLocationPermissions())
        }
    }
    
    private func requestMotionPermissions() -> Observable<TelematicsPrequisitesStatus> {
        let motionAuthorizationStatus = CMMotionActivityManager.authorizationStatus()
        switch motionAuthorizationStatus {
        case .notDetermined:
            return Observable<TelematicsPrequisitesStatus>.create { [weak self] observer in
                guard let self = self else {
                    return observer.onError(TelematicsPrequisitesError.motionRequestFailed) as! Disposable
                }
                
                let now = Date()
                let before = Date(timeIntervalSinceNow: -100)
                // Only way to trigger motion permissions prompt is to query them
                self.motionManager.queryActivityStarting(from: before, to: now, to: OperationQueue.main, withHandler: { _, _ in
                    self.logInfo("Motion manager started")
                    self.motionManager.stopActivityUpdates()
                    let permissionsNeeded = self.checkLocationPermissions()
                    observer.onNext(permissionsNeeded)
                    if permissionsNeeded == .allPermissionsGranted {
                        observer.onCompleted()
                    }
                })
                return Disposables.create()
            }
        case .authorized:
            return Observable<TelematicsPrequisitesStatus>.just(.needMotionPermissions)
        default:
            return Observable<TelematicsPrequisitesStatus>.just(self.checkLocationPermissions())
        }
    }
    
    // MARK: Delegate methods
    public func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        self.locationAuthorizationSubject.onNext(status)
    }
}
