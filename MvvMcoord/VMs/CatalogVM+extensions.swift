import Foundation
import RxSwift
import RxCocoa

protocol FilterActionDelegate : class {
    func applyFromFilterEvent() -> PublishSubject<Void>
    func applyFromSubFilterEvent() -> PublishSubject<Int>
    func removeFilterEvent() -> PublishSubject<Int>
    func filtersEvent() -> BehaviorSubject<[FilterModel?]>
    func requestFilters(categoryId: Int)
    func subFiltersEvent() -> BehaviorSubject<[SubfilterModel?]>
    func requestSubFilters(filterId: Int)
    func sectionSubFiltersEvent() -> BehaviorSubject<[SectionOfSubFilterModel]>
    func selectSubFilterEvent() -> PublishSubject<(Int, Bool)>
    func appliedTitle(filterId: Int) -> String
    func isSelectedSubFilter(subFilterId: Int) -> Bool
    func getTitle(filterId: Int) -> String
    func getFilterEnum(filterId: Int)->FilterEnum
    func cleanupFromFilterEvent() -> PublishSubject<Void>
    func cleanupFromSubFilterEvent() -> PublishSubject<Int>
    func requestComplete() -> PublishSubject<Int>
    func showApplyingViewEvent() -> BehaviorSubject<Bool>
    func refreshedCellSelectionsEvent()->PublishSubject<Set<Int>>
    func wait() -> BehaviorSubject<(FilterActionEnum, Bool)>
}



// MARK: -------------- implements FilterActionDelegate --------------
extension CatalogVM : FilterActionDelegate {
    
    
    convenience init(categoryId: Int) {
        self.init(categoryId: categoryId, fetchLimit: 0, currentPage: 1, totalPages: 0, totalItems: 0)
        handleDelegate()
    }
    
    
    func requestFilters(categoryId:Int) {
        if (prevState != currState) {
            wait().onNext((.enterFilter, true))
            NetworkMgt.requestFullFilterEntities(categoryId: categoryId)
            prevState = currState
        }
        midAppliedSubFilters = appliedSubFilters // crytical! зависит работа applySubfilter
        selectedSubFilters = appliedSubFilters // crytical! зависит работа applySubfilter
    }
    
    func requestSubFilters(filterId: Int) {
        wait().onNext((.enterSubFilter, true))
        showCleanSubFilterVC(filterId: filterId)
        NetworkMgt.requestEnterSubFilter(filterId: filterId, appliedSubFilters: self.midAppliedSubFilters)
    }
    
    func removeFilterEvent() -> PublishSubject<Int> {
        return inRemoveFilterEvent
    }
    
    func filtersEvent() -> BehaviorSubject<[FilterModel?]> {
        return outFiltersEvent
    }
    
    func subFiltersEvent() -> BehaviorSubject<[SubfilterModel?]> {
        return outSubFiltersEvent
    }
    
    func applyFromFilterEvent() -> PublishSubject<Void> {
        return inApplyFromFilterEvent
    }
    
    func applyFromSubFilterEvent() -> PublishSubject<Int> {
        return inApplyFromSubFilterEvent
    }
    
    func requestComplete() -> PublishSubject<Int> {
        return outRequestComplete
    }
    
    func sectionSubFiltersEvent() -> BehaviorSubject<[SectionOfSubFilterModel]> {
        return outSectionSubFiltersEvent
    }
    
    func selectSubFilterEvent() -> PublishSubject<(Int, Bool)> {
        return inSelectSubFilterEvent
    }
    
    func cleanupFromFilterEvent() -> PublishSubject<Void> {
        return inCleanUpFromFilterEvent
    }
    
    func cleanupFromSubFilterEvent() -> PublishSubject<Int> {
        return inCleanUpFromSubFilterEvent
    }
    
    func showApplyingViewEvent() -> BehaviorSubject<Bool> {
        return outShowApplyingViewEvent
    }
    
    func refreshedCellSelectionsEvent() -> PublishSubject<Set<Int>> {
        return outRefreshedCellSelectionsEvent
    }
    
    func wait() -> BehaviorSubject<(FilterActionEnum, Bool)> {
        return outWaitEvent
    }
    
    
    func appliedTitle(filterId: Int) -> String {
        var res = ""
        let arr = midAppliedSubFilters
            .compactMap({subFilters[$0]})
            .filter({$0.filterId == filterId && $0.enabled == true})
        
        arr.forEach({ subf in
            res.append(subf.title + ",")
        })
        if res.count > 0 {
            res.removeLast()
        }
        return res
    }
    
    func isSelectedSubFilter(subFilterId: Int) -> Bool {
        var res = false
        res = selectedSubFilters.contains(subFilterId) || midAppliedSubFilters.contains(subFilterId) //appliedSubFilters.contains(subFilterId)
        return res
    }
    
    func getTitle(filterId: Int) -> String {
        guard
            let filter = filters[filterId]
            else { return ""}
        
        return filter.title
    }
    
    func getFilterEnum(filterId: Int)->FilterEnum {
        guard
            let filter = filters[filterId]
            else { return .select}
        
        return filter.filterEnum
    }
    
    
    
    private func handleDelegate(){
        
        inApplyFromFilterEvent
            .subscribe(onNext: {[weak self] _ in
                if let `self` = self {
                    
                    let midApplying = self.midAppliedSubFilters.subtracting(self.unapplying)
                    
                    
                    if midApplying.count == 0 && self.selectedSubFilters.count == 0{
                        self.resetFilters()
                        return
                    }
                    self.showCleanFilterVC()
                    self.unapplying.removeAll()
                    self.wait().onNext((.applyFilter, true))
                    NetworkMgt.requestApplyFromFilter(categoryId: self.categoryId, appliedSubFilters: midApplying, selectedSubFilters: self.selectedSubFilters)
                }
            })
            .disposed(by: bag)
        
        inApplyFromSubFilterEvent
            .subscribe(onNext: {[weak self] filterId in
                if let `self` = self {
                    let midApplying = self.midAppliedSubFilters.subtracting(self.unapplying)
                    self.wait().onNext((.applySubFilter, true))
                    self.unapplying.removeAll()
                    self.showCleanFilterVC()
                    NetworkMgt.requestApplyFromSubFilter(filterId: filterId, appliedSubFilters: midApplying, selectedSubFilters: self.selectedSubFilters)
                }
            })
            .disposed(by: bag)
        
        inRemoveFilterEvent
            .subscribe(onNext: {[weak self] filterId in
                if let `self` = self {
                    self.wait().onNext((.removeFilter, true))
                    let midApplying = self.midAppliedSubFilters
                    self.unapplying.removeAll()
                    NetworkMgt.requestRemoveFilter(filterId: filterId, appliedSubFilters: midApplying, selectedSubFilters: self.selectedSubFilters)
                }
            })
            .disposed(by: bag)
        
        inSelectSubFilterEvent
            .subscribe(onNext: {[weak self] (subFilterId, selected) in
                self?.selectSubFilter(subFilterId: subFilterId, selected: selected)
            })
            .disposed(by: bag)
        
        
        inCleanUpFromFilterEvent
            .subscribe(onNext: {[weak self] _ in
                if let `self` = self {
                    self.resetFilters()
                    self.unitTestSignalOperationComplete.onNext(self.utMsgId)
                }
            })
            .disposed(by: bag)
        
        
        inCleanUpFromSubFilterEvent
            .subscribe(onNext: {[weak self] filterId in
                guard let `self` = self else { return }
                guard let ids = self.subfiltersByFilter[filterId] else { return }
                
                let res = Set(ids).intersection(self.selectedSubFilters)
                
                self.outRefreshedCellSelectionsEvent.onNext(res)
                
                for id in ids {
                    self.selectSubFilter(subFilterId: id, selected: false)
                }
                self.unitTestSignalOperationComplete.onNext(self.utMsgId)
            })
            .disposed(by: bag)
        
        
        NetworkMgt.outFilterEntitiesResponse
            .skip(1)
            .subscribe(onNext: { [weak self] res in
                guard let `self` = self else {return}
                
                let filters = res.0
                let subFilters = res.1
                self.filters.removeAll()
                self.filters = Dictionary(uniqueKeysWithValues: filters.compactMap({$0}).map{ ($0.id, $0) })
                self.subfiltersByFilter.removeAll()
                subFilters.forEach{ subf in
                    if self.subfiltersByFilter[subf.filterId] == nil {
                        self.subfiltersByFilter[subf.filterId] = []
                    }
                    self.subfiltersByFilter[subf.filterId]?.append(subf.id)
                    self.subFilters[subf.id] = subf
                }
                self.fillSectionSubFilters()
                
                self.outFiltersEvent.onNext(self.getEnabledFilters())
                self.wait().onNext((.enterFilter, false))
                
                self.unitTestSignalOperationComplete.onNext(self.utMsgId)
            })
            .disposed(by: bag)
        
        
        NetworkMgt.outEnterSubFilterResponse
            .subscribe(onNext: {[weak self] res in
                guard let `self` = self else { return }
                let filterIds = res.1
                let countBySubfilterId = res.3
                self.enableSubFilters(ids: filterIds, countBySubfilterId: countBySubfilterId)
                self.midAppliedSubFilters = res.2
                self.subFiltersFromCache(filterId: res.0)
                self.wait().onNext((.enterSubFilter, false))
                
                self.unitTestSignalOperationComplete.onNext(self.utMsgId)
            })
            .disposed(by: bag)
        
        
        NetworkMgt.outApplyItemsResponse
            .subscribe(onNext: {[weak self] _filters in
                guard let `self` = self else {return}
                self.enableFilters(ids: _filters.0)
                self.enableSubFilters(ids: _filters.1)
                
                self.appliedSubFilters = _filters.2
                self.selectedSubFilters = _filters.3
                self.outFiltersEvent.onNext(self.getEnabledFilters())
                self.setupFetch(itemsIds: _filters.4)
                self.outReloadVC.onNext(Void())
                self.emitPrefetchEvent()
                self.wait().onNext((.applyFilter, false))
                
                self.unitTestSignalOperationComplete.onNext(self.utMsgId)
            })
            .disposed(by: bag)
        
        
        NetworkMgt.outApplyFiltersResponse
            .subscribe(onNext: {[weak self] _filters in
                guard let `self` = self else {return}
                self.enableFilters(ids: _filters.0)
                self.enableSubFilters(ids: _filters.1)
                self.midAppliedSubFilters = _filters.2
                self.selectedSubFilters = _filters.3
                let filters = self.getEnabledFilters()
                self.outFiltersEvent.onNext(filters)
                self.wait().onNext((.applySubFilter, false))
                
                self.unitTestSignalOperationComplete.onNext(self.utMsgId)
            })
            .disposed(by: bag)
        
        
        NetworkMgt.outCatalogModel
            .subscribe(onNext: {[weak self] res in
                guard let `self` = self else { return }
                self.inPrefetchEvent.onNext(res)
            })
            .disposed(by: bag)
    }
    
}
