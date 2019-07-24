import RxCocoa
import RxDataSources
import RxSwift

// swiftlint:disable function_body_length
class EditQuotePricingViewController: UIViewController {
    
    typealias DataSource = RxTableViewSectionedReloadDataSource<SectionModel<String, QuotePricingProperty>>
    
    @IBOutlet private var comprehensiveView: DesignableView! {
        didSet { comprehensiveView.alpha = 0 }
    }
    @IBOutlet private var currencyLabel: UILabel!
    @IBOutlet private var premiumLabel: UILabel!
    @IBOutlet private var intervalLabel: UILabel!
    @IBOutlet private var protectSlider: ProtectSlider!
    @IBOutlet private var excessLabel: UILabel!
    @IBOutlet private var tableView: UITableView!
    @IBOutlet private(set) var updatePolicyButton: UIButton!
    
    var viewModel: ViewModel<EditQuotePricingViewModelInput, EditQuotePricingViewModelOutput>!
    
    private let disposeBag = DisposeBag()
    private var loadingHud = StoryboardScene.LoadingHud.initialScene.instantiate()
    private var startDateViewModel: EditQuotePricingStartTableViewCell.ViewModel!
    private var quoteOptionViewModel: EditQuotePricingOptionTableViewCell.ViewModel!
    private var quoteChangesHandler: ((_ changed: Bool) -> Void)!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureInput()
        configureOutput()
    }
    
    private func configureInput() {
        protectSlider.delegate = self
        
        updatePolicyButton.rx.tap
            .bind(to: viewModel.input.updatePolicyTapped)
            .disposed(by: disposeBag)
        
        NotificationCenter.default.rx.notification(GenericNotificationName.resetQuoteToDefault)
            .mapTo(())
            .bind(to: self.viewModel.input.discardChanges)
            .disposed(by: disposeBag)
    }
    
    private func configureOutput() {
        viewModel.output.priceOfferSelected
            .drive(onNext: { [unowned self] priceOffer  in
                self.viewModel.input.updateSelectedPriceOfferExcess(priceOffer.excess)
            })
            .disposed(by: disposeBag)
        
        quoteOptionViewModel.optionChanged
            .bind(to: self.viewModel.input.selectedSupplementChanged)
            .disposed(by: self.disposeBag)
        
        startDateViewModel.startDateChanged
            .bind(to: self.viewModel.input.startDateChanged)
            .disposed(by: self.disposeBag)
        
        viewModel.output.isPolicyChanged()
            .drive(onNext: { [unowned self] in
                self.quoteChangesHandler($0)
            })
            .disposed(by: disposeBag)
        
        viewModel.output.isPolicyChanged()
            .drive(updatePolicyButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
        viewModel.output.quote
            .drive(onNext: { _ in
                UIView.animate(withDuration: 0.33, animations: { [unowned self] in
                    self.comprehensiveView.alpha = 1
                })
            })
            .disposed(by: disposeBag)
        
        viewModel.output.numberOfPriceOffers
            .drive(onNext: { [unowned self] numberOfPriceOffers in
                self.protectSlider.numberOfNodes = numberOfPriceOffers
            })
            .disposed(by: disposeBag)
        
        viewModel.output.errors
            .drive(onNext: { [unowned self] in
                let message = String(describing: $0)
                let alert = UIAlertController(title: L10n.oops, message: message, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: L10n.ok, style: .cancel))
                
                self.loadingHud.hide(animated: false) { [unowned self] in
                    self.present(alert, animated: true)
                }
            })
            .disposed(by: disposeBag)
        
        viewModel.output.priceOfferIndexPreSelected
            .drive(onNext: { [unowned self] indexPreselected in
                self.protectSlider.selectedNode = indexPreselected
            })
            .disposed(by: disposeBag)
        
        viewModel.output.currencySymbol
            .drive(currencyLabel.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.output.premiumValue
            .drive(premiumLabel.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.output.interval
            .drive(intervalLabel.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.output.excessValue
            .drive(excessLabel.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.output.propertiesList.asObservable()
            .map { [SectionModel(model: "", items: $0)] }
            .bind(to: tableView.rx.items(dataSource: makeDataSource()))
            .disposed(by: disposeBag)
        
        viewModel.output.loading
            .drive(onNext: { [unowned self] loading in
                self.loadingHud.changeState(isLoading: loading, in: self)
            })
            .disposed(by: disposeBag)
        
        viewModel.output.finishEditing
            .drive(onNext: { [unowned self] _ in
                self.navigationController?.popViewController(animated: true)
            })
            .disposed(by: disposeBag)
    }
    
    private func makeDataSource() -> DataSource {
        let dataSource =
            DataSource(configureCell: { [unowned self] _, tableView, indexPath, element in
                switch element {
                    
                case let .protectionOption(option):
                    let cell = tableView.dequeueReusableCell(withClass: EditQuotePricingOptionTableViewCell.self, for: indexPath)
                    self.quoteOptionViewModel.configure(with: option)
                    cell.configure(with: self.quoteOptionViewModel)
                    return cell
                    
                case let .startDate(date, dateString):
                    let cell = tableView.dequeueReusableCell(withClass: EditQuotePricingStartTableViewCell.self, for: indexPath)
                    self.startDateViewModel.update(date: date, dateString: dateString)
                    cell.configure(with: self.startDateViewModel)
                    return cell
                }
            })
        
        return dataSource
    }
}

extension EditQuotePricingViewController: ProtectSliderDelegate {
    
    func protectSliderMoved(_ value: Float) {
        viewModel.input.priceOfferSliderIndex.onNext(Int(value))
    }
}
