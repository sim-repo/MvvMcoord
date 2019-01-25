import Foundation
import RxSwift
import RxCocoa
import RxDataSources



class SubFilterVM : BaseVM {
    
    // MARK: - when init. Output to ViewController
    var outModels = Variable<[SubfilterModel?]>([])
    var outModelSections = Variable<[SectionOfSubFilterModel]>([])
    var filterEnum: FilterEnum = .select
    var outCloseVC = PublishSubject<Void>()
    
    // MARK: - during user activies. Input from ViewController
    var inSelectModel = PublishSubject<Int>()
    var inDeselectModel = PublishSubject<Int>()
    var inApply = PublishSubject<CoordRetEnum>()
    var inCleanUp = PublishSubject<Void>()
    
    var filterId = 0
    private weak var filterActionDelegate: FilterActionDelegate?
    
    init(filterId: Int = 0, filterActionDelegate: FilterActionDelegate?){
        super.init()
        self.filterId = filterId
        self.filterActionDelegate = filterActionDelegate
        self.filterEnum = filterActionDelegate?.getFilterEnum(filterId: filterId) ?? .select
        bindData()
        bindSelection()
        bindUserActivities()
    }
    
    public func bindData(){
        
        filterActionDelegate?.subFiltersEvent()
            .bind(to: outModels)
            .disposed(by: bag)
        
        
        filterActionDelegate?.sectionSubFiltersEvent()
            .bind(to: outModelSections)
            .disposed(by: bag)

    }
    
    private func bindSelection(){
        
        inSelectModel
            .subscribe(onNext: {[weak self] id in
                self?.filterActionDelegate?.selectSubFilterEvent().onNext((id, true))
            })
            .disposed(by: bag)
        
        
        inDeselectModel
            .subscribe(onNext: {[weak self] id in
                self?.filterActionDelegate?.selectSubFilterEvent().onNext((id, false))
            })
            .disposed(by: bag)
    }
    
    private func bindUserActivities(){
        
        inApply
            .subscribe(onNext: {[weak self] _ in
                if let `self` = self {
                    self.filterActionDelegate?.applyFromSubFilterEvent().onNext(self.filterId)
                    self.outCloseVC.onCompleted()
                }
            })
            .disposed(by: bag)
        
        inCleanUp
            .subscribe(onCompleted: {
                print("clean up")
            })
            .disposed(by: bag)
    }
    
    public func isCheckmark(subFilterId: Int) -> Bool {
        return self.filterActionDelegate?.isSelectedSubFilter(subFilterId: subFilterId) ?? false
    }
    
}
