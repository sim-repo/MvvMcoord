import Foundation
import SwiftyJSON
import RxSwift
import Firebase
import FirebaseDatabase
import FirebaseFunctions


class HeavyClientFCF : NetworkFacadeBase {
    
    private override init(){
        super.init()
    }
    
    public static var shared = HeavyClientFCF()
    
    let applyLogic: FilterApplyLogic = FilterApplyLogic.shared
    
    typealias Completion = (() -> Void)?
    
    private var task1: Completion
    private var task2: Completion
    private var task3: Completion
    internal var task4: Completion
    internal var task5: Completion
    internal var task6: Completion
    internal var task7: Completion
    
    private func runRequest(task: Completion = nil){
        task?()
    }
    
    private func showTime() -> String{
        let now = Date()
        
        let formatter = DateFormatter()
        
        formatter.timeZone = TimeZone.current
        
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm.ss.SSSZ"
        
        let dateString = formatter.string(from: now)
        return dateString
    }
    
   
    private func firebaseHandleErr(task: Completion ,error: NSError, delay: Int = 0){
        
        let period = delay == 0 ? 30 : delay
        
        if error.domain == FunctionsErrorDomain {
            let code = FunctionsErrorCode(rawValue: error.code)
            let message = error.localizedDescription
            let details = error.userInfo[FunctionsErrorDetailsKey]
            
          //  if code == FunctionsErrorCode.resourceExhausted {
            DispatchQueue.global().asyncAfter(deadline: .now() + .seconds(period), qos: .background) {
                task?()
            }
        
            print("error:\(String(describing: code)) : \(message) : \(String(describing: details))")
        }
    }
    
    
    override func loadCache(categoryId: Int){
        functions.httpsCallable("meta").call(["useCache":true,
                                              "categoryId":categoryId,
                                              "method":""]){ (result, error) in
        
        }
    }
    
    
    override func requestCatalogStart(categoryId: Int) {
        
        if let catalogTotal = GlobalCache.getCatalogTotal(categoryId: categoryId) {
            self.fireCatalogTotal(catalogTotal.itemIds, catalogTotal.fetchLimit, catalogTotal.minPrice, catalogTotal.maxPrice)
            return
        }
        
        task1 = {
            functions.httpsCallable("meta").call(["useCache":true,
                                                  "categoryId":categoryId,
                                                  "method":"getCatalogTotals"
            ]){ [weak self] (result, error) in
                guard let `self` = self else { return }
                if let error = error as NSError? {
                    self.firebaseHandleErr(task: self.task1, error: error)
                    return
                }
                let fetchLimit_ = ParsingHelper.parseJsonVal(type: Int.self, result: result, key: "fetchLimit")
                
                let itemIds: ItemIds = ParsingHelper.parseJsonArr(result: result, key: "itemIds")
                let minPrice_ = ParsingHelper.parseJsonVal(type: Int.self, result: result, key: "minPrice")
                let maxPrice_ = ParsingHelper.parseJsonVal(type: Int.self, result: result, key: "maxPrice")
                
                
                guard let fetchLimit = fetchLimit_,
                    let minPrice = minPrice_,
                    let maxPrice = maxPrice_
                    else { return self.firebaseHandleErr(task: self.task1, error: NSError(domain: FunctionsErrorDomain, code: 1, userInfo: ["Parse Int":0])  )}
                
                GlobalCache.setCatalogTotal(categoryId: categoryId, fetchLimit: fetchLimit, itemIds: itemIds, minPrice: CGFloat(minPrice), maxPrice: CGFloat(maxPrice))
                self.fireCatalogTotal(itemIds, fetchLimit, CGFloat(minPrice), CGFloat(maxPrice))
            }
        }
        runRequest(task: task1)
    }
    
    
    
    override func requestCatalogModel(itemIds: [Int]) {
        guard task2 == nil
            else { return }
        task2 = {
            functions.httpsCallable("meta").call(["useCache": true,
                                                  "itemsIds": itemIds,
                                                  "method":"getPrefetching"
            ]){[weak self] (result, error) in
                guard let `self` = self else { return }
                
                if let error = error as NSError? {
                    self.firebaseHandleErr(task: self.task2, error: error)
                    return
                }
                let arr:[CatalogModel] = ParsingHelper.parseJsonObjArr(result: result, key: "items")
                self.fireCatalogModel(catalogModel: arr)
                self.task2 = nil
            }
        }
        runRequest(task: task2)
    }
    
    
    override func requestFullFilterEntities(categoryId: Int) {
        task3 = { [weak self] in
            DispatchQueue.global(qos: .background).async {
                guard let `self` = self else { return }
                let filters = self.applyLogic.getFilters()
               // let subfilters = self.applyLogic.getSubFilters()
                
                guard filters.count > 0
                     // && subfilters.count > 0
                    else { return self.firebaseHandleErr(task: self.task4, error: NSError(domain: FunctionsErrorDomain, code: 1, userInfo: ["Parse Int":0]), delay: 1 )}
                
                
                DispatchQueue.main.asyncAfter(deadline: .now()) {
                 //   self.fireFullFilterEntities(filters, subfilters)
                    self.fireFilterChunk1(filters)
                }
            }
        }
        runRequest(task: task3)
    }
    
    
    
    override func requestEnterSubFilter(categoryId: Int, filterId: FilterId, appliedSubFilters: Applied, rangePrice: RangePrice) {
        applyLogic.doLoadSubFilters(filterId, appliedSubFilters, rangePrice)
            .asObservable()
            .observeOn(MainScheduler.asyncInstance)
            .subscribe(onNext: {[weak self] res in
                let subfiltersIds = res.1
                let applied = res.2
                let countsItems = res.3
                self?.fireEnterSubFilter(filterId, subfiltersIds, applied, countsItems)
            })
            .disposed(by: bag)
    }
    
    
    
    override func requestApplyFromFilter(categoryId: Int, appliedSubFilters: Applied, selectedSubFilters: Selected, rangePrice: RangePrice) {
       // DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(10)){[weak self] in
        self.applyLogic.doApplyFromFilter(appliedSubFilters, selectedSubFilters, rangePrice)
            .asObservable()
            .observeOn(MainScheduler.asyncInstance)
            .subscribe(onNext: {[weak self] res in
                let filterIds = res.0
                let subfilterIds = res.1
                let applied = res.2
                let selected = res.3
                let itemIds = res.4
                self?.fireApplyForItems(filterIds, subfilterIds, applied, selected, itemIds)
            })
            .disposed(by: bag)
       // }
    }
    
    
    
    override func requestApplyFromSubFilter(categoryId: Int, filterId: FilterId, appliedSubFilters: Applied, selectedSubFilters: Selected, rangePrice: RangePrice) {
        applyLogic.doApplyFromSubFilters(filterId, appliedSubFilters, selectedSubFilters, rangePrice)
        .asObservable()
        .observeOn(MainScheduler.asyncInstance)
            .subscribe(onNext: {[weak self] res in
                let filterIds = res.0
                let subfilterIds = res.1
                let applied = res.2
                let selected = res.3
                let rangePrice = res.4
                let itemsTotal = res.5
                self?.fireApplyForFilters(filterIds,
                                           subfilterIds,
                                           applied,
                                           selected,
                                           rangePrice.tipMinPrice,
                                           rangePrice.tipMaxPrice,
                                           itemsTotal)
            })
            .disposed(by: bag)
    }
    
    
    
    override func requestApplyByPrices(categoryId: Int, rangePrice: RangePrice) {
        applyLogic.doApplyByPrices(categoryId, rangePrice)
        .asObservable()
        .observeOn(MainScheduler.asyncInstance)
            .subscribe(onNext: {[weak self] res in
                let filterIds: FilterIds = res
                self?.fireApplyByPrices(filterIds)
            })
            .disposed(by: bag)
    }
    
    
    override func requestRemoveFilter(categoryId: Int, filterId: FilterId, appliedSubFilters: Applied, selectedSubFilters: Selected, rangePrice: RangePrice) {
        applyLogic.doRemoveFilter(filterId, appliedSubFilters, selectedSubFilters, rangePrice)
            .asObservable()
            .observeOn(MainScheduler.asyncInstance)
            .subscribe(onNext: {[weak self] res in
                let filterIds = res.0
                let subfilterIds = res.1
                let applied = res.2
                let selected = res.3
                let rangePrice = res.4
                let itemsTotal = res.5
                self?.fireApplyForFilters(filterIds,
                                           subfilterIds,
                                           applied,
                                           selected,
                                           rangePrice.tipMinPrice,
                                           rangePrice.tipMaxPrice,
                                           itemsTotal)
            })
            .disposed(by: bag)
    }
    
    
    override func requestPreloadFullFilterEntities(categoryId: Int) {
        print("start download \(self.showTime())")
        task4 = {
            functions.httpsCallable("heavyFullFilterEntities").call(["useCache":true
            ]) {[weak self] (result, error) in
                DispatchQueue.global(qos: .background).async {
                    guard let `self` = self else { return }
                    
                    if let error = error as NSError? {
                        self.firebaseHandleErr(task: self.task4, error: error)
                        return
                    }
                    
                    let filters:[FilterModel] = ParsingHelper.parseJsonObjArr(result: result, key: "filters")
                    let subfilters:[SubfilterModel] = ParsingHelper.parseJsonObjArr(result: result, key: "subFilters")
                    let subfiltersByFilter = ParsingHelper.parseJsonDictWithValArr(result: result, key: "subfiltersByFilter")
                    let subfiltersByItem = ParsingHelper.parseJsonDictWithValArr(result: result, key: "subfiltersByItem")
                    let itemsBySubfilter = ParsingHelper.parseJsonDictWithValArr(result: result, key: "itemsBySubfilter")
                    let priceByItemId = ParsingHelper.parseJsonDict(type: CGFloat.self, result: result, key: "priceByItemId")
                    
                    print("get data \(self.showTime())")
                    self.applyLogic.setup(filters: filters,
                                          subFilters: subfilters,
                                          subfiltersByFilter: subfiltersByFilter,
                                          subfiltersByItem: subfiltersByItem,
                                          itemsBySubfilter: itemsBySubfilter,
                                          priceByItemId: priceByItemId)
                   
                    
                }
            }
        }
        runRequest(task: task4)
    }
    
    
    override func requestPreloadFiltersChunk1(categoryId: Int) {
       
        if let filters = GlobalCache.getChunk1(categoryId: categoryId) {
            print("chunk1 use cache")
            applyLogic.setup(filters: filters)
            fireFilterChunk1(filters)
            didDownloadChunk1.onNext(Void())
            return
        }
        
        self.task5 = {
            functions.httpsCallable("meta").call(["useCache":true,
                                                  "categoryId":categoryId,
                                                  "method":"getFiltersChunk1"
            ]) {[weak self] (result, error) in
                    DispatchQueue.global(qos: .background).async {
                        guard let `self` = self else { return }
                        
                        if let error = error as NSError? {
                            self.firebaseHandleErr(task: self.task5, error: error)
                            return
                        }
                        
                        let filters:[FilterModel] = ParsingHelper.parseJsonObjArr(result: result, key: "filters")
                        
                        
                        guard filters.count > 0
                            else {
                                print("Ошибка!!!!")
                                self.firebaseHandleErr(task: self.task5, error: NSError(domain: FunctionsErrorDomain, code: 777, userInfo: ["Parse Int":0]))
                                  return }
                        
                        GlobalCache.setFilterEntities(categoryId: categoryId, filters: filters)
                        self.applyLogic.setup(filters: filters)
                        self.fireFilterChunk1(filters)
                        self.didDownloadChunk1.onNext(Void())
                }
            }
        }
        self.runRequest(task: self.task5)
    }
    
    
    override func requestPreloadSubFiltersChunk2(categoryId: Int) {
        
        if let (s1, s2) = GlobalCache.getChunk2(categoryId: categoryId) {
            if let subFilters = s1,
                let subfiltersByFilter = s2 {
                print("chunk2 use cache")
                applyLogic.setup(subFilters: subFilters, subfiltersByFilter: subfiltersByFilter)
                didDownloadChunk2.onNext(Void())
                fireFilterChunk2(subFilters)
                return
            }
        }
        
        self.task6 = {
            functions.httpsCallable("meta").call(["useCache":true,
                                                  "categoryId":categoryId,
                                                  "method":"getSubfiltersChunk2"
            ]) {[weak self] (result, error) in
                    guard let `self` = self else { return }
                
                    if let error = error as NSError? {
                        self.firebaseHandleErr(task: self.task6, error: error)
                        return
                    }
                
                    DispatchQueue.global(qos: .userInteractive).async {
                         let subFilters:[SubfilterModel] = ParsingHelper.parseJsonObjArr(result: result, key: "subFilters")
                         let subfiltersByFilter: SubfiltersByFilter = ParsingHelper.parseJsonDictWithValArr(result: result, key: "subfiltersByFilter")
                         GlobalCache.setFilterEntities(categoryId: categoryId, subFilters: subFilters, subfiltersByFilter: subfiltersByFilter)
                         self.applyLogic.setup(subFilters: subFilters, subfiltersByFilter: subfiltersByFilter)
                         self.didDownloadChunk2.onNext(Void())
                         self.fireFilterChunk2(subFilters)
                    }
                }
        }
        self.runRequest(task: self.task6)
    }
    
    
    override func requestPreloadItemsChunk3(categoryId: Int) {
        
        if let (s1, s2, s3) = GlobalCache.getChunk3(categoryId: categoryId) {
            if let subfiltersByItem = s1,
               let itemsBySubfilter = s2,
               let priceByItemId = s3 {
                print("chunk3 use cache")
                applyLogic.setup(subfiltersByItem: subfiltersByItem, itemsBySubfilter: itemsBySubfilter, priceByItemId: priceByItemId)
                didDownloadChunk3.onNext(Void())
                didDownloadChunk4.onNext(Void())
                didDownloadChunk5.onNext(Void())
                return
            }
        }
        
        task7 = {
            functions.httpsCallable("meta").call(["useCache":true,
                                                  "categoryId":categoryId,
                                                  "method":"getItemsChunk3"
            ]) {[weak self] (result, error) in
               
                    guard let `self` = self else { return }
                    
                    if let error = error as NSError? {
                        self.firebaseHandleErr(task: self.task7, error: error)
                        return
                    }
                    DispatchQueue.global(qos: .userInitiated).async {
                        let subfiltersByItem: SubfiltersByItem = ParsingHelper.parseJsonDictWithValArr(result: result, key: "subfiltersByItem")
                        GlobalCache.setFilterEntities(categoryId: categoryId, subfiltersByItem: subfiltersByItem)
                        self.applyLogic.setup(subfiltersByItem: subfiltersByItem)
                        self.didDownloadChunk3.onNext(Void())
                    }
                    DispatchQueue.global(qos: .userInitiated).async {
                        let itemsBySubfilter: ItemsBySubfilter = ParsingHelper.parseJsonDictWithValArr(result: result, key: "itemsBySubfilter")
                        GlobalCache.setFilterEntities(categoryId: categoryId, itemsBySubfilter: itemsBySubfilter)
                        self.applyLogic.setup(itemsBySubfilter: itemsBySubfilter)
                        self.didDownloadChunk4.onNext(Void())
                    }
                    DispatchQueue.global(qos: .userInitiated).async {
                        let priceByItemId: PriceByItemId = ParsingHelper.parseJsonDict(type: CGFloat.self, result: result, key: "priceByItemId")
                        GlobalCache.setFilterEntities(categoryId: categoryId, priceByItemId: priceByItemId)
                        self.applyLogic.setup(priceByItemId: priceByItemId)
                        self.didDownloadChunk5.onNext(Void())
                    }
            }
        }
        runRequest(task: task7)
    }
    
    
    override func requestMidTotal(categoryId: Int, appliedSubFilters: Applied, selectedSubFilters: Selected, rangePrice: RangePrice) {
        applyLogic.doCalcMidTotal(appliedSubFilters, selectedSubFilters, rangePrice)
            .asObservable()
            .observeOn(MainScheduler.asyncInstance)
            .subscribe(onNext: {[weak self] count in
                self?.fireMidTotal(count)
            })
            .disposed(by: bag)
    }
}
