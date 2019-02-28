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
    
    
    override func requestCatalogStart(categoryId: Int, appliedSubFilters: Set<Int>) {
        task1 = {
            functions.httpsCallable("catalogTotal").call(["useCache":true,
                                                          "categoryId":categoryId
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
                
                self.fireCatalogTotal(itemIds, fetchLimit, CGFloat(minPrice), CGFloat(maxPrice))
            }
        }
        runRequest(task: task1)
    }
    
    
    
    override func requestCatalogModel(itemIds: [Int]) {
        task2 = {
            functions.httpsCallable("catalogEntities").call([ "useCache": true,
                                                              "itemsIds": itemIds
            ]){[weak self] (result, error) in
                guard let `self` = self else { return }
                
                if let error = error as NSError? {
                    self.firebaseHandleErr(task: self.task2, error: error)
                    return
                }
                let arr:[CatalogModel] = ParsingHelper.parseJsonObjArr(result: result, key: "items")
                self.fireCatalogModel(catalogModel: arr)
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
        applyLogic.doApplyFromFilter(appliedSubFilters, selectedSubFilters, rangePrice)
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
                        self.firebaseHandleErr(task: self.task3, error: error)
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
    
    
    override func requestPreloadFiltersChunk1() {
       // DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(10)) {[weak self] in
        self.task5 = {
            functions.httpsCallable("filtersChunk1").call(["useCache":true
            ]) {[weak self] (result, error) in
                DispatchQueue.global(qos: .background).async {
                    guard let `self` = self else { return }
                    
                    if let error = error as NSError? {
                        self.firebaseHandleErr(task: self.task3, error: error)
                        return
                    }
                    let filters:[FilterModel] = ParsingHelper.parseJsonObjArr(result: result, key: "filters")
                    self.applyLogic.setup(filters: filters)
                    self.fireFilterChunk1(filters)
                    self.didDownloadChunk1.onNext(Void())
                }
            }
        }
        self.runRequest(task: self.task5)
            
      // }

    }
    
    
    override func requestPreloadSubFiltersChunk2() {
          //DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(10)) {[weak self] in
            self.task6 = {
                functions.httpsCallable("subFiltersChunk2").call(["useCache":true
                ]) {[weak self] (result, error) in
                        guard let `self` = self else { return }
                    
                        if let error = error as NSError? {
                            self.firebaseHandleErr(task: self.task3, error: error)
                            return
                        }
                    
                        DispatchQueue.global(qos: .userInteractive).async {
                             let subFilters:[SubfilterModel] = ParsingHelper.parseJsonObjArr(result: result, key: "subFilters")
                            // self.applyLogic.setup(subFilters: subFilters)
                             let subfiltersByFilter = ParsingHelper.parseJsonDictWithValArr(result: result, key: "subfiltersByFilter")
                             self.applyLogic.setup(subFilters: subFilters, subfiltersByFilter: subfiltersByFilter)
                            // DispatchQueue.main.asyncAfter(deadline: .now()) {
                                self.didDownloadChunk2.onNext(Void())
                                self.fireFilterChunk2(subFilters)
                           //  }
                        }
                    
//                        DispatchQueue.global(qos: .userInteractive).async {
//                            let subfiltersByFilter = ParsingHelper.parseJsonDictWithValArr(result: result, key: "subfiltersByFilter")
//                            self.applyLogic.setup(subfiltersByFilter: subfiltersByFilter)
//                            self.didDownloadChunk2.onNext(Void())
//                        }
                    }
          // }
            
        }
        self.runRequest(task: self.task6)
      //  }
    }
    
    
    override func requestPreloadItemsChunk3() {
        task7 = {
            functions.httpsCallable("itemsChunk3").call(["useCache":true
            ]) {[weak self] (result, error) in
               
                    guard let `self` = self else { return }
                    
                    if let error = error as NSError? {
                        self.firebaseHandleErr(task: self.task3, error: error)
                        return
                    }
                    DispatchQueue.global(qos: .userInitiated).async {
                        let subfiltersByItem = ParsingHelper.parseJsonDictWithValArr(result: result, key: "subfiltersByItem")
                        self.applyLogic.setup(subfiltersByItem: subfiltersByItem)
                        
                        self.didDownloadChunk3.onNext(Void())
                    }
                    DispatchQueue.global(qos: .userInitiated).async {
                        let itemsBySubfilter = ParsingHelper.parseJsonDictWithValArr(result: result, key: "itemsBySubfilter")
                        self.applyLogic.setup(itemsBySubfilter: itemsBySubfilter)
                        
                        self.didDownloadChunk4.onNext(Void())
                    }
                    DispatchQueue.global(qos: .userInitiated).async {
                        let priceByItemId = ParsingHelper.parseJsonDict(type: CGFloat.self, result: result, key: "priceByItemId")
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
