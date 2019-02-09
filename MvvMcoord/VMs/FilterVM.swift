import Foundation
import RxSwift
import RxCocoa


class FilterVM : BaseVM {
    
    // MARK: - during user activies. Input from ViewController
    var inSelectFilter = PublishSubject<Int>()
    var inApply = PublishSubject<Void>()
    var inCleanUp = PublishSubject<Void>()
    var inRemoveFilter = PublishSubject<Int>()
    
    
    // MARK: - Outputs to ViewController or Coord
    var outShowSubFilters = PublishSubject<Int>()
    var outCloseVC = PublishSubject<Void>()
    
    var categoryId : Int
    var filters: [Int:FilterModel] = [:] 
    
    public weak var filterActionDelegate: FilterActionDelegate?
    
    init(categoryId: Int = 0, filterActionDelegate: FilterActionDelegate?){
        self.categoryId = categoryId
        self.filterActionDelegate = filterActionDelegate
        super.init()

        bindSelection()
        bindUserActivities()
    }

    private func getEnabled()->[FilterModel] {
        return filters
            .compactMap({$0.value})
            .filter({$0.enabled == true})
            .sorted(by: {$0.id < $1.id })
    }
    
    public func appliedTitles(filterId: Int)->String {
        return self.filterActionDelegate?.appliedTitle(filterId: filterId) ?? ""
    }
    
    
    private func bindSelection(){
        inSelectFilter
            .subscribe(
                onNext: {[weak self] filterId in
                    self?.filterActionDelegate?.requestSubFilters(filterId: filterId)
                }
            )
            .disposed(by: bag)
        
        filterActionDelegate?.requestComplete()
            .bind { filterId in
                self.outShowSubFilters.onNext(filterId)
            }
            .disposed(by: bag)
    }
    
    private func bindUserActivities(){
        
        inApply
            .subscribe(onCompleted: {
                    self.filterActionDelegate?.applyFromFilterEvent().onNext(Void())
                    self.outCloseVC.onCompleted()
            })
            .disposed(by: bag)
        
        inCleanUp
            .subscribe(onCompleted: {
                self.filterActionDelegate?.cleanupFromFilterEvent().onNext(Void())
                self.outCloseVC.onCompleted()
            })
            .disposed(by: bag)
        
        inRemoveFilter
            .subscribe(onNext: {[weak self] filterId in
                if let `self` = self {
                    self.filterActionDelegate?
                        .removeFilterEvent()
                        .onNext(filterId)
                }
            })
            .disposed(by: bag)
    }
}
