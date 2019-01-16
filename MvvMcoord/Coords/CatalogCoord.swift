import UIKit
import RxSwift

class CatalogCoord : BaseCoord<CoordRetEnum>{
    
    private var rootViewController: UIViewController?
    private var viewController: CatalogVC!
    private var categoryId: Int
    
    
    init(rootViewController: UIViewController? = nil, categoryId: Int){
        self.rootViewController = rootViewController
        self.categoryId = categoryId
    }
    
    private func reload(){
        print("reload catalog")
        guard let vm = viewModel as? CatalogVM
            else { fatalError("view model") }
        vm.bindData()
    }
    
    override func start() -> Observable<CoordRetEnum> {
        viewModel = CatalogVM(categoryId: categoryId)
        viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CatalogVC") as? CatalogVC
        
        guard let vm = viewModel as? CatalogVM
            else { fatalError("view model") }

        viewController.viewModel = vm
        
        vm.outShowFilters
            .asObserver()
            .do(onNext: {[weak self] categoryId in
                if let `self` = self {
                    self.showFilters(on: self.viewController, categoryId: categoryId).asObservable()
                        .subscribe(onNext: {event in
                            switch event {
                            case .reloadData: self.reload()
                            case .back: print("back")
                            }
                        })
                        .disposed(by: self.disposeBag)
                }
            })
            .subscribe()
            .disposed(by: self.disposeBag)
        
        
        if rootViewController != nil {
            rootViewController?.navigationController?.pushViewController(viewController, animated: true)
        }
        
        return Observable
            .merge(vm.backEvent)
    }
    
    
    private func showFilters(on rootViewController: UIViewController, categoryId: Int) -> Observable<CoordRetEnum> {
        let nextCoord = FilterCoord(rootViewController: rootViewController, categoryId: categoryId)
        return coordinate(coord: nextCoord)
    }
}
