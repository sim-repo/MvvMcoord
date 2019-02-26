import Foundation
import RxSwift
import RxDataSources
import SwiftyJSON


class BackendLogic {
    
    private init(){}
       
    public static let shared = BackendLogic()
    
//    private var appliedSubFilters: Applied = Applied()
//    private var selectedSubFilters: Selected = Selected()
//    private var applyingByFilter: ApplyingByFilter = ApplyingByFilter()
    
    private var filters: Filters = Filters()
    private var subfiltersByFilter: SubfiltersByFilter = SubfiltersByFilter()
    private var sectionSubFiltersByFilter: SectionSubFiltersByFilter = SectionSubFiltersByFilter()
    private var subFilters: SubFilters = SubFilters()
    
    private var subfiltersByItem: SubfiltersByItem = SubfiltersByItem()
    private var itemsBySubfilter: ItemsBySubfilter = ItemsBySubfilter()
    private var itemsById: ItemsById = ItemsById()
    private var itemsByCatalog: ItemsByCatalog = ItemsByCatalog()
    
    private var priceByItemId: PriceByItemId = PriceByItemId()
   // private var cntBySubfilterId: CountItems = [:]
    private var itemIds: ItemIds = []
  //  private var rangePrice: RangePrice?
   
    public func getSubfByItem()-> [Int: [Int]] {
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
    
    
    private func checkPrice(_ itemId: Int, _ minPrice: CGFloat, _ maxPrice: CGFloat) -> Bool{
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
        })
        return res
    }
    
    
    
    private func getItemsIntersect(_ applyingByFilter: ApplyingByFilter, _ rangePrice: RangePrice, exceptFilterId: Int = 0) -> Set<Int> {
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
    
    private func applyFromFilter(appliedSubFilters: inout Applied,
                                 selectedSubFilters: inout Selected,
                                 enabledFilters: inout EnabledFilters,
                                 enabledSubfilters: inout EnabledSubfilters,
                                 itemsIds: inout [Int],
                                 rangePrice: RangePrice) {
        
        
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
    
    private func getApplied(applied: Applied, exceptFilterId: Int = 0) -> Set<Int>{
        if exceptFilterId == 0 {
            return applied
        }
        let res = applied.filter({subFilters[$0]?.filterId != exceptFilterId})
        return res
    }
    

    
    private func applyFromSubFilter(filterId: Int,
                                    appliedSubFilters: inout Applied,
                                    selectedSubFilters: inout Selected,
                                    enabledFilters: inout EnabledFilters,
                                    enabledSubfilters: inout EnabledSubfilters,
                                    rangePrice: RangePrice) {
        
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
    
    
    private func removeFilter(appliedSubFilters: inout Applied,
                              selectedSubFilters: inout Selected,
                              filterId: FilterId,
                              enabledFilters: inout EnabledFilters,
                              enabledSubfilters: inout EnabledSubfilters,
                              rangePrice: RangePrice)  {
        
        
        removeApplied(appliedSubFilters: &appliedSubFilters, selectedSubFilters: &selectedSubFilters, filterId: filterId)
        
        applyAfterRemove(appliedSubFilters: &appliedSubFilters,
                         selectedSubFilters: &selectedSubFilters,
                         enabledFilters: &enabledFilters,
                         enabledSubfilters: &enabledSubfilters,
                         rangePrice: rangePrice)
    }
    
    
    private func applyAfterRemove(appliedSubFilters: inout Applied,
                                  selectedSubFilters: inout Selected,
                                  enabledFilters: inout EnabledFilters,
                                  enabledSubfilters: inout EnabledSubfilters,
                                  rangePrice: RangePrice) {
        
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
    
    
    
    
    private func applyBeforeEnter(appliedSubFilters: inout Applied,
                                  filterId: FilterId,
                                  enabledFilters: inout EnabledFilters,
                                  enabledSubfilters: inout EnabledSubfilters,
                                  countsItems: inout CountItems,
                                  rangePrice: RangePrice) {
        
        
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
    
    private func applyByPrice(categoryId: Int, enabledFilters: inout EnabledFilters, rangePrice: RangePrice) {
        let items = getItemsByPrice(rangePrice)
        let rem = getSubFilters(by: items)
        enableAllFilters(&enabledFilters, enable: false)
        rem.forEach({id in
            if let subfilter = subFilters[id] {
                enableFilters(subfilter.filterId, &enabledFilters)
            }
        })
    }
    
    
    private func enableFilters(_ filterId: Int, _ enabledFilters: inout EnabledFilters){
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
    
    private func enableAllSubFilters(except filterId: Int = 0, _ enabledSubFilters: inout EnabledSubfilters, enable: Bool){
        for (key, val) in subFilters {
            if val.filterId != filterId || filterId == 0 {
                enabledSubFilters[key] = enable
            }
        }
    }
    
    
    private func enableAllSubFilters2(except filterId: Int = 0, _ enabledFilters: inout EnabledSubfilters, enable: Bool){
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
    
    
    private func fillItemsCount(by filterId: Int, _ countsItems: inout CountItems){
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
    
    
    private func disableSubFilters(filterId: Int, _ enabledSubfilters: inout EnabledSubfilters){
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



protocol ApiBackendLogic {
    
    
    func apiLoadSubFilters(filterId: FilterId, appliedSubFilters: Set<Int>, rangePrice: RangePrice) -> Observable<(FilterId, SubFilterIds, Applied, CountItems)>
    
    func apiLoadFilters() -> Observable<([FilterModel], [SubfilterModel])>
    
    func apiApplyFromFilter(appliedSubFilters: Set<Int>,  selectedSubFilters: Set<Int>, rangePrice: RangePrice) -> Observable<(FilterIds, SubFilterIds, Applied, Selected, ItemIds)>
    
    func apiApplyFromSubFilters(filterId: Int, appliedSubFilters: Set<Int>, selectedSubFilters: Set<Int>, rangePrice: RangePrice) -> Observable<(FilterIds, SubFilterIds, Applied, Selected, RangePrice)>
    
    func apiRemoveFilter(filterId: Int, appliedSubFilters: Set<Int>,  selectedSubFilters: Set<Int>, rangePrice: RangePrice) -> Observable<(FilterIds, SubFilterIds, Applied, Selected, RangePrice)>
    
    func apiApplyByPrices(categoryId: Int, rangePrice: RangePrice) -> Observable<[Int?]>
    
    func setup(filters: [FilterModel],
               subFilters: [SubfilterModel],
               subfiltersByFilter: SubfiltersByFilter,
               subfiltersByItem: SubfiltersByItem,
               itemsBySubfilter: ItemsBySubfilter,
               priceByItemId: PriceByItemId
    )
}


extension BackendLogic: ApiBackendLogic {


    func apiApplyFromFilter(appliedSubFilters: Set<Int>,  selectedSubFilters: Set<Int>, rangePrice: RangePrice) -> Observable<(FilterIds, SubFilterIds, Applied, Selected, ItemIds)> {
        
        var enabledFilters = EnabledFilters()
        var enabledSubfilters = EnabledSubfilters()
        var itemsIds: [Int] = []
        var applied = appliedSubFilters
        var selected = selectedSubFilters
        fillEnabledFilters(&enabledFilters)
        fillEnabledSubFilters(&enabledSubfilters)
        
        
        applyFromFilter(appliedSubFilters: &applied,
                            selectedSubFilters: &selected,
                            enabledFilters: &enabledFilters,
                            enabledSubfilters: &enabledSubfilters,
                            itemsIds: &itemsIds,
                            rangePrice: rangePrice)

        let filtersIds = getEnabledFiltersIds(&enabledFilters)
        let subFiltersIds = getEnabledSubFiltersIds(&enabledSubfilters)
        itemsIds.sort(by: {$0 < $1})
        return Observable.just((filtersIds, subFiltersIds, applied, selected, itemsIds))
    }
    
    
    func apiApplyFromSubFilters(filterId: Int, appliedSubFilters: Set<Int>, selectedSubFilters: Set<Int>, rangePrice: RangePrice) -> Observable<(FilterIds, SubFilterIds, Applied, Selected, RangePrice)> {
        
        var enabledFilters = EnabledFilters()
        var enabledSubfilters = EnabledSubfilters()
        var applied = appliedSubFilters
        var selected = selectedSubFilters
        fillEnabledFilters(&enabledFilters)
        fillEnabledSubFilters(&enabledSubfilters)
        
        applyFromSubFilter(filterId: filterId,
                           appliedSubFilters: &applied,
                           selectedSubFilters: &selected,
                           enabledFilters: &enabledFilters,
                           enabledSubfilters: &enabledSubfilters,
                           rangePrice: rangePrice)
        
        
        let filtersIds = getEnabledFiltersIds(&enabledFilters)
        let subFiltersIds = getEnabledSubFiltersIds(&enabledSubfilters)
        return Observable.just((filtersIds, subFiltersIds, applied, selected, rangePrice))
    }
    
    
    func apiRemoveFilter(filterId: Int, appliedSubFilters: Set<Int>,  selectedSubFilters: Set<Int>, rangePrice: RangePrice) -> Observable<(FilterIds, SubFilterIds, Applied, Selected, RangePrice)> {
        
        var enabledFilters = EnabledFilters()
        var enabledSubfilters = EnabledSubfilters()
        fillEnabledFilters(&enabledFilters)
        fillEnabledSubFilters(&enabledSubfilters)
        
        var applied = appliedSubFilters
        var selected = selectedSubFilters
        
        removeFilter(appliedSubFilters: &applied,
                     selectedSubFilters: &selected,
                     filterId: filterId,
                     enabledFilters: &enabledFilters,
                     enabledSubfilters: &enabledSubfilters,
                     rangePrice: rangePrice)
        
        
        let filtersIds = getEnabledFiltersIds(&enabledFilters)
        let subFiltersIds = getEnabledSubFiltersIds(&enabledSubfilters)
        return Observable.just((filtersIds, subFiltersIds, applied, selected, rangePrice))
    }

    
    func apiLoadSubFilters(filterId: Int = 0, appliedSubFilters: Set<Int>, rangePrice: RangePrice) -> Observable<(FilterId, SubFilterIds, Applied, CountItems)> {
        
        var enabledFilters = EnabledFilters()
        var enabledSubfilters = EnabledSubfilters()
        var countsItems = CountItems()
        var applied = appliedSubFilters
        fillEnabledFilters(&enabledFilters)
        fillEnabledSubFilters(&enabledSubfilters)
        
        applyBeforeEnter(appliedSubFilters: &applied,
                         filterId: filterId,
                         enabledFilters: &enabledFilters,
                         enabledSubfilters: &enabledSubfilters,
                         countsItems: &countsItems,
                         rangePrice: rangePrice)
       
        let subFiltersIds = getEnabledSubFiltersIds(&enabledSubfilters)
        
        return Observable.just((filterId, subFiltersIds, applied, countsItems))
    }
    
    
    func apiLoadFilters() -> Observable<([FilterModel], [SubfilterModel])> {
        return Observable.just((TestData.loadFilters(), TestData.loadSubFilters(filterId: 0)))
    }
    
    
    func apiApplyByPrices(categoryId: Int, rangePrice: RangePrice) -> Observable<[Int?]> {
        
        var enabledSubfilters = EnabledSubfilters()
        fillEnabledFilters(&enabledSubfilters)
        
        applyByPrice(categoryId: categoryId, enabledFilters: &enabledSubfilters, rangePrice: rangePrice)
        
        let subFiltersIds = getEnabledSubFiltersIds(&enabledSubfilters)
        
        return Observable.just(subFiltersIds)
    }
    
    
    func setup(filters: [FilterModel],
               subFilters: [SubfilterModel],
               subfiltersByFilter: SubfiltersByFilter,
               subfiltersByItem: SubfiltersByItem,
               itemsBySubfilter: ItemsBySubfilter,
               priceByItemId: PriceByItemId
        ){
        
        filters.forEach({f in
            self.filters[f.id] = f
        })
        subFilters.forEach({s in
            self.subFilters[s.id] = s
        })
        self.subfiltersByFilter = subfiltersByFilter
        self.subfiltersByItem = subfiltersByItem
        self.itemsBySubfilter = itemsBySubfilter
        self.priceByItemId = priceByItemId
    }

}
