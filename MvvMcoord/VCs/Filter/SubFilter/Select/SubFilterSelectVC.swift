import UIKit
import RxSwift
import RxCocoa
import RxDataSources

class SubFilterSelectVC: UIViewController {
    
    public var viewModel: SubFilterVM!
    private var bag = DisposeBag()
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var applyView: ApplyButton!
    @IBOutlet weak var applyViewBottomCon: NSLayoutConstraint!
    
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        print("init SubFilterSelectVC")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        registerTableView()
        bindCell()
        bindSelection()
        bindApply()
    }
    
    deinit {
        print("deinit SubFilterSelectVC 4")
    }
    
    
    private func registerTableView(){
        
        tableView.rx.setDelegate(self)
            .disposed(by: bag)
    }
    
    
    private func bindCell(){
        
        viewModel.filterActionDelegate?.subFiltersEvent()
            .bind(to: self.tableView.rx.items) { [weak self] tableView, index, model in
                guard let `self` = self else { return UITableViewCell() }
                let indexPath = IndexPath(item: index, section: 0)
                let cell = tableView.dequeueReusableCell(withIdentifier: "SubFilterSelectCell", for: indexPath) as! SubFilterSelectCell
                if let `model` = model {
                    cell.configCell(model: model, isCheckmark: self.viewModel.isCheckmark(subFilterId: model.id))
                }
                return cell
            }
            .disposed(by: bag)
    }
    
    
    private func bindSelection(){
        
        tableView.rx.itemSelected
            .subscribe(onNext: {[weak self] indexPath  in
               let cell = self!.tableView.cellForRow(at: indexPath) as! SubFilterSelectCell
                if cell.selectedCell() {
                    self?.viewModel?.filterActionDelegate?.selectSubFilterEvent().onNext((cell.id, true))
                } else {
                    self?.viewModel?.filterActionDelegate?.selectSubFilterEvent().onNext((cell.id, false))
                }
            })
            .disposed(by: bag)
    }
    
    
    private func bindApply(){
        
        applyView.applyButton.rx.tap
            .take(1)
            .subscribe{[weak self] _ in
                self?.viewModel.inApply.onNext(Void())
            }
            .disposed(by: bag)
        
        applyView.cleanUpButton.rx.tap
            .subscribe{[weak self] _ in
                self?.viewModel.inCleanUp.onNext(Void())
        }
        .disposed(by: bag)
        
        viewModel.outCloseVC
        .take(1)
        .subscribe{[weak self] _ in
            self?.navigationController?.popViewController(animated: true)
        }
        .disposed(by: bag)
        
        viewModel.filterActionDelegate?.showApplyingViewEvent()
            .bind(onNext: {[weak self] isShow in
                guard let `self` = self else {return}
                self.applyViewBottomCon.constant = isShow ? 0 : self.applyView.frame.height
                self.view.layoutIfNeeded()
            })
            .disposed(by: bag)
    }
}


extension SubFilterSelectVC: UITableViewDelegate {
    override func didMove(toParent parent: UIViewController?) {
        if parent == nil {
            viewModel.backEvent.onNext(.back)
        }
    }
}
