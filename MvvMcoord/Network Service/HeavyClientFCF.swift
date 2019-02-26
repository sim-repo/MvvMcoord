import Foundation
import SwiftyJSON
import RxSwift
import Firebase
import FirebaseDatabase
import FirebaseFunctions


class HeavyClientFCF : NetworkFacadeBase {
    
    private override init(){}
    
    public static var shared = HeavyClientFCF()
    
    let backend: ApiBackendLogic = BackendLogic.shared
    
    typealias Completion = (() -> Void)?
    
    private var networkFunction: Completion
    
    
    private func runRequest(networkFunction: Completion = nil){
        networkFunction?()
    }
    
   
    private func firebaseHandleErr(error: NSError){
        if error.domain == FunctionsErrorDomain {
            let code = FunctionsErrorCode(rawValue: error.code)
            let message = error.localizedDescription
            let details = error.userInfo[FunctionsErrorDetailsKey]
            
            if code == FunctionsErrorCode.resourceExhausted {
                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(30), execute: {[weak self] in
                    self?.networkFunction?()
                })
            }
            print("error:\(code) : \(message) : \(details)")
        }
    }
    
    
    override func requestCatalogStart(categoryId: Int, appliedSubFilters: Set<Int>) {
        networkFunction = {
            functions.httpsCallable("catalogTotal").call(["useCache":true,
                                                          "categoryId":categoryId
            ]){ [weak self] (result, error) in
                guard let `self` = self else { return }
                if let error = error as NSError? {
                    self.firebaseHandleErr(error: error)
                    return
                }
                let fetchLimit_ = ParsingHelper.parseJsonVal(type: Int.self, result: result, key: "fetchLimit")
                
                let itemIds: ItemIds = ParsingHelper.parseJsonArr(result: result, key: "itemIds")
                let minPrice_ = ParsingHelper.parseJsonVal(type: Int.self, result: result, key: "minPrice")
                let maxPrice_ = ParsingHelper.parseJsonVal(type: Int.self, result: result, key: "maxPrice")
                
                
                guard let fetchLimit = fetchLimit_,
                    let minPrice = minPrice_,
                    let maxPrice = maxPrice_
                    else { return self.firebaseHandleErr(error: NSError(domain: FunctionsErrorDomain, code: 1, userInfo: ["Parse Int":0])  )}
                
                self.fireCatalogTotal(itemIds, fetchLimit, CGFloat(minPrice), CGFloat(maxPrice))
            }
        }
        runRequest(networkFunction: networkFunction)
    }
    
    
    
    override func requestCatalogModel(itemIds: [Int]) {
        networkFunction = {
            functions.httpsCallable("catalogEntities").call([ "useCache": true,
                                                              "itemsIds": itemIds
            ]){[weak self] (result, error) in
                guard let `self` = self else { return }
                
                if let error = error as NSError? {
                    self.firebaseHandleErr(error: error)
                    return
                }
                let arr:[CatalogModel] = ParsingHelper.parseJsonObjArr(result: result, key: "items")
                self.fireCatalogModel(catalogModel: arr)
            }
        }
        runRequest(networkFunction: networkFunction)
    }
    
    
    
    override func requestFullFilterEntities(categoryId: Int) {
        networkFunction = {
            functions.httpsCallable("heavyFullFilterEntities").call(["useCache":true
            ]) {[weak self] (result, error) in
                guard let `self` = self else { return }
                
                if let error = error as NSError? {
                    self.firebaseHandleErr(error: error)
                    return
                }
                
                
                let filters:[FilterModel] = ParsingHelper.parseJsonObjArr(result: result, key: "filters")
                let subfilters:[SubfilterModel] = ParsingHelper.parseJsonObjArr(result: result, key: "subFilters")
                let subfiltersByFilter = ParsingHelper.parseJsonDictWithValArr(result: result, key: "subfiltersByFilter")
                let subfiltersByItem = ParsingHelper.parseJsonDictWithValArr(result: result, key: "subfiltersByItem")
                let itemsBySubfilter = ParsingHelper.parseJsonDictWithValArr(result: result, key: "itemsBySubfilter")
                let priceByItemId = ParsingHelper.parseJsonDict(type: CGFloat.self, result: result, key: "priceByItemId")
                
                
                self.backend.setup(filters: filters,
                                   subFilters: subfilters,
                                   subfiltersByFilter: subfiltersByFilter,
                                   subfiltersByItem: subfiltersByItem,
                                   itemsBySubfilter: itemsBySubfilter,
                                   priceByItemId: priceByItemId)
                
                self.fireFullFilterEntities(filters, subfilters)
            }
        }
        runRequest(networkFunction: networkFunction)
    }
    
    
    
    override func requestEnterSubFilter(categoryId: Int, filterId: FilterId, appliedSubFilters: Applied, rangePrice: RangePrice) {

        
        
        backend.apiLoadSubFilters(filterId: filterId, appliedSubFilters: appliedSubFilters, rangePrice: rangePrice)
            .asObservable()
            .subscribe(onNext: {[weak self] res in
                let subfiltersIds = res.1
                let applied = res.2
                let countsItems = res.3
                self?.fireEnterSubFilter(filterId, subfiltersIds, applied, countsItems)
            })
            .disposed(by: bag)
    }
    
    
    
    override func requestApplyFromFilter(categoryId: Int, appliedSubFilters: Applied, selectedSubFilters: Selected, rangePrice: RangePrice) {
        backend.apiApplyFromFilter(appliedSubFilters: appliedSubFilters, selectedSubFilters: selectedSubFilters, rangePrice: rangePrice)
            .asObservable()
            .subscribe(onNext: {[weak self] res in
                let filterIds = res.0
                let subfilterIds = res.1
                let applied = res.2
                let selected = res.3
                let itemIds = res.4
                self?.fireApplyForItems(filterIds, subfilterIds, applied, selected, itemIds)
            })
            .disposed(by: bag)
    }
    
    
    
    override func requestApplyFromSubFilter(categoryId: Int, filterId: FilterId, appliedSubFilters: Applied, selectedSubFilters: Selected, rangePrice: RangePrice) {
        backend.apiApplyFromSubFilters(filterId: filterId, appliedSubFilters: appliedSubFilters, selectedSubFilters: selectedSubFilters, rangePrice: rangePrice)
        .asObservable()
            .subscribe(onNext: {[weak self] res in
                let filterIds = res.0
                let subfilterIds = res.1
                let applied = res.2
                let selected = res.3
                let rangePrice = res.4
                self?.fireApplyForFilters(filterIds,
                                           subfilterIds,
                                           applied,
                                           selected,
                                           rangePrice.tipMinPrice,
                                           rangePrice.tipMaxPrice)
            })
            .disposed(by: bag)
    }
    
    
    
    override func requestApplyByPrices(categoryId: Int, rangePrice: RangePrice) {
        backend.apiApplyByPrices(categoryId: categoryId, rangePrice: rangePrice)
        .asObservable()
            .subscribe(onNext: {[weak self] res in
                let filterIds: FilterIds = res
                self?.fireApplyByPrices(filterIds)
            })
            .disposed(by: bag)
    }
    
    
    override func requestRemoveFilter(categoryId: Int, filterId: FilterId, appliedSubFilters: Applied, selectedSubFilters: Selected, rangePrice: RangePrice) {
        backend.apiRemoveFilter(filterId: filterId, appliedSubFilters: appliedSubFilters, selectedSubFilters: selectedSubFilters, rangePrice: rangePrice)
            .asObservable()
            .subscribe(onNext: {[weak self] res in
                let filterIds = res.0
                let subfilterIds = res.1
                let applied = res.2
                let selected = res.3
                let rangePrice = res.4
                self?.fireApplyForFilters(filterIds,
                                           subfilterIds,
                                           applied,
                                           selected,
                                           rangePrice.tipMinPrice,
                                           rangePrice.tipMaxPrice)
            })
            .disposed(by: bag)
    }
    
    override func requestCleanupFromSubFilter(categoryId: Int, filterId: FilterId, appliedSubFilters: Applied, selectedSubFilters: Selected, rangePrice: RangePrice) {
        backend.apiRemoveFilter(filterId: filterId, appliedSubFilters: appliedSubFilters, selectedSubFilters: selectedSubFilters, rangePrice: rangePrice)
            .asObservable()
            .subscribe(onNext: {[weak self] res in
                let filterIds = res.0
                let subfilterIds = res.1
                let applied = res.2
                let selected = res.3
                let rangePrice = res.4
                self?.fireApplyForFilters(filterIds,
                                          subfilterIds,
                                          applied,
                                          selected,
                                          rangePrice.tipMinPrice,
                                          rangePrice.tipMaxPrice)
            })
            .disposed(by: bag)
    }
}
