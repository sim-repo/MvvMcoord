import Foundation
import RxSwift
import RxCocoa


class FilterVM : BaseVM {
    
    // MARK: - Inputs from ViewController
    var inSelectFilter = PublishSubject<Int>()
    
    // MARK: - Outputs to ViewController or Coord
    var outFilters = Variable<[FilterModel]?>(nil)
    var outShowSubFilters = PublishSubject<Int>()
    
    
    init(categoryId: Int = 0){
        super.init()
        //network request
        let filters = FilterModel.nerworkRequest(categoryId: categoryId)
        
        filters
        .bind(to: outFilters)
        .disposed(by: bag)
        
        
        inSelectFilter
            .subscribe(
                onNext: {[weak self] filterId in
                    //local request
                    self?.outShowSubFilters.onNext(filterId)
                }
            )
            .disposed(by: bag)
    }
}
