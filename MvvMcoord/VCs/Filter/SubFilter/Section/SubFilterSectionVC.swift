import UIKit
import RxSwift
import RxCocoa
import RxDataSources

class SubFilterSectionVC: UIViewController {
    
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
        let dataSource = RxTableViewSectionedReloadDataSource<SectionOfSubFilterModel>(
            configureCell: { dataSource, tableView, indexPath, model in
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "SubFilterSectionCell", for: indexPath) as? SubFilterSectionCell else { return (UITableViewCell()) }
                cell.configCell(model: model, isCheckmark: self.viewModel.isCheckmark(subFilterId: model.id))
                return cell
        })
        
        dataSource.titleForHeaderInSection = { dataSource, index in
            return dataSource.sectionModels[index].header
        }
        
        viewModel.outModelSections
            .asObservable()
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: bag)
    }
    
}


extension SubFilterSectionVC: UITableViewDelegate {
    override func didMove(toParent parent: UIViewController?) {
        if parent == nil {
            viewModel.backEvent.onCompleted()
        }
    }
}
