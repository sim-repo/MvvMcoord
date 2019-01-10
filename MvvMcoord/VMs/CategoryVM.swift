import Foundation
import RxSwift
import RxCocoa

class CategoryVM : BaseVM {    
    // MARK: - Inputs from ViewController
    var inSelectCategory = PublishSubject<Int>()
    
    
    // MARK: - Outputs to ViewController or Coord
    var outCategories = Variable<[CategoryModel]?>(nil)
    
    var outShowSubcategory = PublishSubject<Int>()
    
    var outTitle = Variable<String>("")
    
    var outShowCatalog = PublishSubject<Int>()
 
    init(parentBaseId: Int){
        super.init()
        //network request
        let models = CategoryModel.getModelsA(baseId: parentBaseId)

        models
        .bind(to: outCategories)
        .disposed(by: bag)
        
        CategoryModel.getTitle(baseId: parentBaseId)
        .bind(to: outTitle)
        .disposed(by: bag)
        

       inSelectCategory
            .subscribe(
                onNext: {[weak self] baseId in
                    //local request
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
