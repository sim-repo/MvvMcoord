import UIKit
import RxSwift

protocol NetworkFacadeProtocol {
    
    func requestCatalogStart(categoryId: Int)

    func requestCatalogModel(itemIds: ItemIds)
    
    func requestFullFilterEntities(categoryId: Int)
    
    func requestEnterSubFilter(categoryId: Int, filterId: FilterId, appliedSubFilters: Applied, rangePrice: RangePrice)
    
    func requestApplyFromFilter(categoryId: Int, appliedSubFilters: Applied, selectedSubFilters: Selected, rangePrice: RangePrice)
    
    func requestApplyFromSubFilter(categoryId: Int, filterId: FilterId, appliedSubFilters: Applied, selectedSubFilters: Selected, rangePrice: RangePrice)
    
    func requestApplyByPrices(categoryId: Int, rangePrice: RangePrice)
    
    func requestRemoveFilter(categoryId: Int, filterId: FilterId, appliedSubFilters: Applied, selectedSubFilters: Selected, rangePrice: RangePrice)
    
    func requestPreloadFullFilterEntities(categoryId: Int)
    
    func requestPreloadFiltersChunk1(categoryId: Int)
    
    func requestPreloadSubFiltersChunk2(categoryId: Int)
    
    func requestPreloadItemsChunk3(categoryId: Int)
    
    func requestMidTotal(categoryId: Int, appliedSubFilters: Applied, selectedSubFilters: Selected, rangePrice: RangePrice)
    
    
    
    
    func getFullFilterEntitiesEvent() -> BehaviorSubject<([FilterModel], [SubfilterModel])>
    
    func getEnterSubFilterEvent() -> PublishSubject<(FilterId, SubFilterIds, Applied, CountItems)>
    
    func getApplyForItemsEvent() -> PublishSubject<(FilterIds, SubFilterIds, Applied, Selected, ItemIds)>
    
    func getApplyForFiltersEvent() -> PublishSubject<(FilterIds, SubFilterIds, Applied, Selected, MinPrice, MaxPrice, ItemsTotal)>
    
    func getApplyByPriceEvent() -> PublishSubject<FilterIds>
    
    func getCatalogTotalEvent() -> BehaviorSubject<(ItemIds, Int, MinPrice, MaxPrice)>
    
    func getCatalogModelEvent() -> PublishSubject<[CatalogModel?]>
    
    
    func getFilterChunk1() -> BehaviorSubject<[FilterModel]>
    
    func getSubFilterChunk2() -> BehaviorSubject<[SubfilterModel]>
    
    func getMidTotal() -> PublishSubject<ItemsTotal>
    
    func getDownloadsDoneEvent()-> PublishSubject<Void>
    
    func loadCache(categoryId: Int)
    
}



class NetworkFacadeBase: NetworkFacadeProtocol {
    
    public init(){setupDownload()}
    
    internal var outFilterEntitiesResponse = BehaviorSubject<([FilterModel], [SubfilterModel])>(value: ([],[]))
    internal var outEnterSubFilterResponse = PublishSubject<(FilterId, SubFilterIds, Applied, CountItems)>()
    internal var outApplyItemsResponse = PublishSubject<(FilterIds, SubFilterIds, Applied, Selected, ItemIds)>()
    internal var outApplyFiltersResponse = PublishSubject<(FilterIds, SubFilterIds, Applied, Selected, MinPrice, MaxPrice, ItemsTotal)>()
    internal var outApplyByPrices = PublishSubject<FilterIds>()
    internal var outCatalogTotal = BehaviorSubject<(ItemIds, Int, MinPrice, MaxPrice)>(value: ([],20, 0, 0))
    internal var outCatalogModel = PublishSubject<[CatalogModel?]>()
    
    internal var outFilterChunk1 = BehaviorSubject<[FilterModel]>(value: [])
    internal var outSubFilterChunk2 = BehaviorSubject<[SubfilterModel]>(value: [])
    internal var outTotals = PublishSubject<Int>()
    
    internal var didDownloadChunk1 = PublishSubject<Void>()
    internal var didDownloadChunk2 = PublishSubject<Void>()
    internal var didDownloadChunk3 = PublishSubject<Void>()
    internal var didDownloadChunk4 = PublishSubject<Void>()
    internal var didDownloadChunk5 = PublishSubject<Void>()
    internal var outDownloadsDone = PublishSubject<Void>()
    var didDownloadComplete: Observable<Void>?
    
    private func setupDownload(){
        let didDownloadComplete = Observable.combineLatest(didDownloadChunk1,
                                                           didDownloadChunk2,
                                                           didDownloadChunk3,
                                                           didDownloadChunk4,
                                                           didDownloadChunk5,
                                                           resultSelector:{
            didDownloadChunk1, didDownloadChunk2, didDownloadChunk3, didDownloadChunk4, didDownloadChunk5 in
            "okey!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
        })
        
        didDownloadComplete.subscribe(onNext: {[weak self] value in
            self?.outDownloadsDone.onNext(Void())
        })
        .disposed(by: bag)
    }
   
    func requestCatalogStart(categoryId: Int) {}
    
    func requestCatalogModel(itemIds: ItemIds) {}
    
    func requestFullFilterEntities(categoryId: Int) {}
    
    func requestEnterSubFilter(categoryId: Int, filterId: FilterId, appliedSubFilters: Applied, rangePrice: RangePrice) {}
    
    func requestApplyFromFilter(categoryId: Int, appliedSubFilters: Applied, selectedSubFilters: Selected, rangePrice: RangePrice) {}
    
    func requestApplyFromSubFilter(categoryId: Int, filterId: FilterId, appliedSubFilters: Applied, selectedSubFilters: Selected, rangePrice: RangePrice) {}
    
    func requestApplyByPrices(categoryId: Int, rangePrice: RangePrice) {}
    
    func requestRemoveFilter(categoryId: Int, filterId: FilterId, appliedSubFilters: Applied, selectedSubFilters: Selected, rangePrice: RangePrice) {}
    
    func requestPreloadFullFilterEntities(categoryId: Int) {}
    
    func requestPreloadFiltersChunk1(categoryId: Int) {}
    
    func requestPreloadSubFiltersChunk2(categoryId: Int) {}
    
    func requestPreloadItemsChunk3(categoryId: Int) {}
    
    func requestMidTotal(categoryId: Int, appliedSubFilters: Applied, selectedSubFilters: Selected, rangePrice: RangePrice) {}
    
    
    
    func getFullFilterEntitiesEvent() -> BehaviorSubject<([FilterModel], [SubfilterModel])> {
        return outFilterEntitiesResponse
    }
    
    func getEnterSubFilterEvent() -> PublishSubject<(FilterId, SubFilterIds, Applied, CountItems)>{
        return outEnterSubFilterResponse
    }
    
    func getApplyForItemsEvent() -> PublishSubject<(FilterIds, SubFilterIds, Applied, Selected, ItemIds)> {
        return outApplyItemsResponse
    }
    
    func getApplyForFiltersEvent() -> PublishSubject<(FilterIds, SubFilterIds, Applied, Selected, MinPrice, MaxPrice, ItemsTotal)> {
        return outApplyFiltersResponse
    }
    
    func getApplyByPriceEvent() -> PublishSubject<FilterIds> {
        return outApplyByPrices
    }
    
    func getCatalogTotalEvent() -> BehaviorSubject<(ItemIds, Int, MinPrice, MaxPrice)> {
        return outCatalogTotal
    }
    
    func getCatalogModelEvent() -> PublishSubject<[CatalogModel?]> {
        return outCatalogModel
    }
    
    func getFilterChunk1() -> BehaviorSubject<[FilterModel]> {
        return outFilterChunk1
    }
    
    func getSubFilterChunk2() -> BehaviorSubject<[SubfilterModel]> {
        return outSubFilterChunk2
    }
    
    func getMidTotal() -> PublishSubject<Int> {
        return outTotals
    }
    
    func getDownloadsDoneEvent()-> PublishSubject<Void> {
        return outDownloadsDone
    }
    
    
    internal func fireFullFilterEntities(_ filterModels: [FilterModel], _ subFilterModels: [SubfilterModel]) {
        outFilterEntitiesResponse.onNext((filterModels, subFilterModels))
    }
    
    internal func fireEnterSubFilter(_ filterId: FilterId, _ subFiltersIds: SubFilterIds, _ appliedSubFilters: Applied, _ cntBySubfilterId: CountItems) {
        outEnterSubFilterResponse.onNext((filterId, subFiltersIds, appliedSubFilters, cntBySubfilterId))
    }
    
    internal func fireApplyForItems(_ filterIds: FilterIds, _ subFiltersIds: SubFilterIds, _ appliedSubFilters: Applied, _ selectedSubFilters: Selected, _ itemIds: ItemIds) {
        outApplyItemsResponse.onNext((filterIds, subFiltersIds, appliedSubFilters, selectedSubFilters, itemIds))
    }
    
    internal func fireApplyForFilters(_ filterIds: FilterIds, _ subFiltersIds: SubFilterIds, _ appliedSubFilters: Applied, _ selectedSubFilters: Selected, _ tipMinPrice: CGFloat, _ tipMaxPrice: CGFloat, _ itemsTotal: ItemsTotal) {
        outApplyFiltersResponse.onNext((filterIds, subFiltersIds, appliedSubFilters, selectedSubFilters, tipMinPrice, tipMaxPrice, itemsTotal))
    }
    
    internal func fireApplyByPrices(_ filterIds: FilterIds) {
        outApplyByPrices.onNext(filterIds)
    }
    
    internal func fireCatalogModel(catalogModel:[CatalogModel?]) {
        outCatalogModel.onNext(catalogModel)
    }
    
    internal func fireCatalogTotal(_ itemIds: ItemIds, _ fetchLimit: Int, _ minPrice: CGFloat, _ maxPrice: CGFloat) {
        outCatalogTotal.onNext((itemIds, fetchLimit, minPrice, maxPrice))
    }
    
    internal func fireFilterChunk1(_ filterModel: [FilterModel]){
        outFilterChunk1.onNext(filterModel)
    }
    
    internal func fireFilterChunk2(_ subfilterModel: [SubfilterModel]){
        outSubFilterChunk2.onNext(subfilterModel)
    }
    
    internal func fireMidTotal(_ total: Int) {
        outTotals.onNext(total)
    }
    
    func loadCache(categoryId: Int) {
        
    }

}
