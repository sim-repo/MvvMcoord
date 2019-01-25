import Foundation
import Alamofire
import SwiftyJSON
import RxSwift


class NetworkMgt{
    static let baseURL = "https://api.vk.com/method/"
    
    private init(){}
    
    
    static let outFilters = BehaviorSubject<[FilterModel]>(value: [])
    static let outSubFilters = BehaviorSubject<[SubfilterModel]>(value: [])
    
    static let backend: ApiBackendLogic = BackendLogic.shared
    
    static var outApplyFromSubFilterResponse = PublishSubject<([Int?], [Int?], Set<Int>, Set<Int>)>()

    
    public static let sharedManager: SessionManager = {
        let config = URLSessionConfiguration.default
        config.httpAdditionalHeaders = SessionManager.defaultHTTPHeaders
        config.timeoutIntervalForRequest = 40
        config.timeoutIntervalForResource = 40
        let manager = Alamofire.SessionManager(configuration: config)
        return manager
    }()
    
    
    
    
    public static func requestFilters(categoryId: Int){
        
        //   let params: Parameters = [:]
        //AlamofireNetworkManager.request(clazz: FilterModel.self, urlPath: "", params: params, observer: reqFilter)
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2), execute: {
            print("network Filter done")
            
            backend.apiLoadFilters()
                .asObservable()
                .subscribe(onNext: {res in
                    outFilters.onNext(res)
                })
                .disposed(by: bag)
            
            backend.apiLoadSubFilters(filterId: 0)
                .asObservable()
                .subscribe(onNext: {res in
                    outSubFilters.onNext(res)
                })
                .disposed(by: bag)
        })
    }
    
    
    public static func requestSubFilters(filterId: Int){
        // let params: Parameters = [:]
        //AlamofireNetworkManager.request(clazz: SubFilterModel.self, urlPath: "", params: params, observer: reqFilter)
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2), execute: {
            print("network Sub done")
            backend.apiLoadSubFilters(filterId: filterId)
                .asObservable()
                .subscribe(onNext: {res in
                    outSubFilters.onNext(res)
                })
                .disposed(by: bag)
        })
    }
    
    
    public static func requestApplyFromSubFilter(filterId: Int, appliedSubFilters: Set<Int>, selectedSubFilters: Set<Int>){
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2), execute: {
            backend.apiApplyFromSubFilters(filterId: filterId, appliedSubFilters: appliedSubFilters, selectedSubFilters: selectedSubFilters)
                .asObservable()
                .share()
                .subscribe(onNext: { res in
                    outApplyFromSubFilterResponse.onNext((res.0, res.1, res.2, res.3 ))
                })
                .disposed(by: bag)
        })
    }
    
    
    public static func requestRemoveFilter(filterId: Int, appliedSubFilters: Set<Int>, selectedSubFilters: Set<Int>){
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2), execute: {
            backend.apiRemoveFilter(filterId: filterId, appliedSubFilters: appliedSubFilters, selectedSubFilters: selectedSubFilters)
                .asObservable()
                .share()
                .subscribe(onNext: { res in
                    outApplyFromSubFilterResponse.onNext((res.0, res.1, res.2, res.3 ))
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
