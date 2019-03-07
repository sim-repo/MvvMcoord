import UIKit
import RxSwift

class SubFilterCoord : BaseCoord<CoordRetEnum>{
    
    private var rootViewController: UIViewController?
    private var viewController: UIViewController!
    private var filterId: FilterId
    private weak var filterActionDelegate: FilterActionDelegate?
    
    init(rootViewController: UIViewController? = nil, filterId: FilterId, filterActionDelegate: FilterActionDelegate?){
        self.rootViewController = rootViewController
        self.filterId = filterId
        self.filterActionDelegate = filterActionDelegate
    }
    
    
    override func start() -> Observable<CoordRetEnum> {
        viewModel = SubFilterVM(filterId: filterId, filterActionDelegate: filterActionDelegate)
        
        guard let vm = viewModel as? SubFilterVM
            else { fatalError("view model") }

        
                switch vm.filterEnum {
                case .section:
                    let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SubFilterSectionVC") as! SubFilterSectionVC
                    vc.viewModel = vm
                    viewController = vc
                case .select:
                    let vc =  UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SubFilterSelectVC") as! SubFilterSelectVC
                    vc.viewModel = vm
                    viewController = vc
                default:
                    let vc =  UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SubFilterSelectVC") as! SubFilterSelectVC
                    vc.viewModel = vm
                    viewController = vc
                }

        
        if rootViewController != nil {
            rootViewController?.navigationController?.pushViewController(viewController, animated: true)
        }
        
        return Observable
            .amb([vm.backEvent])
            .take(1)
    }
}
