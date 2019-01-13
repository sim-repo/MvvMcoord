import UIKit
import RxCocoa
import RxSwift
import RxDataSources

class FilterVC: UIViewController {

    @IBOutlet weak var containerView: UIView!
    var viewModel: FilterVM!
    var bag = DisposeBag()
    @IBOutlet weak var tableView: UITableView!
    fileprivate var indexPaths: Set<IndexPath> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        registerTableView()
        bindingCell()
        setupNavigation()
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 44
        tableView.contentInset = UIEdgeInsets(top: 20.0, left: 0.0, bottom: 0.0, right: 0.0)
    }
    
    deinit {
        print("deinit FilterVC")
    }
    
    private func registerTableView(){
        tableView.rx.setDelegate(self)
            .disposed(by: bag)
    }
    
    private func bindingCell(){
        viewModel.outFilters
            .asObservable()
            .map{ filters in
                return filters ?? []
            }
            .bind(to: self.tableView.rx.items) { [weak self] tableView, index, model in
                
                
                let indexPath = IndexPath(item: index, section: 0)
                switch model.filterEnum {
                case .range:
                    guard let cell = tableView.dequeueReusableCell(withIdentifier: "FilterCell", for: indexPath) as? FilterCell else { return (UITableViewCell()) }
                    cell.configCell(model: model)
                    cell.state = self!.cellIsExpanded(at: indexPath) ? .expanded : .collapsed
                    return cell
                case .select:
                    guard let cell = tableView.dequeueReusableCell(withIdentifier: "FilterCellSelect", for: indexPath) as? FilterCellSelect else { return (UITableViewCell()) }
                    cell.configCell(model: model)
                    return cell
                case .section:
                    guard let cell = tableView.dequeueReusableCell(withIdentifier: "FilterCellSection", for: indexPath) as? FilterCellSection else { return (UITableViewCell()) }
                    cell.configCell(model: model)
                    return cell
                }
            }.disposed(by: bag)
        
        
        bindingRowSelected()
       
        self.tableView.reloadData()
    }
    
    
    func bindingRowSelected(){
        
        tableView.rx.itemSelected
            .subscribe(onNext: {[weak self] indexPath  in
                let cell = self!.tableView.cellForRow(at: indexPath)
                
                switch cell {
                    case is FilterCellSelect:
                        self!.tableView.deselectRow(at: indexPath, animated: true)
                        self!.viewModel.inSelectFilter.onNext(indexPath.row)
                    
                    case is FilterCell:
                        if let `cell` = cell as? FilterCell {
                            cell.state = .expanded
                            self!.addExpandedIndexPath(indexPath)
                        }
                    case is FilterCellSection:
                        self!.viewModel.inSelectFilter.onNext(indexPath.row)
                
                    default:
                        print("bindingRowSelected err")
                }
                self!.tableView.beginUpdates()
                self!.tableView.endUpdates()
            })
            .disposed(by: bag)
        
        
        
        tableView.rx.itemDeselected
            .subscribe(onNext: {[weak self] indexPath  in
                let cell = self!.tableView.cellForRow(at: indexPath)
                switch cell {
                case is FilterCellSelect:
                    print("bindingRowSelected must implement")
                case is FilterCell:
                    if let `cell` = cell as? FilterCell {
                        cell.state = .collapsed
                        self!.removeExpandedIndexPath(indexPath)
                    }
                default:
                   print("bindingRowSelected err")
                }
                self!.tableView.beginUpdates()
                self!.tableView.endUpdates()
            })
            .disposed(by: bag)
    }
    
    
    
    func cellIsExpanded(at indexPath: IndexPath) -> Bool {
        return indexPaths.contains(indexPath)
    }
    
    func addExpandedIndexPath(_ indexPath: IndexPath) {
        indexPaths.insert(indexPath)
    }
    
    func removeExpandedIndexPath(_ indexPath: IndexPath) {
        indexPaths.remove(indexPath)
    }
    
    
    private func setupNavigation(){
        navigationController?.navigationBar.tintColor = UIColor.white
        setAttributedTitle()
    }
    
    private func setAttributedTitle(){
        let title = "Фильтры"
        
        let navLabel = UILabel()
        let navTitle = NSMutableAttributedString(string: title, attributes:[
            NSAttributedString.Key.foregroundColor: UIColor.white,
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 17.0, weight: UIFont.Weight.light)])
        
        navLabel.attributedText = navTitle
        self.navigationItem.titleView = navLabel
    }
    
}


extension FilterVC: UITableViewDelegate {
    override func didMove(toParent parent: UIViewController?) {
        if parent == nil {
            viewModel.backEvent.onCompleted()
        }
    }
}
