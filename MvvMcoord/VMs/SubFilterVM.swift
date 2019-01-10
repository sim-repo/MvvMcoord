import Foundation
import RxSwift
import RxCocoa
import RxDataSources

class SubFilterVM : BaseVM {
    
    // MARK: - Inputs from ViewController

    
    // MARK: - Outputs to ViewController or Coord
    var outSubFilters = Variable<[SubfilterModel]?>(nil)
    var outSubFiltersSection = Variable< [SectionOfSubFilterModel]? >(nil)
    var outFilterEnum = Variable<FilterEnum>(.select)
    
    
    init(filterId: Int = 0){
        super.init()
        //network request
        let subFilters = SubfilterModel.nerworkRequest(filterId: filterId)
        
        subFilters
            .bind(to: outSubFilters)
            .disposed(by: bag)
        
        
        //network request
        let subFilters2 = SubfilterModel.nerworkRequestSection(filterId: filterId)
        
        subFilters2
            .bind(to: outSubFiltersSection)
            .disposed(by: bag)
        
        
        let filterEnum = SubfilterModel.getFilterEnum(filterId: filterId)
        
        filterEnum
            .bind(to: outFilterEnum)
            .disposed(by: bag)
        

    }
}
