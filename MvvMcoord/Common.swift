import UIKit


typealias CountItems = [Int:Int]
typealias FilterIds = [Int?]
typealias SubFilterIds = [Int?]
typealias Applied = Set<Int>
typealias Selected = Set<Int>
typealias FilterId = Int
typealias ItemIds = [Int]
typealias ApplyingByFilter = [Int:[Int]]
typealias Filters = [Int:FilterModel]
public typealias SubfiltersByFilter = [Int:[Int]]
typealias SectionSubFiltersByFilter = [Int:[SectionOfSubFilterModel]]
typealias SubFilters = [Int:SubfilterModel]
public typealias SubfiltersByItem = [Int: [Int]]
public typealias ItemsBySubfilter = [Int: [Int]]
public typealias ItemsById = [Int:CatalogModel]
typealias ItemsByCatalog = [Int:[CatalogModel]]
public typealias PriceByItemId = [Int:CGFloat]
typealias EnabledFilters = [Int:Bool]
typealias EnabledSubfilters = [Int:Bool]
typealias ItemsTotal = Int
typealias MinPrice = CGFloat
typealias MaxPrice = CGFloat



extension Date {
    func currentTimeMillis() -> Int64! {
        return Int64(self.timeIntervalSince1970 * 1000)
    }
}

enum ClientModeEnum {
    case heavy, light
}

var clientMode: ClientModeEnum = .heavy

func getNetworkService() -> NetworkFacadeProtocol {
    switch clientMode {
    case .heavy:
        return HeavyClientFCF.shared
    default:
        return LightClientFCF.shared
    }
}
