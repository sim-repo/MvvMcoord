import Foundation
import RxSwift
import RxCocoa
import RxDataSources





class SubFilterVM : BaseVM {
    
    // MARK: - when init. Output to ViewController
    var outModels = Variable<[SubfilterModel]?>(nil)
    var outModelSections = Variable< [SectionOfSubFilterModel]? >(nil)
    var outFilterEnum = Variable<FilterEnum>(.select)
    
    
    // MARK: - during user activies. Input from ViewController
    var inSelectModel = PublishSubject<Int>()
    var inDeselectModel = PublishSubject<Int>()
    
    
    init(filterId: Int = 0){
        super.init()
        
        //network request
        let subFilters = SubfilterModel.nerworkRequest(filterId: filterId)
        
        subFilters
            .bind(to: outModels)
            .disposed(by: bag)
        
        
        //network request
        let subFilters2 = SubfilterModel.nerworkRequestSection(filterId: filterId)
        
        subFilters2
            .bind(to: outModelSections)
            .disposed(by: bag)
        
        
        let filterEnum = SubfilterModel.getFilterEnum(filterId: filterId)
        
        filterEnum
            .bind(to: outFilterEnum)
            .disposed(by: bag)
        
        bindUserActivities()
    }
    
    
    func bindUserActivities(){
        
        inSelectModel
            .subscribe(onNext: {row in
                SubfilterModel.localSelectSubFilter(subFilterId: row, selected: true)
            })
            .disposed(by: bag)
        
        inDeselectModel
            .subscribe(onNext: {row in
                SubfilterModel.localSelectSubFilter(subFilterId: row, selected: false)
            })
            .disposed(by: bag)
    }
}
