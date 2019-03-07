import Foundation
import RxSwift
import RxDataSources
import SwiftyJSON


class FilterApplyLogic {
    
    private init(){}
    
    public static let shared = FilterApplyLogic()
    
    private var filters: Filters = Filters()
    private var subfiltersByFilter: SubfiltersByFilter = SubfiltersByFilter()
    private var sectionSubFiltersByFilter: SectionSubFiltersByFilter = SectionSubFiltersByFilter()
    private var subFilters: SubFilters = SubFilters()
    
    private var subfiltersByItem: SubfiltersByItem = SubfiltersByItem()
    private var itemsBySubfilter: ItemsBySubfilter = ItemsBySubfilter()
    private var itemsById: ItemsById = ItemsById()
    private var itemsByCatalog: ItemsByCatalog = ItemsByCatalog()
    
    private var priceByItemId: PriceByItemId = PriceByItemId()
    private var itemIds: ItemIds = []
    
    
    public func getFilters() -> [FilterModel] {
        return filters.compactMap({$0.value})
    }
    
    public func getSubFilters() -> [SubfilterModel] {
        return subFilters.compactMap({$0.value})
    }
    
    public func getSubfByItem()-> SubfiltersByItem {
        return subfiltersByItem
    }
    
    public func addSubfByFilter(id: Int, arr: [Int]) {
        subfiltersByFilter[id] = arr
    }
    
    public func addSubF(id: Int, subFilter: SubfilterModel){
        subFilters[id] = subFilter
    }
    
    public func addFilter(id: Int, filter: FilterModel){
        filters[id] = filter
    }
    
    
    public func subfByItem(item: Int, subfilters: [Int]){
        subfiltersByItem[item] = subfilters
        subfilters.forEach{ id in
            if itemsBySubfilter[id] == nil {
                itemsBySubfilter[id] = []
                itemsBySubfilter[id]?.append(item)
            } else {
                itemsBySubfilter[id]?.append(item)
            }
        }
    }
    
    private func limitRangePrice(_ itemId: Int, _ rangePrice: RangePrice) {
        guard let price = priceByItemId[itemId] else { return }
        if rangePrice.tipMinPrice > price {
            rangePrice.tipMinPrice = price
        }
        if rangePrice.tipMaxPrice < price {
            rangePrice.tipMaxPrice = price
        }
    }
    
    
    private func checkPrice(_ itemId: Int, _ minPrice: MinPrice, _ maxPrice: MaxPrice) -> Bool{
        guard let price = priceByItemId[itemId] else { return false }
        if price >= minPrice && price <= maxPrice {
            return true
        }
        return false
    }
    
    
    private func getItemIds(by subFilterIds: [Int], _ rangePrice: RangePrice) -> Set<Int> {
        
        var res = Set<Int>()
        
        let itemIds = subFilterIds
            .compactMap({itemsBySubfilter[$0]})
            .flatMap{$0}
        
        itemIds.forEach({itemId in
            if rangePrice.userMinPrice > 0 || rangePrice.userMaxPrice > 0 {
                if checkPrice(itemId, rangePrice.userMinPrice, rangePrice.userMaxPrice) {
                    res.insert(itemId)
                }
            } else {
                res.insert(itemId)
            }
            limitRangePrice(itemId, rangePrice)
        })
        return res
    }
    
    
    
    private func getItemsIntersect(_ applyingByFilter: ApplyingByFilter, _ rangePrice: RangePrice, exceptFilterId: FilterId = 0) -> Set<Int> {
        var res = Set<Int>()
        var tmp = Set<Int>()
        
        for (filterId, subFilterIds) in applyingByFilter {
            if filterId != exceptFilterId || exceptFilterId == 0  {
                tmp = getItemIds(by: subFilterIds, rangePrice)
            }
            res = (res.count == 0) ? tmp : res.intersection(tmp)
        }
        return res
    }
    
    
    private func getItemsByPrice(_ rangePrice: RangePrice) -> Set<Int> {
        var res = Set<Int>()
        
        priceByItemId.forEach({element in
            let price = element.value
            if (price >= rangePrice.userMinPrice && price <= rangePrice.userMaxPrice) {
                res.insert(element.key)
            }
        })
        return res
    }
    
    private func groupApplying(_ applyingByFilter: inout ApplyingByFilter, _ applying: Set<Int>){
        applyingByFilter.removeAll()
        for id in applying {
            if let subFilter = subFilters[id] {
                let filterId = subFilter.filterId
                if applyingByFilter[filterId] == nil {
                    applyingByFilter[filterId] = []
                }
                applyingByFilter[filterId]?.append(id)
            }
        }
    }
    
    private func applyForTotal(appliedSubFilters: Applied,
                                selectedSubFilters: Selected,
                                rangePrice: RangePrice) -> Int{
        
        let selected = selectedSubFilters
        let applied = getApplied(applied: appliedSubFilters)
        let applying = selected.union(applied)
        
        var items: Set<Int>
        if (applying.count == 0) {
            items = getItemsByPrice(rangePrice)
        } else {
            var applyingByFilter = ApplyingByFilter()
            groupApplying(&applyingByFilter, applying)
            items = getItemsIntersect(applyingByFilter, rangePrice)
        }
        return items.count
        
    }
    
    private func applyFromFilter(_ appliedSubFilters: inout Applied,
                                 _ selectedSubFilters: inout Selected,
                                 _ enabledFilters: inout EnabledFilters,
                                 _ enabledSubfilters: inout EnabledSubfilters,
                                 _ itemsIds: inout [Int],
                                 _ rangePrice: RangePrice) {
        
        
        // block #1 >>
        let selected = selectedSubFilters
        let applied = getApplied(applied: appliedSubFilters)
        let applying = selected.union(applied)
        
        if applying.count == 0 && rangePrice.userMinPrice == 0 && rangePrice.userMaxPrice == 0 {
            return
        }
        // block #1 <<
        
        
        // block #2 >>
        var items: Set<Int>
        if (applying.count == 0) {
            items = getItemsByPrice(rangePrice)
        } else {
            var applyingByFilter = ApplyingByFilter()
            groupApplying(&applyingByFilter, applying)
            items = getItemsIntersect(applyingByFilter, rangePrice)
        }
        // block #2 <<
        
        
        for id in items {
            itemsIds.append(id)
        }
        
        let rem = getSubFilters(by: items)
        enableAllFilters(&enabledFilters, enable: false)
        enableAllSubFilters(&enabledSubfilters, enable: false)
        
        rem.forEach{ id in
            if enabledSubfilters[id] != nil {
                let subFilter = subFilters[id]
                enabledSubfilters[id] = true
                enableFilters(subFilter!.filterId, &enabledFilters)
            }
        }
        selectedSubFilters = Set(applying)
        appliedSubFilters = Set(applying)
    }
    
    
    
    private func getApplied(applied: Applied, exceptFilterId: FilterId = 0) -> Applied{
        if exceptFilterId == 0 {
            return applied
        }
        let res = applied.filter({subFilters[$0]?.filterId != exceptFilterId})
        return res
    }
    
    
    
    private func applyFromSubFilter(_ filterId: FilterId,
                                    _ appliedSubFilters: inout Applied,
                                    _ selectedSubFilters: inout Selected,
                                    _ enabledFilters: inout EnabledFilters,
                                    _ enabledSubfilters: inout EnabledSubfilters,
                                    _ rangePrice: RangePrice,
                                    _ itemsTotal: inout ItemsTotal) {
        
        // block #1 >>
        var inFilter: Set<Int> = Set()
        if let ids = subfiltersByFilter[filterId] {
            inFilter = Set(ids)
        }
        let selected = selectedSubFilters.intersection(inFilter)
        let applied = getApplied(applied: appliedSubFilters)
        let applying = selected.union(applied)
        // block #1 <<
        
        
        // block #2 >>
        if applying.count == 0 && rangePrice.userMinPrice == 0 && rangePrice.userMaxPrice == 0 {
            resetFilters(&appliedSubFilters, &selectedSubFilters, &enabledFilters, &enabledSubfilters, 0, rangePrice)
            return
        }
        // block #2 <<
        
        // block #3 >>
        var items: Set<Int>
        if (applying.count == 0) {
            items = getItemsByPrice(rangePrice)
        } else {
            var applyingByFilter = ApplyingByFilter()
            groupApplying(&applyingByFilter, applying)
            items = getItemsIntersect(applyingByFilter, rangePrice)
        }
        // block #3 <<
        
        // block #4 >>
        itemsTotal = items.count
        if items.count == 0 {
            enableAllFilters(&enabledFilters, exceptFilterId: filterId, enable: false)
            enableAllSubFilters(except: filterId, &enabledSubfilters, enable: true)
            selectedSubFilters = Set(applying)
            appliedSubFilters = Set(applying)
            return
        }
        // block #4 <<
        
        // block #5 >>
        let rem = getSubFilters(by: items)
        
        enableAllFilters(&enabledFilters, exceptFilterId: filterId, enable: false)
        enableAllSubFilters(except: filterId, &enabledSubfilters, enable: false)
        
        rem.forEach{ id in
            if enabledSubfilters[id] != nil {
                let subFilter = subFilters[id]
                enabledSubfilters[id] = true
                enableFilters(subFilter!.filterId, &enabledFilters)
            }
        }
        selectedSubFilters = Set(applying)
        appliedSubFilters = Set(applying)
        // block #5 <<
    }
    
    
    private func removeFilter(_ appliedSubFilters: inout Applied,
                              _ selectedSubFilters: inout Selected,
                              _ filterId: FilterId,
                              _ enabledFilters: inout EnabledFilters,
                              _ enabledSubfilters: inout EnabledSubfilters,
                              _ rangePrice: RangePrice,
                              _ itemsTotal: inout ItemsTotal)  {
        
        
        removeApplied(appliedSubFilters: &appliedSubFilters, selectedSubFilters: &selectedSubFilters, filterId: filterId)
        
        applyAfterRemove(&appliedSubFilters,
                         &selectedSubFilters,
                         &enabledFilters,
                         &enabledSubfilters,
                         rangePrice,
                         &itemsTotal)
    }
    
    
    private func applyAfterRemove(_ appliedSubFilters: inout Applied,
                                  _ selectedSubFilters: inout Selected,
                                  _ enabledFilters: inout EnabledFilters,
                                  _ enabledSubfilters: inout EnabledSubfilters,
                                  _ rangePrice: RangePrice,
                                  _ itemsTotal: inout ItemsTotal ) {
        
        // block #1 >>
        let applying = getApplied(applied: appliedSubFilters)
        if applying.count == 0 && rangePrice.userMinPrice == 0 && rangePrice.userMaxPrice == 0 {
            resetFilters(&appliedSubFilters, &selectedSubFilters, &enabledFilters, &enabledSubfilters, 0, rangePrice)
            return
        }
        // block #1 <<
        
        
        // block #2 >>
        var items: Set<Int>
        var applyingByFilter = ApplyingByFilter()
        if (applying.count == 0) {
            items = getItemsByPrice(rangePrice)
            resetRangePrice(rangePrice)
        } else {
            groupApplying(&applyingByFilter, applying)
            items = getItemsIntersect(applyingByFilter, rangePrice)
        }
        // block #2 <<
        
        // block #3 >>
        if items.count == 0 {
            resetFilters(&appliedSubFilters, &selectedSubFilters, &enabledFilters, &enabledSubfilters, 0, rangePrice)
            return
        }
        
        var filterId = 0
        if applyingByFilter.count == 1 {
            filterId = applyingByFilter.first?.key ?? 0
        }
        // block #3 <<
        
        
        // block #4 >>
        itemsTotal = items.count
        let rem = getSubFilters(by: items)
        enableAllFilters(&enabledFilters, enable: false)
        enableAllSubFilters2(except: filterId, &enabledSubfilters, enable: false)
        
        rem.forEach{ id in
            if enabledSubfilters[id] != nil {
                let subFilter = subFilters[id]
                enabledSubfilters[id] = true
                enableFilters(subFilter!.filterId, &enabledFilters)
            }
        }
        selectedSubFilters = Set(applying)
        appliedSubFilters = Set(applying)
        // block #4 <<
    }
    
    
    
    
    private func applyBeforeEnter(_ appliedSubFilters: inout Applied,
                                  _ filterId: FilterId,
                                  _ enabledFilters: inout EnabledFilters,
                                  _ enabledSubfilters: inout EnabledSubfilters,
                                  _ countsItems: inout CountItems,
                                  _ rangePrice: RangePrice) {
        
        
        // block #1 >>
        let applying = getApplied(applied: appliedSubFilters, exceptFilterId: filterId)
        if applying.count == 0 && rangePrice.userMinPrice == 0 && rangePrice.userMaxPrice == 0 {
            fillItemsCount(by: filterId, &countsItems)
            enableAllSubFilters2(&enabledSubfilters, enable: true)
            return
        }
        // block #1 <<
        
        
        // block #2 >>
        var items: Set<Int>
        if (applying.count == 0) {
            items = getItemsByPrice(rangePrice)
        } else {
            var applyingByFilter = ApplyingByFilter()
            groupApplying(&applyingByFilter, applying)
            items = getItemsIntersect(applyingByFilter, rangePrice)
        }
        // block #2 <<
        
        // block #3 >>
        if items.count == 0 {
            fillItemsCount(by: filterId, &countsItems)
            resetFilters2(&appliedSubFilters, &enabledFilters, &enabledSubfilters, 0, rangePrice)
            return
        }
        // block #3 <<
        
        // block #4 >>
        let rem = getSubFilters(by: items, &countsItems)
        disableSubFilters(filterId: filterId, &enabledSubfilters)
        rem.forEach{ id in
            if enabledSubfilters[id] != nil {
                enabledSubfilters[id] = true
            }
        }
        // block #4 <<
    }
    
    private func applyByPrice(categoryId: CategoryId, enabledFilters: inout EnabledFilters, rangePrice: RangePrice) {
        let items = getItemsByPrice(rangePrice)
        let rem = getSubFilters(by: items)
        enableAllFilters(&enabledFilters, enable: false)
        rem.forEach({id in
            if let subfilter = subFilters[id] {
                enableFilters(subfilter.filterId, &enabledFilters)
            }
        })
    }
    
    
    private func enableFilters(_ filterId: CategoryId, _ enabledFilters: inout EnabledFilters){
        enabledFilters[filterId] = true
    }
    
    private func enableAllFilters(_ enabledFilters: inout EnabledFilters, exceptFilterId: Int = 0, enable: Bool ){
        for (key, _) in enabledFilters {
            enabledFilters[key] = enable
        }
        
        if exceptFilterId != 0 {
            enabledFilters[exceptFilterId] = true
        }
    }
    
    private func enableAllSubFilters(except filterId: CategoryId = 0, _ enabledSubFilters: inout EnabledSubfilters, enable: Bool){
        for (key, val) in subFilters {
            if val.filterId != filterId || filterId == 0 {
                enabledSubFilters[key] = enable
            }
        }
    }
    
    
    private func enableAllSubFilters2(except filterId: FilterId = 0, _ enabledFilters: inout EnabledSubfilters, enable: Bool){
        let ids1 = subFilters.filter({$0.value.filterId != filterId || filterId == 0 }).compactMap({$0.key})
        
        for id in ids1 {
            enabledFilters[id] = enable
        }
        
        if (filterId == 0) {
            return
        }
        
        let ids2 = subFilters.filter({$0.value.filterId == filterId}).compactMap({$0.key})
        for id in ids2 {
            enabledFilters[id] = !enable
        }
    }
    
    private func getSubFilters(by items: Set<Int> ) -> [Int] {
        let sub = items.compactMap{subfiltersByItem[$0]}
        return sub.flatMap{$0}
    }
    
    private func getSubFilters(by items: Set<Int>, _ countsItems: inout CountItems ) -> [Int] {
        let subfilters = items.compactMap{subfiltersByItem[$0]}.flatMap{$0}
        subfilters.forEach({id in
            if let cnt = countsItems[id] {
                countsItems[id] = cnt + 1
            } else {
                countsItems[id] = 1
            }
        })
        return subfilters
    }
    
    
    private func fillItemsCount(by filterId: FilterId, _ countsItems: inout CountItems){
        guard let subfilters = subfiltersByFilter[filterId] else { return }
        for subfID in subfilters {
            if let tmp = itemsBySubfilter[subfID] {
                countsItems[subfID] = tmp.count
            }
        }
    }
    
    
    private func removeApplied( appliedSubFilters: inout Applied,
                                selectedSubFilters: inout Selected,
                                filterId: Int = 0) {
        var removing = Set<Int>()
        if filterId == 0 {
            removing = appliedSubFilters
        } else {
            removing = appliedSubFilters.filter({subFilters[$0]?.filterId == filterId})
        }
        appliedSubFilters.subtract(removing)
        selectedSubFilters.subtract(removing)
    }
    
    
    private func resetFilters(  _ applied: inout Applied,
                                _ selected: inout Selected,
                                _ enabledFilters: inout EnabledFilters,
                                _ enabledSubfilters: inout EnabledSubfilters,
                                _ exceptFilterId: Int = 0,
                                _ rangePrice: RangePrice? = nil
        ){
        applied.removeAll()
        selected.removeAll()
        enableAllFilters(&enabledFilters, enable: true)
        enableAllSubFilters(except: exceptFilterId, &enabledSubfilters, enable: true)
        resetRangePrice(rangePrice)
    }
    
    private func resetFilters2( _ applied: inout Applied,
                                _ enabledFilters: inout EnabledFilters,
                                _ enabledSubfilters: inout EnabledSubfilters,
                                _ exceptFilterId: Int = 0,
                                _ rangePrice: RangePrice? = nil
        ){
        applied.removeAll()
        enableAllFilters(&enabledFilters, enable: true)
        enableAllSubFilters(except: exceptFilterId, &enabledSubfilters, enable: true)
        resetRangePrice(rangePrice)
    }
    
    private func resetRangePrice(_ rangePrice: RangePrice?) {
        guard let rp = rangePrice else { return }
        rp.tipMinPrice = rp.initialMinPrice
        rp.tipMaxPrice = rp.initialMaxPrice
    }
    
    
    private func disableSubFilters(filterId: FilterId, _ enabledSubfilters: inout EnabledSubfilters){
        for (key, val) in subFilters {
            if val.filterId == filterId {
                enabledSubfilters[key] = false
            }
        }
    }
    
    
    private func getEnabledSubFilters(ids: [Int]) -> [SubfilterModel?] {
        let res = ids
            .compactMap({subFilters[$0]})
            .filter({$0.enabled == true})
        return res
    }
    
    private func getEnabledFilters()->[FilterModel?] {
        return filters
            .compactMap({$0.value})
            .filter({$0.enabled == true})
            .sorted(by: {$0.id < $1.id })
    }
    
    
    private func getEnabledFiltersIds(_ enabledFilters: inout EnabledFilters)->[Int?] {
        return enabledFilters
            .filter({$0.value == true })
            .compactMap({$0.key})
            .sorted(by: {$0 < $1 })
    }
    
    
    private func getEnabledSubFiltersIds(_ enabledSubfilters: inout EnabledSubfilters)->[Int?] {
        return enabledSubfilters
            .filter({$0.value == true })
            .compactMap({$0.key})
            .sorted(by: {$0 < $1 })
    }
    
    private func fillEnabledFilters(_ enabledFilters: inout EnabledFilters){
        for filter in filters {
            enabledFilters[filter.key] = true
        }
    }
    
    private func fillEnabledSubFilters(_ enabledSubfilters: inout EnabledSubfilters){
        for subf in subFilters {
            enabledSubfilters[subf.key] = true
        }
    }
    
    
    private func checkSubFilterApply() -> Bool {
        
        if self.filters.count > 0 &&
            self.subFilters.count > 0 &&
            self.subfiltersByFilter.count > 0 &&
            self.subfiltersByItem.count > 0 &&
            self.itemsBySubfilter.count > 0 &&
            self.priceByItemId.count > 0 {
            return true
        }
        return false
    }
    
    
    private func timer4SubFilterApply() {
        var ready = false
        while ready == false {
            ready = checkSubFilterApply()
            if ready {
                return
            }
            usleep(200)
        }
    }
    
    private func checkEnterSubFilter() -> Bool {
        
        if self.filters.count > 0 &&
            self.subFilters.count > 0 &&
            self.subfiltersByFilter.count > 0 {
            return true
        }
        return false
    }
    
    
    private func timer4SubFilterEnter() {
        var ready = false
        while ready == false {
            ready = checkEnterSubFilter()
            if ready {
                return
            }
            usleep(200)
        }
    }
    
    
    
    
    //
    //    // Catalog Models:
    //    private func loadItemsFromDb(categoryId: Int, offset: Int){
    //
    //        itemsByCatalog = TestData.loadCatalogs(categoryId: categoryId)
    //
    //        let catalogModels = itemsByCatalog[categoryId] ?? []
    //        itemsById.removeAll()
    //        let limit = 5
    //
    //        var next = ArraySlice<CatalogModel>()
    //        if catalogModels.count > offset{
    //           let end = max(catalogModels.count-1, offset + limit)
    //           next = catalogModels[offset...end]
    //        }
    //
    //        next.forEach{ model in
    //            itemsById[model.id] = model
    //        }
    //    }
    //
    //
    //    private func getCatalogModel(categoryId: Int, appliedSubFilters: Set<Int>, offset: Int) -> [CatalogModel?]{
    //        loadItemsFromDb(categoryId: categoryId, offset: offset)
    //
    //        guard appliedSubFilters.count > 0
    //        else {
    //            return itemsById.compactMap({$0.value}).sorted(by: {$0.id < $1.id })
    //        }
    //
    //
    //        groupApplying(applying: appliedSubFilters)
    //
    //
    //        let items = getItemsIntersect()
    //
    //
    ////
    ////        let itemIdsArr = appliedSubFilters
    ////        .compactMap({itemsBySubfilter[$0]})
    ////        .flatMap{$0}
    ////
    ////        let itemIdsSet = Set(itemIdsArr)
    //        let res = items
    //            .compactMap({itemsById[$0]})
    //
    //        return res
    //    }
    
}



protocol FilterApplyLogicProtocol {
    
    
    func doLoadSubFilters(_ filterId: FilterId, _ appliedSubFilters: Set<Int>, _ rangePrice: RangePrice) -> Observable<(FilterId, SubFilterIds, Applied, CountItems)>
    
    func doLoadFilters() -> Observable<([FilterModel], [SubfilterModel])>
    
    func doCalcMidTotal(_ appliedSubFilters: Set<Int>,  _ selectedSubFilters: Set<Int>, _ rangePrice: RangePrice) -> Observable<Int>
    
    func doApplyFromFilter(_ appliedSubFilters: Set<Int>,  _ selectedSubFilters: Set<Int>, _ rangePrice: RangePrice) -> Observable<(FilterIds, SubFilterIds, Applied, Selected, ItemIds)>
    
    func doApplyFromSubFilters(_ filterId: Int, _ appliedSubFilters: Set<Int>, _ selectedSubFilters: Set<Int>, _ rangePrice: RangePrice) -> Observable<(FilterIds, SubFilterIds, Applied, Selected, RangePrice, ItemsTotal)>
    
    func doRemoveFilter(_ filterId: Int, _ appliedSubFilters: Set<Int>,  _ selectedSubFilters: Set<Int>, _ rangePrice: RangePrice) -> Observable<(FilterIds, SubFilterIds, Applied, Selected, RangePrice, ItemsTotal)>
    
    func doApplyByPrices(_ categoryId: Int, _ rangePrice: RangePrice) -> Observable<[Int?]>
    
    func setup(filters: [FilterModel]?,
               subFilters: [SubfilterModel]?,
               subfiltersByFilter: SubfiltersByFilter?,
               subfiltersByItem: SubfiltersByItem?,
               itemsBySubfilter: ItemsBySubfilter?,
               priceByItemId: PriceByItemId?
    )
    
    func dealloc()
}


extension FilterApplyLogic: FilterApplyLogicProtocol {
    
    func doCalcMidTotal(_ appliedSubFilters: Set<Int>,  _ selectedSubFilters: Set<Int>, _ rangePrice: RangePrice) -> Observable<Int> {
        let count = applyForTotal(appliedSubFilters: appliedSubFilters, selectedSubFilters: selectedSubFilters, rangePrice: rangePrice)
        return Observable.just(count)
    }
    
    func doApplyFromFilter(_ appliedSubFilters: Set<Int>,  _ selectedSubFilters: Set<Int>, _ rangePrice: RangePrice) -> Observable<(FilterIds, SubFilterIds, Applied, Selected, ItemIds)> {
        
        var enabledFilters = EnabledFilters()
        var enabledSubfilters = EnabledSubfilters()
        var itemsIds: [Int] = []
        var applied = appliedSubFilters
        var selected = selectedSubFilters
        fillEnabledFilters(&enabledFilters)
        fillEnabledSubFilters(&enabledSubfilters)
        
        
        applyFromFilter(&applied,
                        &selected,
                        &enabledFilters,
                        &enabledSubfilters,
                        &itemsIds,
                        rangePrice)
        
        let filtersIds = getEnabledFiltersIds(&enabledFilters)
        let subFiltersIds = getEnabledSubFiltersIds(&enabledSubfilters)
        itemsIds.sort(by: {$0 < $1})
        return Observable.just((filtersIds, subFiltersIds, applied, selected, itemsIds))
    }
    
    
    func doApplyFromSubFilters(_ filterId: Int, _ appliedSubFilters: Set<Int>, _ selectedSubFilters: Set<Int>, _ rangePrice: RangePrice) -> Observable<(FilterIds, SubFilterIds, Applied, Selected, RangePrice, ItemsTotal)> {
        
        timer4SubFilterApply()
        
        var enabledFilters = EnabledFilters()
        var enabledSubfilters = EnabledSubfilters()
        var applied = appliedSubFilters
        var selected = selectedSubFilters
        fillEnabledFilters(&enabledFilters)
        fillEnabledSubFilters(&enabledSubfilters)
        
        rangePrice.tipMinPrice = 50000000
        rangePrice.tipMaxPrice = -1
        var itemsTotal = 0
        
        applyFromSubFilter(filterId,
                           &applied,
                           &selected,
                           &enabledFilters,
                           &enabledSubfilters,
                           rangePrice,
                           &itemsTotal
                           )
        
        
        let filtersIds = getEnabledFiltersIds(&enabledFilters)
        let subFiltersIds = getEnabledSubFiltersIds(&enabledSubfilters)
        return Observable.just((filtersIds, subFiltersIds, applied, selected, rangePrice, itemsTotal))
    }
    
    
    func doRemoveFilter(_ filterId: Int, _ appliedSubFilters: Set<Int>,  _ selectedSubFilters: Set<Int>, _ rangePrice: RangePrice) -> Observable<(FilterIds, SubFilterIds, Applied, Selected, RangePrice, ItemsTotal)> {
        
        var enabledFilters = EnabledFilters()
        var enabledSubfilters = EnabledSubfilters()
        var applied = appliedSubFilters
        var selected = selectedSubFilters
        fillEnabledFilters(&enabledFilters)
        fillEnabledSubFilters(&enabledSubfilters)
        
        rangePrice.tipMinPrice = 50000000
        rangePrice.tipMaxPrice = -1
        var itemsTotal = 0
        
        removeFilter(&applied,
                     &selected,
                     filterId,
                     &enabledFilters,
                     &enabledSubfilters,
                     rangePrice,
                     &itemsTotal)
        
        
        let filtersIds = getEnabledFiltersIds(&enabledFilters)
        let subFiltersIds = getEnabledSubFiltersIds(&enabledSubfilters)
        return Observable.just((filtersIds, subFiltersIds, applied, selected, rangePrice, itemsTotal))
    }
    
    
    func doLoadSubFilters(_ filterId: Int = 0, _ appliedSubFilters: Set<Int>, _ rangePrice: RangePrice) -> Observable<(FilterId, SubFilterIds, Applied, CountItems)> {
        
        
        timer4SubFilterEnter()
        
        var enabledFilters = EnabledFilters()
        var enabledSubfilters = EnabledSubfilters()
        var countsItems = CountItems()
        var applied = appliedSubFilters
        fillEnabledFilters(&enabledFilters)
        fillEnabledSubFilters(&enabledSubfilters)
        
        applyBeforeEnter(&applied,
                         filterId,
                         &enabledFilters,
                         &enabledSubfilters,
                         &countsItems,
                         rangePrice)
        
        let subFiltersIds = getEnabledSubFiltersIds(&enabledSubfilters)
        
        return Observable.just((filterId, subFiltersIds, applied, countsItems))
    }
    
    
    func doLoadFilters() -> Observable<([FilterModel], [SubfilterModel])> {
        return Observable.just((TestData.loadFilters(), TestData.loadSubFilters(filterId: 0)))
    }
    
    
    func doApplyByPrices(_ categoryId: Int, _ rangePrice: RangePrice) -> Observable<[Int?]> {
        
        var enabledSubfilters = EnabledSubfilters()
        fillEnabledFilters(&enabledSubfilters)
        
        applyByPrice(categoryId: categoryId, enabledFilters: &enabledSubfilters, rangePrice: rangePrice)
        
        let subFiltersIds = getEnabledSubFiltersIds(&enabledSubfilters)
        
        return Observable.just(subFiltersIds)
    }
    
    
    func setup(filters: [FilterModel]? = nil,
               subFilters: [SubfilterModel]? = nil,
               subfiltersByFilter: SubfiltersByFilter? = nil,
               subfiltersByItem: SubfiltersByItem? = nil,
               itemsBySubfilter: ItemsBySubfilter? = nil,
               priceByItemId: PriceByItemId? = nil
        ){
        
        if let a = filters {
            a.forEach({f in
                self.filters[f.id] = f
            })
          //  print("Filters Loading Completed...")
        }
            
        if let b = subFilters {
            b.forEach({s in
                self.subFilters[s.id] = s
            })
            //print("Subf Loading Completed...")
        }
        
        if let c = subfiltersByFilter {
            self.subfiltersByFilter = c
            //print("subfiltersByFilter Loading Completed...")
        }
        
        if let d = subfiltersByItem {
            self.subfiltersByItem = d
           // print("subfiltersByItem Loading Completed...")
        }
        
        if let e = itemsBySubfilter {
            self.itemsBySubfilter = e
           // print("itemsBySubfilter Loading Completed...")
        }
        
        if let f = priceByItemId {
            self.priceByItemId = f
           // print("priceByItemId Loading Completed...")
        }
    }
    
    
    func dealloc(){
        filters.removeAll()
        subfiltersByFilter.removeAll()
        subfiltersByItem.removeAll()
        itemsBySubfilter.removeAll()
        priceByItemId.removeAll()
    }
}

