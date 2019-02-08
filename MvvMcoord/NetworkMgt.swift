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

    public static let outFullFilterEntities = BehaviorSubject<([FilterModel], [SubfilterModel])>(value: ([],[]))
    public static var outCurrentSubFilterIds = PublishSubject<(Int, [Int?], Set<Int>)>()
    public static var outCatalogModel = PublishSubject<[CatalogModel?]>()
    
    static let backend: ApiBackendLogic = BackendLogic.shared
    
    static var outApplyItemsResponse = PublishSubject<([Int?], [Int?], Set<Int>, Set<Int>)>()
    static var outApplyFiltersResponse = PublishSubject<([Int?], [Int?], Set<Int>, Set<Int>)>()
    
    static let delay = 0
    
    
    // MARK: - next functions
    private static func nextCurrentSubFilterIds(filterId: Int, subFiltersIds: [Int?], appliedSubFilters: Set<Int>) {
        outCurrentSubFilterIds.onNext((filterId, subFiltersIds, appliedSubFilters))
    }
    
    private static func nextFullFilterEntities(filterModels: [FilterModel], subFilterModels: [SubfilterModel]) {
        outFullFilterEntities.onNext((filterModels, subFilterModels))
    }
    
    private static func nextApplyForItems(filterIds: [Int?], subFiltersIds: [Int?], appliedSubFilters: Set<Int>, selectedSubFilters: Set<Int>) {
        outApplyItemsResponse.onNext((filterIds, subFiltersIds, appliedSubFilters, selectedSubFilters))
    }
    
    private static func nextApplyForFilters(filterIds: [Int?], subFiltersIds: [Int?], appliedSubFilters: Set<Int>, selectedSubFilters: Set<Int>) {
        outApplyFiltersResponse.onNext((filterIds, subFiltersIds, appliedSubFilters, selectedSubFilters))
    }
    
    private static func nextCatalogModel(catalogModel:[CatalogModel?]) {
        outCatalogModel.onNext(catalogModel)
    }
    
    private static func parseJSON<T: ModelProtocol>(result: HTTPSCallableResult?, key:String)->[T]{
        var res: [T] = []
        if let text = (result?.data as? [String: Any])?[key] as? String {
            if let data = text.data(using: .utf8) {
                if let json = try? JSON(data: data) {
                    for j in json["items"].arrayValue {
                        let t: T = T(json: j)
                        res.append(t)
                    }
                }
            }
        }
        return res
    }
    
    private static func parseJSON2(result: HTTPSCallableResult?, key:String)->[Int]{
        var res: [Int] = []
        if let text = (result?.data as? [String: Any])?[key] as? String {
            if let data = text.data(using: .utf8) {
                if let json = try? JSON(data: data) {
                    for j in json["items"].arrayValue {
                        res.append(j.intValue)
                    }
                }
            }
        }
        return res
    }
    
    private static func parseJSON3(result: HTTPSCallableResult?, key:String)->Int{
        var res: Int = 0
        if let text = (result?.data as? [String: Any])?["filterId"] as? String {
            if let data = text.data(using: .utf8) {
                if let json = try? JSON(data: data) {
                    res = json["filterId"].intValue
                }
            }
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
    
    
    
    
    public static func requestCatalogModel(categoryId: Int, appliedSubFilters: Set<Int>, offset: Int) {
        print("requestCatalogModel")
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(delay), execute: {
                backend.apiCatalogModel(categoryId: categoryId, appliedSubFilters: appliedSubFilters, offset: offset)
                    .asObservable()
                    .subscribe(onNext: {res in
                        nextCatalogModel(catalogModel: res)
                    })
                    .disposed(by: bag)
            })
    }
    
    
    // MARK: - request functions
    public static func requestFullFilterEntities(categoryId: Int){
        //   fbCallFullFilterEntities()
        //   let params: Parameters = [:]
        //AlamofireNetworkManager.request(clazz: FilterModel.self, urlPath: "", params: params, observer: reqFilter)
        //        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(delay), execute: {
        //            backend.apiLoadFilters()
        //                .asObservable()
        //                .subscribe(onNext: {res in
        //                    nextFullFilterEntities(filterModels: res.0, subFilterModels: res.1)
        //                })
        //                .disposed(by: bag)
        //        })
       
        functions.httpsCallable("fullFilterEntities").call(["useCache":true]) {(result, error) in
            if let error = error as NSError? {
                firebaseHandleErr(error: error)
            }
            let arr:[FilterModel] = parseJSON(result: result, key: "filters")
            let arr2:[SubfilterModel] = parseJSON(result: result, key: "subFilters")
            nextFullFilterEntities(filterModels: arr, subFilterModels: arr2)
        }
    }
    
    
    
    
    
    public static func requestCurrentSubFilterIds(filterId: Int, appliedSubFilters: Set<Int>){
        // let params: Parameters = [:]
        //AlamofireNetworkManager.request(clazz: SubFilterModel.self, urlPath: "", params: params, observer: reqFilter)
//        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(delay), execute: {
//            backend.apiLoadSubFilters(filterId: filterId, appliedSubFilters: appliedSubFilters)
//                .asObservable()
//                .subscribe(onNext: {res in
//                    nextCurrentSubFilterIds(filterId: res.0, subFiltersIds: res.1, appliedSubFilters: res.2)
//                })
//                .disposed(by: bag)
//        })

        functions.httpsCallable("currSubFilterIds").call(["useCache":true, "filterId":filterId, "appliedSubFilters":Array(appliedSubFilters)]) {(result, error) in
            if let error = error as NSError? {
                firebaseHandleErr(error: error)
            }
            
            
            let filterId = parseJSON3(result: result, key: "filterId")
            let arr:[Int] = parseJSON2(result: result, key: "subFiltersIds")
            let arr2:[Int] = parseJSON2(result: result, key: "appliedSubFiltersIds")
            
            nextCurrentSubFilterIds(filterId: filterId, subFiltersIds: arr, appliedSubFilters: Set(arr2))
        }
    }
    
    
    
    public static func requestApplyFromFilter(appliedSubFilters: Set<Int>, selectedSubFilters: Set<Int>){
//        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(delay), execute: {
//            backend.apiApplyFromFilter(appliedSubFilters: appliedSubFilters, selectedSubFilters: selectedSubFilters)
//                .asObservable()
//                .share()
//                .subscribe(onNext: { res in
//                    nextAfterApplyingIds(filterIds: res.0, subFiltersIds: res.1, appliedSubFilters: res.2, selectedSubFilters: res.3)
//                })
//                .disposed(by: bag)
//        })
//
        functions.httpsCallable("applyFromFilterNow").call(["useCache":true,
                                                            "selectedSubFilters":Array(selectedSubFilters),
                                                            "appliedSubFilters":Array(appliedSubFilters)]) {(result, error) in
            if let error = error as NSError? {
                firebaseHandleErr(error: error)
            }
            
            let arr:[Int] = parseJSON2(result: result, key: "filtersIds")
            let arr2:[Int] = parseJSON2(result: result, key: "subFiltersIds")
            let arr3:[Int] = parseJSON2(result: result, key: "appliedSubFiltersIds")
            let arr4:[Int] = parseJSON2(result: result, key: "selectedSubFiltersIds")
            
            nextApplyForItems(filterIds: arr, subFiltersIds: arr2, appliedSubFilters: Set(arr3), selectedSubFilters: Set(arr4))
        }
    }
    
    public static func requestApplyFromSubFilter(filterId: Int, appliedSubFilters: Set<Int>, selectedSubFilters: Set<Int>){
//        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(delay), execute: {
//            backend.apiApplyFromSubFilters(filterId: filterId, appliedSubFilters: appliedSubFilters, selectedSubFilters: selectedSubFilters)
//                .asObservable()
//                .share()
//                .subscribe(onNext: { res in
//                    nextAfterApplyingIds(filterIds: res.0, subFiltersIds: res.1, appliedSubFilters: res.2, selectedSubFilters: res.3)
//                })
//                .disposed(by: bag)
//        })
        
        functions.httpsCallable("applyFromSubFilterNow").call([ "useCache":true,
                                                                "filterId":filterId,
                                                                "selectedSubFilters":Array(selectedSubFilters),
                                                                "appliedSubFilters":Array(appliedSubFilters)]) {(result, error) in
            if let error = error as NSError? {
                firebaseHandleErr(error: error)
            }
                                                                
            let arr:[Int] = parseJSON2(result: result, key: "filtersIds")
            let arr2:[Int] = parseJSON2(result: result, key: "subFiltersIds")
            let arr3:[Int] = parseJSON2(result: result, key: "appliedSubFiltersIds")
            let arr4:[Int] = parseJSON2(result: result, key: "selectedSubFiltersIds")
            
            nextApplyForFilters(filterIds: arr, subFiltersIds: arr2, appliedSubFilters: Set(arr3), selectedSubFilters: Set(arr4))
        }
    }
    
    
    public static func requestRemoveFilter(filterId: Int, appliedSubFilters: Set<Int>, selectedSubFilters: Set<Int>){
//        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(delay), execute: {
//            backend.apiRemoveFilter(filterId: filterId, appliedSubFilters: appliedSubFilters, selectedSubFilters: selectedSubFilters)
//                .asObservable()
//                .share()
//                .subscribe(onNext: { res in
//                    nextAfterApplyingIds(filterIds: res.0, subFiltersIds: res.1, appliedSubFilters: res.2, selectedSubFilters: res.3)
//                })
//                .disposed(by: bag)
//        })
        
        functions.httpsCallable("apiRemoveFilter").call([   "useCache":true,
                                                            "filterId":filterId,
                                                            "selectedSubFilters":Array(selectedSubFilters),
                                                            "appliedSubFilters":Array(appliedSubFilters)]) {(result, error) in
                                                                if let error = error as NSError? {
                                                                    firebaseHandleErr(error: error)
                                                                }
                                                                
            let arr:[Int] = parseJSON2(result: result, key: "filtersIds")
            let arr2:[Int] = parseJSON2(result: result, key: "subFiltersIds")
            let arr3:[Int] = parseJSON2(result: result, key: "appliedSubFiltersIds")
            let arr4:[Int] = parseJSON2(result: result, key: "selectedSubFiltersIds")
            
            nextApplyForFilters(filterIds: arr, subFiltersIds: arr2, appliedSubFilters: Set(arr3), selectedSubFilters: Set(arr4))
        }
    }
    
    
    public static func requestCleanupFromSubFilter(filterId: Int, appliedSubFilters: Set<Int>, selectedSubFilters: Set<Int>){
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(delay), execute: {
            backend.apiRemoveFilter(filterId: filterId, appliedSubFilters: appliedSubFilters, selectedSubFilters: selectedSubFilters)
                .asObservable()
                .share()
                .subscribe(onNext: { res in
                    nextApplyForItems(filterIds: res.0, subFiltersIds: res.1, appliedSubFilters: res.2, selectedSubFilters: res.3)
                })
                .disposed(by: bag)
        })
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
