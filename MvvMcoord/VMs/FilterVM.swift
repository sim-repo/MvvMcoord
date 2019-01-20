import Foundation
import RxSwift
import RxCocoa


class FilterVM : BaseVM {
    
    // MARK: - during user activies. Input from ViewController
    var inSelectFilter = PublishSubject<Int>()
    var inApply = PublishSubject<CoordRetEnum>()
    var inCleanUp = PublishSubject<Void>()
    var inRemoveFilter = PublishSubject<Int>()
    
    
    // MARK: - Outputs to ViewController or Coord
    var outFilters = Variable<[FilterModel?]>([])
    var outShowSubFilters = PublishSubject<Int>()
    var outDidUpdateParentVC = PublishSubject<Void>()
    
    var categoryId : Int
    
    init(categoryId: Int = 0){
        self.categoryId = categoryId
        super.init()
        
        bindData()
        bindSelection()
        bindUserActivities()
    }
    
    //network or local request
    public func bindData(){
        let filters = FilterModel.localRequest(categoryId: categoryId)
        
        filters
            .bind(to: outFilters)
            .disposed(by: bag)
    }
    
    public func appliedTitles(filterId: Int)->String {
        return FilterModel.localAppliedTitles(filterId: filterId)
    }
    
    private func bindSelection(){
        inSelectFilter
            .subscribe(
                onNext: {[weak self] filterId in
                    //local request
                    self?.outShowSubFilters.onNext(filterId)
                }
            )
            .disposed(by: bag)
    }
    
    private func bindUserActivities(){
        
        inApply
            .subscribe(onNext: {[weak self] _ in
                if let `self` = self {
                    FilterModel.applyFilters()
                    self.outDidUpdateParentVC.onCompleted()
                }
            })
            .disposed(by: bag)
        
        inCleanUp
            .subscribe(onCompleted: {
                print("clean up")
            })
            .disposed(by: bag)
        
        inRemoveFilter
            .subscribe(onNext: {[weak self] filterId in
                FilterModel.removeFilter(filterId: filterId)
                self?.bindData()
            })
            .disposed(by: bag)
    }
}
