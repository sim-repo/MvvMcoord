import UIKit
import RxSwift

class SubFilterCoord : BaseCoord<CoordRetEnum>{
    
    private var rootViewController: UIViewController?
    private var viewController: UIViewController!
    private var filterId: Int
    
    
    init(rootViewController: UIViewController? = nil, filterId: Int){
        self.rootViewController = rootViewController
        self.filterId = filterId
    }
    
    
    override func start() -> Observable<CoordRetEnum> {
        viewModel = SubFilterVM(filterId: filterId)
        
        guard let vm = viewModel as? SubFilterVM
            else { fatalError("view model") }

        vm.outFilterEnum
        .asObservable()
            .subscribe(onNext: { [weak self] filterType in
                switch filterType {
                case .section:
                    let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SubFilterSectionVC") as! SubFilterSectionVC
                    vc.viewModel = vm
                    self?.viewController = vc
                case .select:
                    let vc =  UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SubFilterSelectVC") as! SubFilterSelectVC
                    vc.viewModel = vm
                    self?.viewController = vc
                default:
                    let vc =  UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SubFilterSelectVC") as! SubFilterSelectVC
                    vc.viewModel = vm
                    self?.viewController = vc
                }
            })
        .disposed(by: disposeBag)

        
        if rootViewController != nil {
            rootViewController?.navigationController?.pushViewController(viewController, animated: true)
        }
        
        return Observable
            .amb([vm.backEvent, vm.inApply])
            .take(1)
    }
}
