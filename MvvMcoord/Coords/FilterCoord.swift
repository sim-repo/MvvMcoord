import UIKit
import RxSwift

class FilterCoord : BaseCoord<Void>{
    
    private var rootViewController: UIViewController?
    private var viewController: FilterVC!
    private var categoryId: Int
    
    
    init(rootViewController: UIViewController? = nil, categoryId: Int){
        self.rootViewController = rootViewController
        self.categoryId = categoryId
    }
    
    
    override func start() -> Observable<Void> {
        viewModel = FilterVM(categoryId: categoryId)
        viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "FilterVC") as? FilterVC
        
        guard let vm = viewModel as? FilterVM
            else { fatalError("view model") }
        
        viewController.viewModel = vm
        
        
        vm.outShowSubFilters
            .flatMap{[weak self] filterId -> Observable<Void> in
                guard let `self` = self else { return .empty() }
                return self.showSubFilters(on: self.viewController, filterId: filterId)
            }
            .subscribe()
            .disposed(by: self.disposeBag)
        
        
        
        if rootViewController != nil {
            rootViewController?.navigationController?.pushViewController(viewController, animated: true)
        }
        
        return Observable
            .merge(back)
    }
    
    
    private func showSubFilters(on rootViewController: UIViewController, filterId: Int) -> Observable<Void> {
        let nextCoord = SubFilterCoord(rootViewController: rootViewController, filterId: filterId)
        return coordinate(coord: nextCoord)
    }
}
