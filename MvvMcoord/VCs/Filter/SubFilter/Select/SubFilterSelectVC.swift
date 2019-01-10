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
    }
    
    
    private func registerTableView(){
        tableView.rx.setDelegate(self)
            .disposed(by: bag)
    }
    
    private func bindingCell(){
        viewModel.outSubFilters
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
    
    
 
    
}


extension SubFilterSelectVC: UITableViewDelegate {
    override func didMove(toParent parent: UIViewController?) {
        if parent == nil {
            viewModel.inBackEvent.onCompleted()
        }
    }
}
