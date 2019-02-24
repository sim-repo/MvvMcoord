import Foundation
import SwiftyJSON
import RxSwift
import Firebase
import FirebaseDatabase
import FirebaseFunctions


var functions = Functions.functions()

class NetworkMgt{
    
    private init(){}
    
    static let baseURL = "https://api.vk.com/method/"
    
    public static let outFilterEntitiesResponse = BehaviorSubject<([FilterModel], [SubfilterModel])>(value: ([],[]))
    public static var outEnterSubFilterResponse = PublishSubject<(Int, [Int?], Set<Int>, [Int:Int])>()
    public static var outCatalogModel = PublishSubject<[CatalogModel?]>()
    public static var outCatalogTotal = BehaviorSubject<([Int], Int, CGFloat, CGFloat)>(value: ([],20, 0, 0))
    
    static let backend: ApiBackendLogic = BackendLogic.shared
    
    static var outApplyItemsResponse = PublishSubject<([Int?], [Int?], Set<Int>, Set<Int>, [Int])>()
    static var outApplyFiltersResponse = PublishSubject<([Int?], [Int?], Set<Int>, Set<Int>, CGFloat, CGFloat)>()
    static var outApplyByPrices = PublishSubject<[Int?]>()
    static let delay = 0
    
    
    // MARK: - next functions
    private static func nextEnterSubFilter(filterId: Int, subFiltersIds: [Int?], appliedSubFilters: Set<Int>, cntBySubfilterId: [Int:Int]) {
        outEnterSubFilterResponse.onNext((filterId, subFiltersIds, appliedSubFilters, cntBySubfilterId))
    }
    
    private static func nextFullFilterEntities(filterModels: [FilterModel], subFilterModels: [SubfilterModel]) {
        outFilterEntitiesResponse.onNext((filterModels, subFilterModels))
    }
    
    private static func nextApplyForItems(filterIds: [Int?], subFiltersIds: [Int?], appliedSubFilters: Set<Int>, selectedSubFilters: Set<Int>, itemIds: [Int]) {
        outApplyItemsResponse.onNext((filterIds, subFiltersIds, appliedSubFilters, selectedSubFilters, itemIds))
    }
    
    private static func nextApplyForFilters(filterIds: [Int?], subFiltersIds: [Int?], appliedSubFilters: Set<Int>, selectedSubFilters: Set<Int>, tipMinPrice: CGFloat, tipMaxPrice: CGFloat) {
        outApplyFiltersResponse.onNext((filterIds, subFiltersIds, appliedSubFilters, selectedSubFilters, tipMinPrice, tipMaxPrice))
    }
    
    private static func nextCatalogModel(catalogModel:[CatalogModel?]) {
        outCatalogModel.onNext(catalogModel)
    }
    
    private static func nextCatalogTotal(itemIds: [Int], fetchLimit: Int, minPrice: CGFloat, maxPrice: CGFloat) {
        outCatalogTotal.onNext((itemIds, fetchLimit, minPrice, maxPrice))
    }
    
    private static func nextApplyByPrices(filterIds: [Int?]) {
        outApplyByPrices.onNext(filterIds)
    }
    
    
    
    private static func parseJsonObjArr<T: ModelProtocol>(result: HTTPSCallableResult?, key:String)->[T]{
        var res: [T] = []
        if let text = (result?.data as? [String: Any])?[key] as? String,
            let data = text.data(using: .utf8),
            let json = try? JSON(data: data) {
            for j in json["items"].arrayValue {
                let t: T = T(json: j)
                res.append(t)
            }
        }
        return res
    }
    
    private static func parseJsonArr(result: HTTPSCallableResult?, key:String)->[Int]{
        var res: [Int] = []
        if let text = (result?.data as? [String: Any])?[key] as? String,
            let data = text.data(using: .utf8),
            let json = try? JSON(data: data) {
            for j in json["items"].arrayValue {
                res.append(j.intValue)
            }
        }
        return res
    }
    
    
    private static func parseJsonDict(result: HTTPSCallableResult?, key:String)->[Int:Int]{
        var res: [Int:Int] = [:]
        if let text = (result?.data as? [String: Any])?[key] as? String,
            let data = text.data(using: .utf8),
            let json = try? JSON(data: data) {
            for j in json["items"].arrayValue {
                let dict = j.dictionaryObject as! [String:Int]
                for(key,val) in dict {
                    res[Int(key)!] = val
                }
            }
        }
        return res
    }
    
    private static func parseJsonVal<T>(type: T.Type, result: HTTPSCallableResult?, key:String)->T?{
        if let text = (result?.data as? [String: Any])?[key] as? String,
            let data = text.data(using: .utf8),
            let json = try? JSON(data: data) {
            switch type {
            case is Int.Type:
                return json[key].intValue as? T
            case is CGFloat.Type:
                return json[key].floatValue as? T
            case is String.Type:
                return json[key].stringValue as? T
            default:
                return json[key].stringValue as? T
            }
        }
        return nil
    }
    
    
    private static func firebaseHandleErr(error: NSError){
        if error.domain == FunctionsErrorDomain {
            let code = FunctionsErrorCode(rawValue: error.code)
            let message = error.localizedDescription
            let details = error.userInfo[FunctionsErrorDetailsKey]
            
            if code == FunctionsErrorCode.resourceExhausted {
                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(30), execute: {
                    networkFunc?()
                })
            }
            
            print("error:\(code) : \(message) : \(details)")
        }
    }
    
    
    static var networkFunc: (() -> Void)?
    
    private static func runRequest(networkFunction: (()->Void)? = nil){
        networkFunction?()
    }
    
    
    public static func requestCatalogStart(categoryId: Int, appliedSubFilters: Set<Int>) {
        networkFunc = {
            functions.httpsCallable("catalogTotal").call(["useCache":true,
                                                          "categoryId":categoryId
            ]){ (result, error) in
                if let error = error as NSError? {
                    firebaseHandleErr(error: error)
                    return
                }
                let fetchLimit_ = parseJsonVal(type: Int.self, result: result, key: "fetchLimit")
                
                let itemIds:[Int] = parseJsonArr(result: result, key: "itemIds")
                let minPrice_ = parseJsonVal(type: Int.self, result: result, key: "minPrice")
                let maxPrice_ = parseJsonVal(type: Int.self, result: result, key: "maxPrice")
                
                
                guard let fetchLimit = fetchLimit_,
                    let minPrice = minPrice_,
                    let maxPrice = maxPrice_
                    else { return firebaseHandleErr(error: NSError(domain: FunctionsErrorDomain, code: 1, userInfo: ["Parse Int":0])  )}
                
                nextCatalogTotal(itemIds: itemIds, fetchLimit: fetchLimit, minPrice: CGFloat(minPrice), maxPrice: CGFloat(maxPrice))
            }
        }
        NetworkMgt.runRequest(networkFunction: networkFunc)
    }
    
    
    public static func requestCatalogModel(itemIds: [Int]) {
        networkFunc = {
            functions.httpsCallable("catalogEntities").call([ "useCache": true,
                                                              "itemsIds": itemIds
            ]){ (result, error) in
                if let error = error as NSError? {
                    firebaseHandleErr(error: error)
                    return
                }
                let arr:[CatalogModel] = parseJsonObjArr(result: result, key: "items")
                nextCatalogModel(catalogModel: arr)
            }
        }
        NetworkMgt.runRequest(networkFunction: networkFunc)
    }
    
    
    public static func requestFullFilterEntities(categoryId: Int){
        networkFunc = {
            functions.httpsCallable("fullFilterEntities").call(["useCache":true
            ]) {(result, error) in
                if let error = error as NSError? {
                    firebaseHandleErr(error: error)
                    return
                }
                let arr:[FilterModel] = parseJsonObjArr(result: result, key: "filters")
                let arr2:[SubfilterModel] = parseJsonObjArr(result: result, key: "subFilters")
                nextFullFilterEntities(filterModels: arr, subFilterModels: arr2)
            }
        }
        NetworkMgt.runRequest(networkFunction: networkFunc)
    }
    
    
    
    public static func requestEnterSubFilter(categoryId: Int, filterId: Int, appliedSubFilters: Set<Int>, rangePrice: RangePrice){
        networkFunc = {
            functions.httpsCallable("currSubFilterIds").call(["useCache":true,
                                                              "categoryId": categoryId,
                                                              "filterId":filterId,
                                                              "appliedSubFilters":Array(appliedSubFilters),
                                                              "userMinPrice":rangePrice.userMinPrice,
                                                              "userMaxPrice":rangePrice.userMaxPrice,
                                                              "tipMinPrice":rangePrice.tipMinPrice,
                                                              "tipMaxPrice":rangePrice.tipMaxPrice
            ]) {(result, error) in
                if let error = error as NSError? {
                    firebaseHandleErr(error: error)
                    return
                }
                let filterId_ = parseJsonVal(type: Int.self, result: result, key: "filterId")
                guard let filterId = filterId_
                    else { return firebaseHandleErr(error: NSError(domain: "parse INT error", code: 0, userInfo: [:]))}
                
                let arr:[Int] = parseJsonArr(result: result, key: "subFiltersIds")
                let arr2:[Int] = parseJsonArr(result: result, key: "appliedSubFiltersIds")
                let dict:[Int:Int] = parseJsonDict(result: result, key: "countItemsBySubfilter")
                nextEnterSubFilter(filterId: filterId, subFiltersIds: arr, appliedSubFilters: Set(arr2), cntBySubfilterId: dict)
            }
        }
        NetworkMgt.runRequest(networkFunction: networkFunc)
    }
    
    
    
    public static func requestApplyFromFilter(categoryId: Int, appliedSubFilters: Set<Int>, selectedSubFilters: Set<Int>, rangePrice: RangePrice){
        networkFunc = {
            functions.httpsCallable("applyFromFilterNow").call(["useCache":true,
                                                                "categoryId":categoryId,
                                                                "selectedSubFilters":Array(selectedSubFilters),
                                                                "appliedSubFilters":Array(appliedSubFilters),
                                                                "userMinPrice":rangePrice.userMinPrice,
                                                                "userMaxPrice":rangePrice.userMaxPrice,
                                                                "tipMinPrice":rangePrice.tipMinPrice,
                                                                "tipMaxPrice":rangePrice.tipMaxPrice
            ]) {(result, error) in
                if let error = error as NSError? {
                    firebaseHandleErr(error: error)
                    return
                }
                
                let arr:[Int] = parseJsonArr(result: result, key: "filtersIds")
                let arr2:[Int] = parseJsonArr(result: result, key: "subFiltersIds")
                let arr3:[Int] = parseJsonArr(result: result, key: "appliedSubFiltersIds")
                let arr4:[Int] = parseJsonArr(result: result, key: "selectedSubFiltersIds")
                let arr5:[Int] = parseJsonArr(result: result, key: "itemIds")
                
                nextApplyForItems(filterIds: arr, subFiltersIds: arr2, appliedSubFilters: Set(arr3), selectedSubFilters: Set(arr4), itemIds: arr5)
            }
        }
        NetworkMgt.runRequest(networkFunction: networkFunc)
    }
    
    public static func requestApplyFromSubFilter(categoryId: Int, filterId: Int, appliedSubFilters: Set<Int>, selectedSubFilters: Set<Int>, rangePrice: RangePrice){
        networkFunc = {
            functions.httpsCallable("applyFromSubFilterNow").call([ "useCache":true,
                                                                    "categoryId":categoryId,
                                                                    "filterId":filterId,
                                                                    "selectedSubFilters":Array(selectedSubFilters),
                                                                    "appliedSubFilters":Array(appliedSubFilters),
                                                                    "initialMinPrice":rangePrice.initialMinPrice,
                                                                    "initialMaxPrice":rangePrice.initialMaxPrice,
                                                                    "userMinPrice":rangePrice.userMinPrice,
                                                                    "userMaxPrice":rangePrice.userMaxPrice,
                                                                    "tipMinPrice":rangePrice.tipMinPrice,
                                                                    "tipMaxPrice":rangePrice.tipMaxPrice
            ]) {(result, error) in
                if let error = error as NSError? {
                    firebaseHandleErr(error: error)
                    return
                }
                
                let arr:[Int] = parseJsonArr(result: result, key: "filtersIds")
                let arr2:[Int] = parseJsonArr(result: result, key: "subFiltersIds")
                let arr3:[Int] = parseJsonArr(result: result, key: "appliedSubFiltersIds")
                let arr4:[Int] = parseJsonArr(result: result, key: "selectedSubFiltersIds")
                let sTipMinPrice_ = parseJsonVal(type: Int.self, result: result, key: "tipMinPrice")
                let sTipMaxPrice_ = parseJsonVal(type: Int.self, result: result, key: "tipMaxPrice")
                
                
                guard let tipMinPrice = sTipMinPrice_,
                    let tipMaxPrice = sTipMaxPrice_
                    else { return firebaseHandleErr(error: NSError(domain: FunctionsErrorDomain, code: 1, userInfo: ["Parse Int":0])  )}
                
                nextApplyForFilters(filterIds: arr,
                                    subFiltersIds: arr2,
                                    appliedSubFilters: Set(arr3),
                                    selectedSubFilters: Set(arr4),
                                    tipMinPrice: CGFloat(tipMinPrice),
                                    tipMaxPrice: CGFloat(tipMaxPrice)
                )
            }
        }
        NetworkMgt.runRequest(networkFunction: networkFunc)
    }
    
    
    public static func requestApplyByPrices(categoryId: Int, rangePrice: RangePrice){
        networkFunc = {
            functions.httpsCallable("applyByPrices").call(["useCache":true,
                                                           "categoryId":categoryId,
                                                           "userMinPrice":rangePrice.userMinPrice,
                                                           "userMaxPrice":rangePrice.userMaxPrice,
                                                           "tipMinPrice":rangePrice.tipMinPrice,
                                                           "tipMaxPrice":rangePrice.tipMaxPrice
            ]) {(result, error) in
                if let error = error as NSError? {
                    firebaseHandleErr(error: error)
                    return
                }
                
                let arr:[Int] = parseJsonArr(result: result, key: "filterIds")
                
                nextApplyByPrices(filterIds: arr)
            }
        }
        NetworkMgt.runRequest(networkFunction: networkFunc)
    }
    
    
    public static func requestRemoveFilter(categoryId: Int, filterId: Int, appliedSubFilters: Set<Int>, selectedSubFilters: Set<Int>, rangePrice: RangePrice){
        networkFunc = {
            functions.httpsCallable("apiRemoveFilter").call(["useCache":true,
                                                            "filterId":filterId,
                                                            "selectedSubFilters":Array(selectedSubFilters),
                                                            "appliedSubFilters":Array(appliedSubFilters),
                                                            "categoryId":categoryId,
                                                            "initialMinPrice":rangePrice.initialMinPrice,
                                                            "initialMaxPrice":rangePrice.initialMaxPrice,
                                                            "userMinPrice":rangePrice.userMinPrice,
                                                            "userMaxPrice":rangePrice.userMaxPrice,
                                                            "tipMinPrice":rangePrice.tipMinPrice,
                                                            "tipMaxPrice":rangePrice.tipMaxPrice
            ]) {(result, error) in
                if let error = error as NSError? {
                    firebaseHandleErr(error: error)
                }
                
                let arr:[Int] = parseJsonArr(result: result, key: "filtersIds")
                let arr2:[Int] = parseJsonArr(result: result, key: "subFiltersIds")
                let arr3:[Int] = parseJsonArr(result: result, key: "appliedSubFiltersIds")
                let arr4:[Int] = parseJsonArr(result: result, key: "selectedSubFiltersIds")
                let sTipMinPrice_ = parseJsonVal(type: Int.self, result: result, key: "tipMinPrice")
                let sTipMaxPrice_ = parseJsonVal(type: Int.self, result: result, key: "tipMaxPrice")
                
                
                guard let tipMinPrice = sTipMinPrice_,
                    let tipMaxPrice = sTipMaxPrice_
                    else { return firebaseHandleErr(error: NSError(domain: FunctionsErrorDomain, code: 1, userInfo: ["Parse Int":0])  )}
                
                nextApplyForFilters(filterIds: arr,
                                    subFiltersIds: arr2,
                                    appliedSubFilters: Set(arr3),
                                    selectedSubFilters: Set(arr4),
                                    tipMinPrice: CGFloat(tipMinPrice),
                                    tipMaxPrice: CGFloat(tipMaxPrice))
            
            }
        }
        NetworkMgt.runRequest(networkFunction: networkFunc)
    }
    
    
    public static func requestCleanupFromSubFilter(filterId: Int, appliedSubFilters: Set<Int>, selectedSubFilters: Set<Int>){
        networkFunc = {
            backend.apiRemoveFilter(filterId: filterId, appliedSubFilters: appliedSubFilters, selectedSubFilters: selectedSubFilters)
                .asObservable()
                .share()
                .subscribe(onNext: { res in
                    nextApplyForFilters(filterIds: res.0,
                                        subFiltersIds: res.1,
                                        appliedSubFilters: res.2,
                                        selectedSubFilters: res.3,
                                        tipMinPrice: 0,
                                        tipMaxPrice: 0
                    )
                })
                .disposed(by: bag)
        }
        NetworkMgt.runRequest(networkFunction: networkFunc)
    }
}
