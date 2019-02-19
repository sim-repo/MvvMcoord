import Foundation
import RxSwift
import RxCocoa


class FilterVM : BaseVM {
    
    // MARK: - during user activies. Input from ViewController
    public var inSelectFilter = PublishSubject<Int>()
    public var inApply = PublishSubject<Void>()
    public var inCleanUp = PublishSubject<Void>()
    public var inRemoveFilter = PublishSubject<Int>()
    
    
    // MARK: - Outputs to ViewController or Coord
    public var outShowSubFilters = PublishSubject<Int>()
    public var outCloseVC = PublishSubject<Void>()
   
    var categoryId : Int
    
    public weak var filterActionDelegate: FilterActionDelegate?
    
    init(categoryId: Int = 0, filterActionDelegate: FilterActionDelegate?){
        self.categoryId = categoryId
        self.filterActionDelegate = filterActionDelegate
        super.init()

        bindSelection()
        bindUserActivities()
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
            .subscribe(onNext: {[weak self] _ in   // onNext need for unit-tests
                    self?.filterActionDelegate?.applyFromFilterEvent().onNext(Void())
                    self?.outCloseVC.onCompleted()
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
