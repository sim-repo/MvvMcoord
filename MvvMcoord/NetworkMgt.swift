import Foundation
import Alamofire
import SwiftyJSON
import RxSwift


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
    
    static let backend: ApiBackendLogic = BackendLogic.shared
    
    static var outAfterApplyResponse = PublishSubject<([Int?], [Int?], Set<Int>, Set<Int>)>()

    static let delay = 0
    
    
    // MARK: - next functions
    private static func nextCurrentSubFilterIds(filterId: Int, subFiltersIds: [Int?], appliedSubFilters: Set<Int>) {
        outCurrentSubFilterIds.onNext((filterId, subFiltersIds, appliedSubFilters))
    }
    
    private static func nextFullFilterEntities(filterModels: [FilterModel], subFilterModels: [SubfilterModel]) {
        outFullFilterEntities.onNext((filterModels, subFilterModels))
    }
    
    private static func nextAfterApplyingIds(filterIds: [Int?], subFiltersIds: [Int?], appliedSubFilters: Set<Int>, selectedSubFilters: Set<Int>) {
        outAfterApplyResponse.onNext((filterIds, subFiltersIds, appliedSubFilters, selectedSubFilters))
    }
    
    
    
    // MARK: - request functions
    public static func requestFullFilterEntities(categoryId: Int){
        //   let params: Parameters = [:]
        //AlamofireNetworkManager.request(clazz: FilterModel.self, urlPath: "", params: params, observer: reqFilter)
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(delay), execute: {
            backend.apiLoadFilters()
                .asObservable()
                .subscribe(onNext: {res in
                    nextFullFilterEntities(filterModels: res.0, subFilterModels: res.1)
                })
                .disposed(by: bag)
        })
    }
    
    
    public static func requestCurrentSubFilterIds(filterId: Int, appliedSubFilters: Set<Int>){
        // let params: Parameters = [:]
        //AlamofireNetworkManager.request(clazz: SubFilterModel.self, urlPath: "", params: params, observer: reqFilter)
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(delay), execute: {
            backend.apiLoadSubFilters(filterId: filterId, appliedSubFilters: appliedSubFilters)
                .asObservable()
                .subscribe(onNext: {res in
                    nextCurrentSubFilterIds(filterId: res.0, subFiltersIds: res.1, appliedSubFilters: res.2)
                })
                .disposed(by: bag)
        })
    }
    
    
    public static func requestApplyFromFilter(appliedSubFilters: Set<Int>, selectedSubFilters: Set<Int>){
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(delay), execute: {
            backend.apiApplyFromFilter(appliedSubFilters: appliedSubFilters, selectedSubFilters: selectedSubFilters)
                .asObservable()
                .share()
                .subscribe(onNext: { res in
                    nextAfterApplyingIds(filterIds: res.0, subFiltersIds: res.1, appliedSubFilters: res.2, selectedSubFilters: res.3)
                })
                .disposed(by: bag)
        })
    }
    
    public static func requestApplyFromSubFilter(filterId: Int, appliedSubFilters: Set<Int>, selectedSubFilters: Set<Int>){
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(delay), execute: {
            backend.apiApplyFromSubFilters(filterId: filterId, appliedSubFilters: appliedSubFilters, selectedSubFilters: selectedSubFilters)
                .asObservable()
                .share()
                .subscribe(onNext: { res in
                    nextAfterApplyingIds(filterIds: res.0, subFiltersIds: res.1, appliedSubFilters: res.2, selectedSubFilters: res.3)
                })
                .disposed(by: bag)
        })
    }
    
    
    public static func requestRemoveFilter(filterId: Int, appliedSubFilters: Set<Int>, selectedSubFilters: Set<Int>){
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(delay), execute: {
            backend.apiRemoveFilter(filterId: filterId, appliedSubFilters: appliedSubFilters, selectedSubFilters: selectedSubFilters)
                .asObservable()
                .share()
                .subscribe(onNext: { res in
                    nextAfterApplyingIds(filterIds: res.0, subFiltersIds: res.1, appliedSubFilters: res.2, selectedSubFilters: res.3)
                })
                .disposed(by: bag)
        })
    }
    
    
    public static func requestCleanupFromSubFilter(filterId: Int, appliedSubFilters: Set<Int>, selectedSubFilters: Set<Int>){
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(delay), execute: {
            backend.apiRemoveFilter(filterId: filterId, appliedSubFilters: appliedSubFilters, selectedSubFilters: selectedSubFilters)
                .asObservable()
                .share()
                .subscribe(onNext: { res in
                    nextAfterApplyingIds(filterIds: res.0, subFiltersIds: res.1, appliedSubFilters: res.2, selectedSubFilters: res.3)
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
