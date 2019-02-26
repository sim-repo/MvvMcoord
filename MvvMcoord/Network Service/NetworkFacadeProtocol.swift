import UIKit
import RxSwift

protocol NetworkFacadeProtocol {
    
    func requestCatalogStart(categoryId: Int, appliedSubFilters: Applied)

    func requestCatalogModel(itemIds: ItemIds)
    
    func requestFullFilterEntities(categoryId: Int)
    
    func requestEnterSubFilter(categoryId: Int, filterId: FilterId, appliedSubFilters: Applied, rangePrice: RangePrice)
    
    func requestApplyFromFilter(categoryId: Int, appliedSubFilters: Applied, selectedSubFilters: Selected, rangePrice: RangePrice)
    
    func requestApplyFromSubFilter(categoryId: Int, filterId: FilterId, appliedSubFilters: Applied, selectedSubFilters: Selected, rangePrice: RangePrice)
    
    func requestApplyByPrices(categoryId: Int, rangePrice: RangePrice)
    
    func requestRemoveFilter(categoryId: Int, filterId: FilterId, appliedSubFilters: Applied, selectedSubFilters: Selected, rangePrice: RangePrice)
    
    func requestCleanupFromSubFilter(categoryId: Int, filterId: FilterId, appliedSubFilters: Applied, selectedSubFilters: Selected, rangePrice: RangePrice)
    
    
    
    func getFullFilterEntitiesEvent() -> BehaviorSubject<([FilterModel], [SubfilterModel])>
    
    func getEnterSubFilterEvent() -> PublishSubject<(FilterId, SubFilterIds, Applied, CountItems)>
    
    func getApplyForItemsEvent() -> PublishSubject<(FilterIds, SubFilterIds, Applied, Selected, ItemIds)>
    
    func getApplyForFiltersEvent() -> PublishSubject<(FilterIds, SubFilterIds, Applied, Selected, CGFloat, CGFloat)>
    
    func getApplyByPriceEvent() -> PublishSubject<FilterIds>
    
    func getCatalogTotalEvent() -> BehaviorSubject<(ItemIds, Int, CGFloat, CGFloat)>
    
    func getCatalogModelEvent() -> PublishSubject<[CatalogModel?]>
    
}



class NetworkFacadeBase: NetworkFacadeProtocol {
    
    public init(){}
    
    internal var outFilterEntitiesResponse = BehaviorSubject<([FilterModel], [SubfilterModel])>(value: ([],[]))
    internal var outEnterSubFilterResponse = PublishSubject<(FilterId, SubFilterIds, Applied, CountItems)>()
    internal var outApplyItemsResponse = PublishSubject<(FilterIds, SubFilterIds, Applied, Selected, ItemIds)>()
    internal var outApplyFiltersResponse = PublishSubject<(FilterIds, SubFilterIds, Applied, Selected, CGFloat, CGFloat)>()
    internal var outApplyByPrices = PublishSubject<FilterIds>()
    internal var outCatalogTotal = BehaviorSubject<(ItemIds, Int, CGFloat, CGFloat)>(value: ([],20, 0, 0))
    internal var outCatalogModel = PublishSubject<[CatalogModel?]>()
    
    
    
    func requestCatalogStart(categoryId: Int, appliedSubFilters: Applied) {}
    
    func requestCatalogModel(itemIds: ItemIds) {}
    
    func requestFullFilterEntities(categoryId: Int) {}
    
    func requestEnterSubFilter(categoryId: Int, filterId: FilterId, appliedSubFilters: Applied, rangePrice: RangePrice) {}
    
    func requestApplyFromFilter(categoryId: Int, appliedSubFilters: Applied, selectedSubFilters: Selected, rangePrice: RangePrice) {}
    
    func requestApplyFromSubFilter(categoryId: Int, filterId: FilterId, appliedSubFilters: Applied, selectedSubFilters: Selected, rangePrice: RangePrice) {}
    
    func requestApplyByPrices(categoryId: Int, rangePrice: RangePrice) {}
    
    func requestRemoveFilter(categoryId: Int, filterId: FilterId, appliedSubFilters: Applied, selectedSubFilters: Selected, rangePrice: RangePrice) {}
    
    func requestCleanupFromSubFilter(categoryId: Int, filterId: FilterId, appliedSubFilters: Applied, selectedSubFilters: Selected, rangePrice: RangePrice) {}
    
    
    
    func getFullFilterEntitiesEvent() -> BehaviorSubject<([FilterModel], [SubfilterModel])> {
        return outFilterEntitiesResponse
    }
    
    func getEnterSubFilterEvent() -> PublishSubject<(FilterId, SubFilterIds, Applied, CountItems)>{
        return outEnterSubFilterResponse
    }
    
    func getApplyForItemsEvent() -> PublishSubject<(FilterIds, SubFilterIds, Applied, Selected, ItemIds)> {
        return outApplyItemsResponse
    }
    
    func getApplyForFiltersEvent() -> PublishSubject<(FilterIds, SubFilterIds, Applied, Selected, CGFloat, CGFloat)> {
        return outApplyFiltersResponse
    }
    
    func getApplyByPriceEvent() -> PublishSubject<FilterIds> {
        return outApplyByPrices
    }
    
    func getCatalogTotalEvent() -> BehaviorSubject<(ItemIds, Int, CGFloat, CGFloat)> {
        return outCatalogTotal
    }
    
    func getCatalogModelEvent() -> PublishSubject<[CatalogModel?]> {
        return outCatalogModel
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
    
    internal func fireApplyForFilters(_ filterIds: FilterIds, _ subFiltersIds: SubFilterIds, _ appliedSubFilters: Applied, _ selectedSubFilters: Selected, _ tipMinPrice: CGFloat, _ tipMaxPrice: CGFloat) {
        outApplyFiltersResponse.onNext((filterIds, subFiltersIds, appliedSubFilters, selectedSubFilters, tipMinPrice, tipMaxPrice))
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

}
