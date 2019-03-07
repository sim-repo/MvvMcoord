import Foundation
import RxSwift
import RxCocoa

class CategoryVM : BaseVM {    
    // MARK: - Inputs from ViewController
    var inSelectCategory = PublishSubject<CategoryId>()
    
    
    // MARK: - Outputs to ViewController or Coord
    var outCategories = BehaviorRelay<[CategoryModel]?>(value:nil)
    
    var outShowSubcategory = PublishSubject<CategoryId>()
    
    var outTitle = Variable<String>("")
    
    var outShowCatalog = PublishSubject<CategoryId>()
    
 
    var outCloseVC = PublishSubject<Void>()
    
    init(parentBaseId: CategoryId){
        super.init()
    
        let models = CategoryModel.getModelsA(baseId: parentBaseId).share()

        models
        .bind(onNext: {[weak self] data in
            self!.outCategories.accept(data)
        })
        .disposed(by: bag)
        
        CategoryModel.getTitle(baseId: parentBaseId)
        .bind(to: outTitle)
        .disposed(by: bag)
        
       inSelectCategory
            .subscribe(
                onNext: {[weak self] baseId in
                    if models2[baseId]?.last ?? true {
                        self?.outShowCatalog.onNext(baseId)
                    } else {
                        self?.outShowSubcategory.onNext(baseId)
                    }
                }
            )
            .disposed(by: bag)
    }
}
