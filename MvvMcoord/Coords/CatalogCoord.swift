import UIKit
import RxSwift

class CatalogCoord : BaseCoord<Void>{
    
    private var rootViewController: UIViewController?
    private var viewController: CatalogVC!
    private var categoryId: Int
    
    
    init(rootViewController: UIViewController? = nil, categoryId: Int){
        self.rootViewController = rootViewController
        self.categoryId = categoryId
    }
    
    
    override func start() -> Observable<Void> {
        viewModel = CatalogVM(categoryId: categoryId)
        viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CatalogVC") as? CatalogVC
        
        guard let vm = viewModel as? CatalogVM
            else { fatalError("view model") }

        viewController.viewModel = vm
        
        vm.outShowFilters
            .flatMap{[weak self] categoryId -> Observable<Void> in
                guard let `self` = self else { return .empty() }
                return self.showFilters(on: self.viewController, categoryId: categoryId)
            }
            .subscribe()
            .disposed(by: self.disposeBag)
        
        
        if rootViewController != nil {
            rootViewController?.navigationController?.pushViewController(viewController, animated: true)
        }
        
        return Observable
            .merge(back)
    }
    
    
    private func showFilters(on rootViewController: UIViewController, categoryId: Int) -> Observable<Void> {
        let nextCoord = FilterCoord(rootViewController: rootViewController, categoryId: categoryId)
        return coordinate(coord: nextCoord)
    }
}
