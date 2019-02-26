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
typealias SubfiltersByFilter = [Int:[Int]]
typealias SectionSubFiltersByFilter = [Int:[SectionOfSubFilterModel]]
typealias SubFilters = [Int:SubfilterModel]
typealias SubfiltersByItem = [Int: [Int]]
typealias ItemsBySubfilter = [Int: [Int]]
typealias ItemsById = [Int:CatalogModel]
typealias ItemsByCatalog = [Int:[CatalogModel]]
typealias PriceByItemId = [Int:CGFloat]
typealias EnabledFilters = [Int:Bool]
typealias EnabledSubfilters = [Int:Bool]

