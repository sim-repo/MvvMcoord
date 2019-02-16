import Foundation
import Alamofire
import SwiftyJSON
import RxSwift
import Firebase
import FirebaseDatabase
import FirebaseFunctions


var functions = Functions.functions()


class NetworkMgt{
    
    private init(){}
    public static let sharedManager: SessionManager = {
        let config = URLSessionConfiguration.default
        config.httpAdditionalHeaders = SessionManager.defaultHTTPHeaders
        config.timeoutIntervalForRequest = 40
        config.timeoutIntervalForResource = 40
        let manager = Alamofire.SessionManager(configuration: config)
        return manager
    }()
    
    static let baseURL = "https://api.vk.com/method/"

    public static let outFilterEntitiesResponse = BehaviorSubject<([FilterModel], [SubfilterModel])>(value: ([],[]))
    public static var outEnterSubFilterResponse = PublishSubject<(Int, [Int?], Set<Int>, [Int:Int])>()
    public static var outCatalogModel = PublishSubject<[CatalogModel?]>()
    public static var outCatalogTotal = BehaviorSubject<([Int], Int)>(value: ([],20))
    
    static let backend: ApiBackendLogic = BackendLogic.shared
    
    static var outApplyItemsResponse = PublishSubject<([Int?], [Int?], Set<Int>, Set<Int>, [Int])>()
    static var outApplyFiltersResponse = PublishSubject<([Int?], [Int?], Set<Int>, Set<Int>)>()
    
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
    
    private static func nextApplyForFilters(filterIds: [Int?], subFiltersIds: [Int?], appliedSubFilters: Set<Int>, selectedSubFilters: Set<Int>) {
        outApplyFiltersResponse.onNext((filterIds, subFiltersIds, appliedSubFilters, selectedSubFilters))
    }
    
    private static func nextCatalogModel(catalogModel:[CatalogModel?]) {
        outCatalogModel.onNext(catalogModel)
    }
    
    private static func nextCatalogTotal(itemIds: [Int], fetchLimit: Int) {
        outCatalogTotal.onNext((itemIds, fetchLimit))
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
    
    private static func parseJsonVal(result: HTTPSCallableResult?, key:String)->String{
        var res: String = ""
        if let text = (result?.data as? [String: Any])?[key] as? String,
            let data = text.data(using: .utf8),
            let json = try? JSON(data: data) {
                res = json[key].stringValue
        }
        return res
    }
    
    
    private static func firebaseHandleErr(error: NSError){
        if error.domain == FunctionsErrorDomain {
            let code = FunctionsErrorCode(rawValue: error.code)
            let message = error.localizedDescription
            let details = error.userInfo[FunctionsErrorDetailsKey]
            print("error:\(code) : \(message) : \(details)")
        }
    }
    
    
    public static func requestCatalogTotal(categoryId: Int, appliedSubFilters: Set<Int>) {
        functions.httpsCallable("catalogTotal").call(["useCache":true,
                                                      "categoryId":categoryId,
                                                     ]) {(result, error) in
            if let error = error as NSError? {
                firebaseHandleErr(error: error)
            }
            let sFetchLimit = parseJsonVal(result: result, key: "fetchLimit")
            guard let fetchLimit = Int(sFetchLimit) else {return}
            let itemIds:[Int] = parseJsonArr(result: result, key: "itemIds")
                                                       
            nextCatalogTotal(itemIds: itemIds, fetchLimit: fetchLimit)
        }
    }
    
    
    public static func requestCatalogModel(categoryId: Int, itemIds: [Int]) {
        print("requestCatalogModel")
        
        functions.httpsCallable("catalogEntities").call(["useCache": true,
                                                         "categoryId": categoryId,
                                                         "itemsIds": itemIds
                                                        ]) {(result, error) in
            if let error = error as NSError? {
                firebaseHandleErr(error: error)
            }
            let arr:[CatalogModel] = parseJsonObjArr(result: result, key: "items")
            nextCatalogModel(catalogModel: arr)
        }
    }
    
    
    // MARK: - request functions
    public static func requestFullFilterEntities(categoryId: Int){
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(delay), execute: {
            functions.httpsCallable("fullFilterEntities").call(["useCache":true]) {(result, error) in
                if let error = error as NSError? {
                    firebaseHandleErr(error: error)
                }
                let arr:[FilterModel] = parseJsonObjArr(result: result, key: "filters")
                let arr2:[SubfilterModel] = parseJsonObjArr(result: result, key: "subFilters")
                nextFullFilterEntities(filterModels: arr, subFilterModels: arr2)
            }
        })
    }
    
    
    
    public static func requestEnterSubFilter(filterId: Int, appliedSubFilters: Set<Int>){
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(delay), execute: {
            functions.httpsCallable("currSubFilterIds").call(["useCache":true, "filterId":filterId, "appliedSubFilters":Array(appliedSubFilters)]) {(result, error) in
                if let error = error as NSError? {
                    firebaseHandleErr(error: error)
                }
                let sfilterId = parseJsonVal(result: result, key: "filterId")
                guard let filterId = Int(sfilterId) else {return}
                let arr:[Int] = parseJsonArr(result: result, key: "subFiltersIds")
                let arr2:[Int] = parseJsonArr(result: result, key: "appliedSubFiltersIds")
                let dict:[Int:Int] = parseJsonDict(result: result, key: "countItemsBySubfilter")
                nextEnterSubFilter(filterId: filterId, subFiltersIds: arr, appliedSubFilters: Set(arr2), cntBySubfilterId: dict)
            }
        })
    }
    
    
    
    public static func requestApplyFromFilter(categoryId: Int, appliedSubFilters: Set<Int>, selectedSubFilters: Set<Int>){
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(delay), execute: {
            functions.httpsCallable("applyFromFilterNow").call(["useCache":true,
                                                                "selectedSubFilters":Array(selectedSubFilters),
                                                                "appliedSubFilters":Array(appliedSubFilters)]) {(result, error) in
                if let error = error as NSError? {
                    firebaseHandleErr(error: error)
                }
                
                let arr:[Int] = parseJsonArr(result: result, key: "filtersIds")
                let arr2:[Int] = parseJsonArr(result: result, key: "subFiltersIds")
                let arr3:[Int] = parseJsonArr(result: result, key: "appliedSubFiltersIds")
                let arr4:[Int] = parseJsonArr(result: result, key: "selectedSubFiltersIds")
                let arr5:[Int] = parseJsonArr(result: result, key: "itemIds")
                                                                    
                nextApplyForItems(filterIds: arr, subFiltersIds: arr2, appliedSubFilters: Set(arr3), selectedSubFilters: Set(arr4), itemIds: arr5)
            }
        })
    }
    
    public static func requestApplyFromSubFilter(filterId: Int, appliedSubFilters: Set<Int>, selectedSubFilters: Set<Int>){
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(delay), execute: {
            
            functions.httpsCallable("applyFromSubFilterNow").call([ "useCache":true,
                                                                    "filterId":filterId,
                                                                    "selectedSubFilters":Array(selectedSubFilters),
                                                                    "appliedSubFilters":Array(appliedSubFilters)]) {(result, error) in
                if let error = error as NSError? {
                    firebaseHandleErr(error: error)
                }
                                                                    
                let arr:[Int] = parseJsonArr(result: result, key: "filtersIds")
                let arr2:[Int] = parseJsonArr(result: result, key: "subFiltersIds")
                let arr3:[Int] = parseJsonArr(result: result, key: "appliedSubFiltersIds")
                let arr4:[Int] = parseJsonArr(result: result, key: "selectedSubFiltersIds")
                
                nextApplyForFilters(filterIds: arr, subFiltersIds: arr2, appliedSubFilters: Set(arr3), selectedSubFilters: Set(arr4))
            }
        })
    }
    
    
    public static func requestRemoveFilter(filterId: Int, appliedSubFilters: Set<Int>, selectedSubFilters: Set<Int>){
        
                functions.httpsCallable("apiRemoveFilter").call([   "useCache":true,
                                                                    "filterId":filterId,
                                                                    "selectedSubFilters":Array(selectedSubFilters),
                                                                    "appliedSubFilters":Array(appliedSubFilters)]) {(result, error) in
                                                                        if let error = error as NSError? {
                                                                            firebaseHandleErr(error: error)
                                                                        }
                                                                        
                    let arr:[Int] = parseJsonArr(result: result, key: "filtersIds")
                    let arr2:[Int] = parseJsonArr(result: result, key: "subFiltersIds")
                    let arr3:[Int] = parseJsonArr(result: result, key: "appliedSubFiltersIds")
                    let arr4:[Int] = parseJsonArr(result: result, key: "selectedSubFiltersIds")
                    
                    nextApplyForFilters(filterIds: arr, subFiltersIds: arr2, appliedSubFilters: Set(arr3), selectedSubFilters: Set(arr4))
                }
    }
    
    
    public static func requestCleanupFromSubFilter(filterId: Int, appliedSubFilters: Set<Int>, selectedSubFilters: Set<Int>){
        backend.apiRemoveFilter(filterId: filterId, appliedSubFilters: appliedSubFilters, selectedSubFilters: selectedSubFilters)
            .asObservable()
            .share()
            .subscribe(onNext: { res in
                nextApplyForFilters(filterIds: res.0, subFiltersIds: res.1, appliedSubFilters: res.2, selectedSubFilters: res.3)
            })
            .disposed(by: bag)
     
    }
    
    
    public static func request<T: ModelProtocol>(clazz: T.Type , urlPath: String, params: Parameters, observer: BehaviorSubject<[T]>){
        NetworkMgt.sharedManager.request(baseURL + urlPath, method: .get, parameters: params)
            .responseJSON{ response in
                switch response.result {
                case .success(let val):
                    let arr:[T]? = parseJSON(val)
                    if let arr = arr {
                        observer.onNext(arr)
                    }
                case .failure(let err):
                    observer.onError(err)
                }
        }
    }
    
    private static func parseJSON<T: ModelProtocol>(_ val: Any)->[T]?{
        let json = JSON(val)
        var res: [T] = []
        let arr = json["response"]["items"].arrayValue
        for j in arr {
            let t: T = T(json: j)
            res.append(t)
        }
        return res
    }
    
}
