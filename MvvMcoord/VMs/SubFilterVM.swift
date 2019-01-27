import Foundation
import RxSwift
import RxCocoa
import RxDataSources



class SubFilterVM : BaseVM {
    
    // MARK: - when init. Output to ViewController
    var filterEnum: FilterEnum = .select
    var outCloseVC = PublishSubject<Void>()
    
    // MARK: - during user activies. Input from ViewController
    var inApply = PublishSubject<Void>()
    var inCleanUp = PublishSubject<Void>()
    
    var filterId = 0
    public weak var filterActionDelegate: FilterActionDelegate?
    
    init(filterId: Int = 0, filterActionDelegate: FilterActionDelegate?){
        super.init()
        self.filterId = filterId
        self.filterActionDelegate = filterActionDelegate
        self.filterEnum = filterActionDelegate?.getFilterEnum(filterId: filterId) ?? .select
        bindUserActivities()
    }
    
    private func bindUserActivities(){
        
        inApply
            .subscribe(onCompleted: {
                    self.filterActionDelegate?.applyFromSubFilterEvent().onNext(self.filterId)
                    self.outCloseVC.onCompleted()
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
