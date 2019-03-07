import Foundation
import RxSwift
import RxCocoa

protocol FilterActionDelegate : class {
    func applyFromFilterEvent() -> PublishSubject<Void>
    func applyFromSubFilterEvent() -> PublishSubject<FilterId>
    func removeFilterEvent() -> PublishSubject<FilterId>
    func filtersEvent() -> BehaviorSubject<[FilterModel?]>
    func requestFilters(categoryId: CategoryId)
    func subFiltersEvent() -> BehaviorSubject<[SubfilterModel?]>
    func requestSubFilters(filterId: FilterId)
    func sectionSubFiltersEvent() -> BehaviorSubject<[SectionOfSubFilterModel]>
    func selectSubFilterEvent() -> PublishSubject<(SubFilterId, Bool)>
    func appliedTitle(filterId: FilterId) -> String
    func isSelectedSubFilter(subFilterId: SubFilterId) -> Bool
    func getTitle(filterId: FilterId) -> String
    func getFilterEnum(filterId: FilterId)->FilterEnum
    func cleanupFromFilterEvent() -> PublishSubject<Void>
    func cleanupFromSubFilterEvent() -> PublishSubject<FilterId>
    func requestComplete() -> PublishSubject<FilterId>
    func showApplyViewEvent() -> BehaviorSubject<Bool>
    func showPriceApplyViewEvent() -> PublishSubject<Bool>
    func refreshedCellSelectionsEvent()->PublishSubject<Set<Int>>
    func applyByPrices() -> PublishSubject<Void>
    func getRangePrice()-> (MinPrice, MaxPrice, MinPrice, MaxPrice)
    func setTipRangePrice(minPrice: MinPrice, maxPrice: MaxPrice)
    func setUserRangePrice(minPrice: MinPrice, maxPrice: MaxPrice)
    func wait() -> BehaviorSubject<(FilterActionEnum, Bool)>
    func back() -> PublishSubject<FilterActionEnum>
    func getMidTotal() -> PublishSubject<Int>
    func calcMidTotal(tmpMinPrice: MinPrice, tmpMaxPrice: MaxPrice)
    func showApplyWarning() -> PublishSubject<Void>
    func reloadSubfilterVC() -> PublishSubject<Void>
}



// MARK: -------------- implements FilterActionDelegate --------------
extension CatalogVM : FilterActionDelegate {
   
    convenience init(categoryId: CategoryId) {
        self.init(categoryId: categoryId, fetchLimit: 0, currentPage: 1, totalPages: 0, totalItems: 0)
        wait().onNext((.prefetchCatalog, true))
        handleDelegate()
    }
    
    
    func requestFilters(categoryId: CategoryId) {
//        if readyGetFullEntities {
//            wait().onNext((.enterFilter, true))
//            getNetworkService().requestFullFilterEntities(categoryId: categoryId)
//        }
        
        if filters.count == 0 {
            wait().onNext((.enterFilter, true))
        }
        midAppliedSubFilters = appliedSubFilters // crytical! зависит работа applySubfilter
    }
    
    func requestSubFilters(filterId: FilterId) {
        wait().onNext((.enterSubFilter, true))
        showCleanSubFilterVC(filterId: filterId)
        DispatchQueue.global(qos: .userInitiated).async {[weak self] in
            guard let `self` = self else { return }
            getNetworkService().requestEnterSubFilter(categoryId: self.categoryId,
                                             filterId: filterId,
                                             appliedSubFilters: self.midAppliedSubFilters,
                                             rangePrice: self.rangePrice.getPricesWhenRequestSubFilters()
                                             )
        }
    }
    
    func removeFilterEvent() -> PublishSubject<FilterId> {
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
    
    func applyFromSubFilterEvent() -> PublishSubject<FilterId> {
        return inApplyFromSubFilterEvent
    }
    
    func applyByPrices() -> PublishSubject<Void> {
        return inApplyByPricesEvent
    }
    
    func requestComplete() -> PublishSubject<FilterId> {
        return outRequestComplete
    }
    
    func sectionSubFiltersEvent() -> BehaviorSubject<[SectionOfSubFilterModel]> {
        return outSectionSubFiltersEvent
    }
    
    func selectSubFilterEvent() -> PublishSubject<(SubFilterId, Bool)> {
        return inSelectSubFilterEvent
    }
    
    func cleanupFromFilterEvent() -> PublishSubject<Void> {
        return inCleanUpFromFilterEvent
    }
    
    func cleanupFromSubFilterEvent() -> PublishSubject<FilterId> {
        return inCleanUpFromSubFilterEvent
    }
    
    func showApplyViewEvent() -> BehaviorSubject<Bool> {
        return outShowApplyViewEvent
    }
    
    func showPriceApplyViewEvent() -> PublishSubject<Bool> {
        return outShowPriceApplyViewEvent
    }
    
    func showApplyWarning() -> PublishSubject<Void> {
        return outShowWarning
    }
    
    func refreshedCellSelectionsEvent() -> PublishSubject<Set<Int>> {
        return outRefreshedCellSelectionsEvent
    }
    
    func wait() -> BehaviorSubject<(FilterActionEnum, Bool)> {
        return outWaitEvent
    }
    
    func back() -> PublishSubject<FilterActionEnum> {
        return outBackEvent
    }
    
    func getRangePrice() -> (MinPrice, MaxPrice, MinPrice, MaxPrice) {
        return rangePrice.getRangePrice()
    }
    
    func setTipRangePrice(minPrice: MinPrice, maxPrice: MaxPrice) {
        rangePrice.setTipRangePrice(minPrice: minPrice, maxPrice: maxPrice)
    }
    
    func setUserRangePrice(minPrice: MinPrice, maxPrice: MaxPrice) {
        rangePrice.setUserRangePrice(minPrice: minPrice, maxPrice: maxPrice)
    }
    
    func getMidTotal() -> PublishSubject<Int> {
        return outMidTotal
    }
    
    func calcMidTotal(tmpMinPrice: MinPrice, tmpMaxPrice: MaxPrice) {
         let tmpRangePrice = RangePrice.shared.clone()
         tmpRangePrice.setUserRangePrice(minPrice: tmpMinPrice, maxPrice: tmpMaxPrice)
         let midApplying = self.midAppliedSubFilters.subtracting(self.unapplying)
         getNetworkService().requestMidTotal(categoryId: categoryId,
                                           appliedSubFilters: midApplying,
                                           selectedSubFilters: self.selectedSubFilters,
                                           rangePrice:  tmpRangePrice)
    }
    
    func reloadSubfilterVC() -> PublishSubject<Void> {
        return outReloadSubFilterVCEvent
    }
    
    func appliedTitle(filterId: FilterId) -> String {
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
    
    func isSelectedSubFilter(subFilterId: SubFilterId) -> Bool {
        var res = false
        res = selectedSubFilters.contains(subFilterId) || midAppliedSubFilters.contains(subFilterId) //appliedSubFilters.contains(subFilterId)
        return res
    }
    
    func getTitle(filterId: FilterId) -> String {
        guard
            let filter = filters[filterId]
            else { return ""}
        
        return filter.title
    }
    
    func getFilterEnum(filterId: FilterId) -> FilterEnum {
        guard
            let filter = filters[filterId]
            else { return .select}
        
        return filter.filterEnum
    }
    
    
 
    private func handleDelegate(){
        
        applyFromFilterEvent()
            .subscribe(onNext: {[weak self] _ in
                guard let `self` = self else { return }
                guard self.itemsTotal > 0
                    else {
                        self.showApplyWarning().onNext(Void())
                        return
                    }
                
                
                // check if new applying exists
                let united = self.midAppliedSubFilters.subtracting(self.unapplying).union(self.selectedSubFilters)
                guard united.subtracting(self.appliedSubFilters).count > 0 ||
                      self.appliedSubFilters.subtracting(united).count > 0
                else {
                    self.back().onNext(.closeFilter)
                    return
                }
                
                
                let midApplying = self.midAppliedSubFilters.subtracting(self.unapplying)
                if midApplying.count == 0 &&
                   self.selectedSubFilters.count == 0 &&
                   self.rangePrice.isUserChangedPriceFilter() == false {
                        self.resetFilters()
                        self.back().onNext(.closeFilter)
                        return
                }
                self.unapplying.removeAll()
                self.wait().onNext((.applyFilter, true))
                self.back().onNext(.closeFilter)
            
                DispatchQueue.global(qos: .background).async {
                    getNetworkService().requestApplyFromFilter(categoryId: self.categoryId,
                                                               appliedSubFilters: midApplying,
                                                               selectedSubFilters: self.selectedSubFilters,
                                                               rangePrice: self.rangePrice.getPricesWhenApplyFilter())
                }
            })
            .disposed(by: bag)
        
        
        applyFromSubFilterEvent()
            .subscribe(onNext: {[weak self] filterId in
                guard let `self` = self else { return }
                
                guard self.canApplyFromSubfilter == true
                    else {
                        self.back().onNext(.closeSubFilter)
                        self.unitTestSignalOperationComplete.onNext(self.utMsgId)
                        return
                    }
                self.back().onNext(.closeSubFilter)
                self.canApplyFromSubfilter = false
                let midApplying = self.midAppliedSubFilters.subtracting(self.unapplying)
                self.wait().onNext((.applySubFilter, true))
                self.unapplying.removeAll()
                self.cleanupFilterVC()
                DispatchQueue.global(qos: .background).async {
                    getNetworkService().requestApplyFromSubFilter(categoryId: self.categoryId,
                                                                  filterId: filterId,
                                                                  appliedSubFilters: midApplying,
                                                                  selectedSubFilters: self.selectedSubFilters,
                                                                  rangePrice: self.rangePrice.getPricesWhenApplySubFilter())
                }
            })
            .disposed(by: bag)
        
        
        applyByPrices()
            .subscribe(onNext: {[weak self] _ in
                guard let `self` = self else { return }
                DispatchQueue.global(qos: .background).async {
                    getNetworkService().requestApplyByPrices(categoryId: self.categoryId,
                                                    rangePrice: self.rangePrice.getPricesWhenApplyByPrices())
                }
            })
            .disposed(by: bag)
        
        
        removeFilterEvent()
            .subscribe(onNext: {[weak self] filterId in
                if let `self` = self {
                    self.wait().onNext((.removeFilter, true))
                    let midApplying = self.midAppliedSubFilters
                    self.unapplying.removeAll()
                    getNetworkService().requestRemoveFilter(categoryId: self.categoryId,
                                                   filterId: filterId,
                                                   appliedSubFilters: midApplying,
                                                   selectedSubFilters: self.selectedSubFilters,
                                                   rangePrice: self.rangePrice.getPricesWhenRemoveFilter()
                                                   )
                }
            })
            .disposed(by: bag)
        
        
        selectSubFilterEvent()
            .subscribe(onNext: {[weak self] (subFilterId, selected) in
                self?.selectSubFilter(subFilterId: subFilterId, selected: selected)
            })
            .disposed(by: bag)
        
        
        cleanupFromFilterEvent()
            .subscribe(onNext: {[weak self] _ in
                if let `self` = self {
                    self.resetFilters()
                    self.unitTestSignalOperationComplete.onNext(self.utMsgId)
                }
            })
            .disposed(by: bag)
        
        
        cleanupFromSubFilterEvent()
            .subscribe(onNext: {[weak self] filterId in
                guard let `self` = self else { return }
                
                self.back().onNext(.closeFilter)
                
                guard let ids = self.subfiltersByFilter[filterId] else { return }
                
                let res = Set(ids).intersection(self.selectedSubFilters)
                
                self.outRefreshedCellSelectionsEvent.onNext(res)
                
                for id in ids {
                    self.selectSubFilter(subFilterId: id, selected: false)
                }
                self.unitTestSignalOperationComplete.onNext(self.utMsgId)
            })
            .disposed(by: bag)
        
        
        getNetworkService().getFullFilterEntitiesEvent()
            .filter({$0.0.count > 0 && $0.1.count > 0})
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
                
                self.outFiltersEvent.onNext(self.getEnabledFilters())
                self.wait().onNext((.enterFilter, false))
                
                self.unitTestSignalOperationComplete.onNext(self.utMsgId)
            })
            .disposed(by: bag)
        
        
        getNetworkService().getEnterSubFilterEvent()
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
        
        
        getNetworkService().getApplyForItemsEvent()
            .subscribe(onNext: {[weak self] _filters in
                guard let `self` = self else { return }
                
                self.enableFilters(ids: _filters.0)
                self.enableSubFilters(ids: _filters.1)
                
                self.appliedSubFilters = _filters.2
                self.midAppliedSubFilters = _filters.2 // last added!!!
                self.selectedSubFilters = _filters.3
                self.outFiltersEvent.onNext(self.getEnabledFilters())
                self.setupFetch(itemsIds: _filters.4)
                self.outReloadCatalogVC.onNext(true)
                self.emitPrefetchEvent()
                
                self.wait().onNext((.applyFilter, false))
                
                self.unitTestSignalOperationComplete.onNext(self.utMsgId)
            })
            .disposed(by: bag)
        
        
        getNetworkService().getApplyForFiltersEvent()
            .subscribe(onNext: {[weak self] _filters in
                guard let `self` = self else { return }
                self.enableFilters(ids: _filters.0)
                self.enableSubFilters(ids: _filters.1)
                self.midAppliedSubFilters = _filters.2
                self.selectedSubFilters.removeAll()
                self.setTipRangePrice(minPrice: _filters.4, maxPrice: _filters.5)
                
                self.itemsTotal = _filters.6
                self.outMidTotal.onNext(self.itemsTotal)
                
                let filters = self.getEnabledFilters()
                self.outFiltersEvent.onNext(filters)
                self.wait().onNext((.applySubFilter, false))
                
                self.unitTestSignalOperationComplete.onNext(self.utMsgId)
            })
            .disposed(by: bag)
        
        
        getNetworkService().getApplyByPriceEvent()
            .subscribe(onNext: {[weak self] _filters in
                guard let `self` = self else { return }
                self.enableFilters(ids: _filters)
                let filters = self.getEnabledFilters()
                self.outFiltersEvent.onNext(filters)
            })
            .disposed(by: bag)
        
        
        
        getNetworkService().getCatalogModelEvent()
            .subscribe(onNext: {[weak self] res in
                guard let `self` = self else { return }
                self.inPrefetchEvent.onNext(res)
            })
            .disposed(by: bag)
        
        
        
        getNetworkService().getFilterChunk1()
            .filter({$0.count > 0})
            .observeOn(MainScheduler.asyncInstance)
            .subscribe(onNext: { [weak self] res in
                guard let `self` = self else { return }
                
                let filters = res
                self.filters.removeAll()
                self.filters = Dictionary(uniqueKeysWithValues: filters.compactMap({$0}).map{ ($0.id, $0) })
                self.outFiltersEvent.onNext(self.getEnabledFilters())
                self.wait().onNext((.enterFilter, false))
                
                self.unitTestSignalOperationComplete.onNext(self.utMsgId)
            })
            .disposed(by: bag)
        
        
        getNetworkService().getSubFilterChunk2()
            .filter({$0.count > 0})
            .subscribe(onNext: { [weak self] res in
                guard let `self` = self else { return }
                
                let subFilters = res
                self.subfiltersByFilter.removeAll()
                subFilters.forEach{ subf in
                    if self.subfiltersByFilter[subf.filterId] == nil {
                        self.subfiltersByFilter[subf.filterId] = []
                    }
                    self.subfiltersByFilter[subf.filterId]?.append(subf.id)
                    self.subFilters[subf.id] = subf
                }
            })
            .disposed(by: bag)
        
        
        getNetworkService().getMidTotal()
            .subscribe(onNext: {[weak self] count in
                self?.itemsTotal = count
                self?.outMidTotal.onNext(count)
            })
            .disposed(by: bag)
        
        
        getNetworkService().getDownloadsDoneEvent()
            .observeOn(MainScheduler.asyncInstance)
            .subscribe(onNext: {[weak self] _ in
                DispatchQueue.global(qos: .background).async {[weak self] in
                    guard let `self` = self else { return }
                    getNetworkService().requestEnterSubFilter(categoryId: self.categoryId,
                                                              filterId: 6,
                                                              appliedSubFilters: self.midAppliedSubFilters,
                                                              rangePrice: self.rangePrice.getPricesWhenRequestSubFilters()
                    )
                }
            })
            .disposed(by: bag)
        
    }
    
}
