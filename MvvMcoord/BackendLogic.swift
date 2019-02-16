import Foundation
import RxSwift
import RxDataSources
import SwiftyJSON


protocol ApiBackendLogic {
    func apiLoadSubFilters(filterId: Int, appliedSubFilters: Set<Int>) -> Observable<(Int, [Int?], Set<Int>)>
    func apiLoadFilters() -> Observable<([FilterModel], [SubfilterModel])>
    func apiApplyFromFilter(appliedSubFilters: Set<Int>,  selectedSubFilters: Set<Int>) -> Observable<([Int?], [Int?], Set<Int>, Set<Int>)>
    func apiApplyFromSubFilters(filterId:Int, appliedSubFilters: Set<Int>,  selectedSubFilters: Set<Int>) -> Observable<([Int?], [Int?], Set<Int>, Set<Int>)>
    func apiRemoveFilter(filterId: Int, appliedSubFilters: Set<Int>,  selectedSubFilters: Set<Int>) -> Observable<([Int?], [Int?], Set<Int>, Set<Int>)>
    func apiCatalogModel(categoryId: Int, appliedSubFilters: Set<Int>, offset: Int) -> Observable<[CatalogModel?]>
}



class BackendLogic {
    
    private init(){}
    
   
    public static let shared = BackendLogic()
    
   
    
    private var appliedSubFilters: Set<Int> = Set()
    private var selectedSubFilters: Set<Int> = Set()
    private var applyingByFilter: [Int:[Int]] = [:]
    
    
    private var filters: [Int:FilterModel] = [:]
    private var subfiltersByFilter: [Int:[Int]] = [:]
    private var sectionSubFiltersByFilter: [Int:[SectionOfSubFilterModel]] = [:]
    private var subFilters: [Int:SubfilterModel] = [:]
    
    
    private var subfiltersByItem: [Int: [Int]] = [:]
    private var itemsBySubfilter: [Int: [Int]] = [:]
    private var itemsById: [Int:CatalogModel] = [:]
    private var itemsByCatalog: [Int:[CatalogModel]] = [:] // use for load from db
    
    
    
    public func setup() {
        TestData.loadFilters()
        TestData.loadSubFilters(filterId: 0)
    }
    
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
    
    
    private func getItemIds(by subFilterIds: [Int]) -> [Int] {
        let r = subFilterIds.compactMap({itemsBySubfilter[$0]})
        return r.flatMap{$0}
    }
    
    
    
    private func getItemsIntersect(exceptFilterId: Int = 0) -> Set<Int> {
        var res = Set<Int>()
        var tmp = Set<Int>()
        
        for (filterId, applying) in applyingByFilter {
            if filterId != exceptFilterId || exceptFilterId == 0  {
                tmp = Set(getItemIds(by: applying))
            }
            res = (res.count == 0) ? tmp : res.intersection(tmp)
        }
        return res
    }
    

    private func groupApplying(applying: Set<Int>){
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
    
    private func applyFromFilter() {
        
        let selected = selectedSubFilters
        let applied = getApplied()
        let applying = selected.union(applied)
        if applying.count > 0 {
            
            groupApplying(applying: applying)
            
            let items = getItemsIntersect()
            
            let rem = getSubFilters(by: items)
            
            self.enableAllFilters(enable: false)
            self.enableAllSubFilters( enable: false)
            
            rem.forEach{ id in
                if let subFilter = subFilters[id] {
                    subFilter.enabled = true
                    self.enableFilters(filterId: subFilter.filterId)
                }
            }
            selectedSubFilters = Set(applying)
            appliedSubFilters = Set(applying)
        }
    }
    
    private func getApplied(exceptFilterId: Int = 0) -> Set<Int>{
        if exceptFilterId == 0 {
            return appliedSubFilters
        }
        let res = appliedSubFilters.filter({subFilters[$0]?.filterId != exceptFilterId})
        return res
    }
    

    
    private func applyFromSubFilter(filterId: Int) {
        var inFilter: Set<Int> = Set()
        
        if let ids = subfiltersByFilter[filterId] {
            inFilter = Set(ids)
        }
        
        let selected = selectedSubFilters.intersection(inFilter)
        
        let applied = getApplied(exceptFilterId: filterId)
        let applying = selected.union(applied)
        
        if applying.count == 0 {
            resetFilters(exceptFilterId: filterId)
            return
        }
        
        groupApplying(applying: applying)
        
        
        let items = getItemsIntersect()
        
        if items.count == 0 {
            enableAllFilters(exceptFilterId: filterId, enable: false)
            enableAllSubFilters(except: filterId, enable: true)
            selectedSubFilters = Set(applying)
            appliedSubFilters = Set(applying)
            return
        }
        
        let rem = getSubFilters(by: items)
        
        enableAllFilters(enable: false)
        
        enableAllSubFilters(except: filterId, enable: false)
        
        rem.forEach{ id in
            if let subFilter = subFilters[id] {
                subFilter.enabled = true
                enableFilters(filterId: subFilter.filterId)
            }
        }
        selectedSubFilters = Set(applying)
        appliedSubFilters = Set(applying)
    }
    
    
    private func applyAfterRemove() {
        let applying = getApplied()
        
        if applying.count == 0 {
            resetFilters()
            return
        }
        
        groupApplying(applying: applying)
        let items = getItemsIntersect()
        
        if items.count == 0 {
            resetFilters()
            return
        }
        
        var filterId = 0
        if applyingByFilter.count == 1 {
            filterId = applyingByFilter.first?.key ?? 0
        }
        let rem = getSubFilters(by: items)
        
        enableAllFilters(enable: false)
        
        enableAllSubFilters2(except: filterId, enable: false)
        
        rem.forEach{ id in
            if let subFilter = subFilters[id] {
                subFilter.enabled = true
                enableFilters(filterId: subFilter.filterId)
            }
        }
        selectedSubFilters = Set(applying)
        appliedSubFilters = Set(applying)
    }
    
    
    private func applyBeforeEnter(filterId: Int){
        
        let applied = getApplied(exceptFilterId: filterId)
        let applying = applied
        
        if applying.count == 0 {
            enableAllSubFilters2(enable: true)
            return
        }
        
        groupApplying(applying: applying)
        
        let items = getItemsIntersect()
        
        if items.count == 0 {
            resetFilters(exceptFilterId: filterId)
            return
        }
        
        let rem = getSubFilters(by: items)
        
        disableSubFilters(filterId: filterId)
        rem.forEach{ id in
            if let subFilter = subFilters[id] {
                subFilter.enabled = true
            }
        }
    }
    
    private func removeFilter(filterId: Int)  {
        removeApplied(filterId: filterId)
        applyAfterRemove()
    }
    
    
    private func enableFilters(filterId: Int){
        self.filters[filterId]?.enabled = true
    }
    
    private func enableAllFilters(exceptFilterId: Int = 0 ,enable: Bool){
        for (_, val) in filters {
            val.enabled = enable
        }
        if exceptFilterId != 0 {
            filters[exceptFilterId]?.enabled = true
        }
    }
    
    private func enableAllSubFilters(except filterId: Int = 0, enable: Bool){
        for (_, val) in subFilters {
            if val.filterId != filterId || filterId == 0 {
                val.enabled = enable
            }
        }
    }
    

    private func getSubFilters(by items: Set<Int>) -> [Int] {
        let sub = items.compactMap{subfiltersByItem[$0]}
        return sub.flatMap{$0}
    }
    
    
    private func removeApplied(filterId: Int = 0) {
        var removing = Set<Int>()
        if filterId == 0 {
            removing = appliedSubFilters
        } else {
            removing = appliedSubFilters.filter({subFilters[$0]?.filterId == filterId})
        }
        appliedSubFilters.subtract(removing)
        selectedSubFilters.subtract(removing)
    }
    
    
    private func resetFilters(exceptFilterId: Int = 0){
        selectedSubFilters = []
        appliedSubFilters = []
        enableAllFilters(enable: true)
        enableAllSubFilters(except: exceptFilterId, enable: true)
    }
    
    private func getOtherApplied(except subFilters: Set<Int>)-> Set<Int>{
        return appliedSubFilters.subtracting(subFilters)
    }
    
    
    private func disableSubFilters(filterId: Int){
        for (_, val) in subFilters {
            if val.filterId == filterId {
                val.enabled = false
            }
        }
    }
    
    private func enableAllSubFilters2(except filterId: Int = 0, enable: Bool){
        for (_, val) in subFilters {
            if val.filterId != filterId || filterId == 0 {
                val.enabled = enable
            }
        }
        
        if filterId == 0 {
            return
        }
        
        for (_, val) in subFilters {
            if val.filterId == filterId{
                val.enabled = !enable
            }
        }
    }
    
    
    func nerworkRequest(filterId: Int)->Observable<[SubfilterModel?]> {
        var res = [SubfilterModel?]()
        applyBeforeEnter(filterId: filterId)
        if let ids = subfiltersByFilter[filterId] {
            res = getEnabledSubFilters(ids: ids)
        }
        return Observable.just(res)
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
    
    
    private func getEnabledFiltersIds()->[Int?] {
        return filters
            .compactMap({$0.value})
            .filter({$0.enabled == true})
            .compactMap({$0.id})
            .sorted(by: {$0 < $1 })
    }
    
    
    private func getEnabledSubFiltersIds()->[Int?] {
        return subFilters
            .compactMap({$0.value})
            .filter({$0.enabled == true})
            .compactMap({$0.id})
            .sorted(by: {$0 < $1})
    }
    
    
    
    // Catalog Models:
    private func loadItemsFromDb(categoryId: Int, offset: Int){
        
        itemsByCatalog = TestData.loadCatalogs(categoryId: categoryId)
        
        let catalogModels = itemsByCatalog[categoryId] ?? []
        itemsById.removeAll()
        let limit = 5
       
        var next = ArraySlice<CatalogModel>()
        if catalogModels.count > offset{
           let end = max(catalogModels.count-1, offset + limit)
           next = catalogModels[offset...end]
        }
        
        next.forEach{ model in
            itemsById[model.id] = model
        }
    }
    
    
    private func getCatalogModel(categoryId: Int, appliedSubFilters: Set<Int>, offset: Int) -> [CatalogModel?]{
        loadItemsFromDb(categoryId: categoryId, offset: offset)
        
        guard appliedSubFilters.count > 0
        else {
            return itemsById.compactMap({$0.value}).sorted(by: {$0.id < $1.id })
        }
        
        
        groupApplying(applying: appliedSubFilters)
        
        
        let items = getItemsIntersect()
        
        
//
//        let itemIdsArr = appliedSubFilters
//        .compactMap({itemsBySubfilter[$0]})
//        .flatMap{$0}
//
//        let itemIdsSet = Set(itemIdsArr)
        
        
        
        let res = items
            .compactMap({itemsById[$0]})
        
        return res
    }
    
}


extension BackendLogic: ApiBackendLogic {
    
    
    func apiApplyFromFilter(appliedSubFilters: Set<Int>,  selectedSubFilters: Set<Int>) -> Observable<([Int?], [Int?], Set<Int>, Set<Int>)> {
        self.appliedSubFilters = appliedSubFilters
        self.selectedSubFilters = selectedSubFilters
        
        if self.appliedSubFilters.isEmpty && self.selectedSubFilters.isEmpty {
            resetFilters()
        } else {
            applyFromFilter()
        }
        let filtersIds = getEnabledFiltersIds()
        let subFiltersIds = getEnabledSubFiltersIds()
        return Observable.just((filtersIds, subFiltersIds, self.appliedSubFilters, self.selectedSubFilters))
    }
    
    func apiApplyFromSubFilters(filterId: Int, appliedSubFilters: Set<Int>, selectedSubFilters: Set<Int>) -> Observable<([Int?], [Int?], Set<Int>, Set<Int>)> {
        self.appliedSubFilters = appliedSubFilters
        self.selectedSubFilters = selectedSubFilters
        applyFromSubFilter(filterId: filterId)
        let filtersIds = getEnabledFiltersIds()
        let subFiltersIds = getEnabledSubFiltersIds()
        return Observable.just((filtersIds, subFiltersIds, self.appliedSubFilters, self.selectedSubFilters))
    }
    
    func apiRemoveFilter(filterId: Int, appliedSubFilters: Set<Int>,  selectedSubFilters: Set<Int>) -> Observable<([Int?], [Int?], Set<Int>, Set<Int>)> {
        self.appliedSubFilters = appliedSubFilters
        self.selectedSubFilters = selectedSubFilters
        removeFilter(filterId: filterId)
        let filtersIds = getEnabledFiltersIds()
        let subFiltersIds = getEnabledSubFiltersIds()
        return Observable.just((filtersIds, subFiltersIds, self.appliedSubFilters, self.selectedSubFilters))
    }
    
    
    func apiLoadSubFilters(filterId: Int = 0, appliedSubFilters: Set<Int>) -> Observable<(Int, [Int?], Set<Int>)> {
        self.appliedSubFilters = appliedSubFilters
        self.selectedSubFilters = []
        applyBeforeEnter(filterId: filterId)
        let subFiltersIds = getEnabledSubFiltersIds()
        return Observable.just((filterId, subFiltersIds, self.appliedSubFilters))
    }
    
    func apiLoadFilters() -> Observable<([FilterModel], [SubfilterModel])> {
        return Observable.just((TestData.loadFilters(), TestData.loadSubFilters(filterId: 0)))
    }
    
    
    func apiCatalogModel(categoryId: Int, appliedSubFilters: Set<Int>, offset: Int) -> Observable<[CatalogModel?]> {
        let catalogModel = getCatalogModel(categoryId: categoryId, appliedSubFilters: appliedSubFilters, offset: offset)
        return Observable.just(catalogModel)
    }

}
