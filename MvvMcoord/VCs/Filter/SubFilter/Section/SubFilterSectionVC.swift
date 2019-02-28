import UIKit
import RxSwift
import RxCocoa
import RxDataSources

class SubFilterSectionVC: UIViewController {
    
    var viewModel: SubFilterVM!
    var bag = DisposeBag()
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var applyView: ApplyButton!
    @IBOutlet weak var applyViewBottomCon: NSLayoutConstraint!
    
    private let waitContainer: UIView = UIView()
    private let waitActivityView = UIActivityIndicatorView(style: .whiteLarge)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        registerTableView()
        bindCell()
        bindSelection()
        bindApply()
        bindWaitEvent()
    }
    
    private func registerTableView(){
        tableView.rx.setDelegate(self)
            .disposed(by: bag)
    }
    
    private func bindCell(){
        let dataSource = RxTableViewSectionedReloadDataSource<SectionOfSubFilterModel>(
            configureCell: { dataSource, tableView, indexPath, model in
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "SubFilterSectionCell", for: indexPath) as? SubFilterSectionCell else { return (UITableViewCell()) }
                cell.configCell(model: model, isCheckmark: self.viewModel.isCheckmark(subFilterId: model.id))
                return cell
        })
        
        dataSource.titleForHeaderInSection = { dataSource, index in
            return dataSource.sectionModels[index].header
        }
        
        viewModel.filterActionDelegate?.sectionSubFiltersEvent()
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: bag)
    }
    
    private func bindSelection(){
        
        tableView.rx.itemSelected
            .subscribe(onNext: {[weak self] indexPath  in
                let cell = self!.tableView.cellForRow(at: indexPath) as! SubFilterSectionCell
                
                if cell.selectedCell() {
                    self?.viewModel?.filterActionDelegate?.selectSubFilterEvent().onNext((cell.id, true))
                } else {
                    self?.viewModel?.filterActionDelegate?.selectSubFilterEvent().onNext((cell.id, false))
                }
            })
            .disposed(by: bag)
        
        
        viewModel.filterActionDelegate?.refreshedCellSelectionsEvent()
            .subscribe(onNext: {[weak self] ids in
                guard let `self` = self else { return }
                
                for row in 0...self.tableView.numberOfRows(inSection: 0) - 1 {
                    if let cell = self.tableView.cellForRow(at: IndexPath(row: row, section: 0)) as? SubFilterSectionCell {
                        if ids.contains(cell.id) {
                            cell.selectCell()
                        }
                    }
                }
            })
            .disposed(by: bag)
    }
    
    private func bindApply(){
        
        applyView.applyButton.rx.tap
            .subscribe{[weak self] _ in
                self?.viewModel.inApply.onNext(Void())
            }
            .disposed(by: bag)
        
        applyView.cleanUpButton.rx.tap
            .subscribe{[weak self] _ in
                self?.viewModel.inCleanUp.onNext(Void())
            }
            .disposed(by: bag)
        
        viewModel.outCloseSubFilterVC
            .take(1)
            .subscribe{[weak self] _ in
                self?.navigationController?.popViewController(animated: true)
            }
            .disposed(by: bag)
        
        viewModel.filterActionDelegate?.showApplyViewEvent()
            .bind(onNext: {[weak self] isShow in
                guard let `self` = self else {return}
                self.applyViewBottomCon.constant = isShow ? 0 : self.applyView.frame.height
                self.view.layoutIfNeeded()
            })
            .disposed(by: bag)
    }
    
    
    private func bindWaitEvent(){
        waitContainer.frame = CGRect(x: view.center.x, y: view.center.y, width: 80, height: 80)
        waitContainer.backgroundColor = .lightGray
        waitContainer.center = self.view.center
        waitActivityView.frame = CGRect(x: 0, y: 0, width: 80, height: 80)
        waitContainer.isHidden = true
        waitContainer.addSubview(waitActivityView)
        view.addSubview(waitContainer)
        
        viewModel.filterActionDelegate?.wait()
            .filter({[.enterSubFilter].contains($0.0)})
            .takeWhile({$0.1 == true})
            .subscribe(onNext: {[weak self] res in
                guard let `self` = self else {return}
                print("start wait")
                self.startWait()
                },
                       onCompleted: {
                        self.stopWait()
            })
            .disposed(by: bag)
    }
    
    
    private func startWait() {
        tableView.isHidden = true
        waitContainer.isHidden = false
        waitActivityView.startAnimating()
    }
    
    private func stopWait(){
        tableView.isHidden = false
        waitContainer.isHidden = true
        waitActivityView.stopAnimating()
    }
    
}


extension SubFilterSectionVC: UITableViewDelegate {
    override func didMove(toParent parent: UIViewController?) {
        if parent == nil {
            viewModel.backEvent.onCompleted()
        }
    }
}
