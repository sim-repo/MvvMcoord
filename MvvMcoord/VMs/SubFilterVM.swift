import Foundation
import RxSwift
import RxCocoa
import RxDataSources





class SubFilterVM : BaseVM {
    
    // MARK: - when init. Output to ViewController
    var outModels = Variable<[SubfilterModel?]>([])
    var outModelSections = Variable< [SectionOfSubFilterModel]? >(nil)
    var outFilterEnum = Variable<FilterEnum>(.select)
    var outDidUpdateParentVC = PublishSubject<Void>()
    
    // MARK: - during user activies. Input from ViewController
    var inSelectModel = PublishSubject<Int>()
    var inDeselectModel = PublishSubject<Int>()
    var inApply = PublishSubject<CoordRetEnum>()
    var inCleanUp = PublishSubject<Void>()
    
    var filterId = 0
    
    init(filterId: Int = 0){
        super.init()
        self.filterId = filterId
        
        bindData()
        bindSelection()
        bindUserActivities()
    }
    
    //network or local request
    public func bindData(){
        
        let subFilters = SubfilterModel.nerworkRequest(filterId: filterId)
        
        subFilters
            .bind(to: outModels)
            .disposed(by: bag)
        
        let subFilters2 = SubfilterModel.nerworkRequestSection(filterId: filterId)
        
        subFilters2
            .bind(to: outModelSections)
            .disposed(by: bag)
        
        
        let filterEnum = SubfilterModel.getFilterEnum(filterId: filterId)
        
        filterEnum
            .bind(to: outFilterEnum)
            .disposed(by: bag)
    }
    
    private func bindSelection(){
        inSelectModel
            .subscribe(onNext: {id in
                SubfilterModel.localSelectSubFilter(subFilterId: id, selected: true)
            })
            .disposed(by: bag)
        
        inDeselectModel
            .subscribe(onNext: {id in
                SubfilterModel.localSelectSubFilter(subFilterId: id, selected: false)
            })
            .disposed(by: bag)
    }
    
    private func bindUserActivities(){
        
        inApply
            .subscribe(onNext: {[weak self] _ in
                if let `self` = self {
                    // SubFilterVM не знает когда вызывать outDidUpdateParentVC, нужен рефакторинг
                    SubfilterModel.applySubFilters(filterId: self.filterId)
                    self.outDidUpdateParentVC.onCompleted()
                }
            })
            .disposed(by: bag)
        
        inCleanUp
            .subscribe(onCompleted: {
                print("clean up")
            })
            .disposed(by: bag)
    }
    
    public func isCheckmark(subFilterId: Int)->Bool {
        return SubfilterModel.localSelectedSubFilter(subFilterId: subFilterId)
    }
    
}
