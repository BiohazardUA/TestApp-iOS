import Reachability
import RxCocoa
import RxSwift
import UIKit

class NetworkConnectivityMonitor: NetworkConnectivityMonitoring {
    let reachable: Observable<Bool>
    let error: Observable<Error>
    var isNetworkAvailable: Bool { return reachability.connection != .none }
    
    private let reachableSubject = PublishSubject<Bool>()
    private let errorSubject = PublishSubject<Error>()
    private let reachability = Reachability()!

    init() {
        reachable = reachableSubject.asObservable().distinctUntilChanged()
        error = errorSubject.asObservable()
        
        reachability.whenReachable = { _ in
            self.reachableSubject.onNext(true)
        }
        reachability.whenUnreachable = { _ in
            self.reachableSubject.onNext(false)
        }
        
        do {
            try reachability.startNotifier()
        } catch let error {
            errorSubject.onNext(error)
        }
    }
    
    deinit {
        reachability.whenReachable = nil
        reachability.whenUnreachable = nil
        reachability.stopNotifier()
    }
}
