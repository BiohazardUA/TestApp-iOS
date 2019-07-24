import RxCocoa
import RxSwift
import SafariServices
import SwinjectStoryboard

final class RootNavigationController: UINavigationController {
    typealias ViewModelType = ViewModel<RootNavigationViewModelInput, RootNavigationViewModelOutput>
    
    // MARK: - Public Properties
    var viewModel: ViewModelType!
    
    // MARK: - Private Properties
    private let disposeBag = DisposeBag()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        interactivePopGestureRecognizer?.isEnabled = false
        configureOutput()
    }

    // MARK: - ViewModel
    private func configureOutput() {
        viewModel.output.transition
            .drive(onNext: { [unowned self] destination in
                self.dismiss(animated: true)
                
                switch destination {
                case .home:
                    self.perform(segue: StoryboardSegue.Main.showHome)
                case .onboarding:
                    self.perform(segue: StoryboardSegue.Main.showOnboarding)
                case .signIn:
                    self.perform(segue: StoryboardSegue.Main.showSignIn)
                }
            })
            .disposed(by: disposeBag)
    }
}
