import RxSwift
import RxCocoa

protocol RootNavigationViewModelInput {
    //
}

protocol RootNavigationViewModelOutput {
    var transition: Driver<RootNavigationDestination> { get }
    var state: ApplicationState { get }
}

enum RootNavigationDestination {
    case signIn, home, onboarding
}

class RootNavigationViewModel: RootNavigationViewModelInput, RootNavigationViewModelOutput {
    
    // MARK: - Output
    let transition: Driver<RootNavigationDestination>
    let stateMachine: ReadOnlyApplicationStateMachine
    
    var state: ApplicationState { return stateMachine.state }
    
    // MARK: - Lifecycle
    init(stateMachine: ReadOnlyApplicationStateMachine, dataStore: DataStore) {
        
        self.stateMachine = stateMachine
        
        self.transition = stateMachine.rx.transitions().map { transition in
            switch transition.new {
            case .pending, .preparing, .guest, .loggedIn:
                return nil // not handled
                
            case .ready:
                return .onboarding

            case .loggedOut:
                // ignore the `.loggedIn` > `.loggedOut` transition
                // as it eventually results in a `.preparing` state
                guard case .ready = transition.old else { return nil }
                
                return .onboarding
            }
        }
        .unwrap()
        .asDriver(onErrorDriveWith: .never())

        AppStateMachine.transition(with: .prepared)
    }
}

extension ReadOnlyStateMachine: ReactiveCompatible { }

extension Reactive where Base == ReadOnlyApplicationStateMachine {
    /// Observable of transition events
    func transitions() -> Observable<Transition<ApplicationState>> {
        return .create { observer in
            let subscription = self.base.subscribe { value in
                observer.onNext(value)
            }
            return Disposables.create {
                self.base.unsubscribe(subscription)
            }
        }
    }
}
