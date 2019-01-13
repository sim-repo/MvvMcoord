import UIKit
import RxSwift
import RxCocoa
import RxDataSources

class SubFilterSelectVC: UIViewController {
    
    var viewModel: SubFilterVM!
    var bag = DisposeBag()
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        registerTableView()
        bindingCell()
        bindingRowSelected()
    }
    
    deinit {
        print("deinit SubFilterSelectVC")
    }
    
    private func registerTableView(){
        tableView.rx.setDelegate(self)
            .disposed(by: bag)
    }
    
    private func bindingCell(){
        viewModel.outModels
            .asObservable()
            .map{ filters in
                return filters ?? []
            }
            .bind(to: self.tableView.rx.items) { tableView, index, model in
                let indexPath = IndexPath(item: index, section: 0)
                let cell = tableView.dequeueReusableCell(withIdentifier: "SubFilterSelectCell", for: indexPath) as! SubFilterSelectCell
                
                cell.configCell(model: model)
                return cell
            }
            .disposed(by: bag)
    }
    
    
    func bindingRowSelected(){
        
        tableView.rx.itemSelected
            .subscribe(onNext: {[weak self] indexPath  in
               let cell = self!.tableView.cellForRow(at: indexPath) as! SubFilterSelectCell
                if cell.selectedCell() {
                    self?.viewModel.inSelectModel.onNext(cell.id)
                } else {
                    self?.viewModel.inDeselectModel.onNext(cell.id)
                }
            })
            .disposed(by: bag)
    }
}


extension SubFilterSelectVC: UITableViewDelegate {
    override func didMove(toParent parent: UIViewController?) {
        if parent == nil {
            viewModel.backEvent.onCompleted()
        }
    }
}
