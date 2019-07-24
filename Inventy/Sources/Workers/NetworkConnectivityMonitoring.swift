import RxSwift

protocol NetworkConnectivityMonitoring {
    
    var reachable: Observable<Bool> { get }
    var error: Observable<Error> { get }
    var isNetworkAvailable: Bool { get }
}
