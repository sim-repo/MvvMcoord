import Foundation
import RxSwift
import RxDataSources
import SwiftyJSON

var bag = DisposeBag()

enum FilterEnum : String{
    case select, range, section
}

protocol ModelProtocol: class {
    init(json: JSON?) // need for AlamofireNetworkManager.parseJSON
}

public class FilterModel : ModelProtocol {
    
    var id: FilterId = 0
    var title: String = ""
    var categoryId: CategoryId = 0
    var filterEnum: FilterEnum = .select
    var enabled = true
    
    init(id: FilterId, title: String, categoryId: CategoryId, filterEnum: FilterEnum = .select){
        self.id = id
        self.title = title
        self.categoryId = categoryId
        self.filterEnum = filterEnum
        
        FilterApplyLogic.shared.addFilter(id: id, filter: self)
    }
    
    required init(json: JSON?) {
        if let json = json {
            self.id = json["id"].intValue
            self.title = json["title"].stringValue
            self.categoryId = json["categoryId"].intValue
            self.filterEnum = FilterEnum(rawValue: json["filterEnum"].stringValue)!
            self.enabled = json["enabled"].boolValue
        }
    }
}



public class SubfilterModel : ModelProtocol{
    var filterId: FilterId = 0
    var id: SubFilterId = 0
    var categoryId: CategoryId = 0
    var title: String = ""
    var enabled = true
    var sectionHeader = ""
    var countItems = 0
    
    init(id: SubFilterId, categoryId: CategoryId, filterId: FilterId, title: String, sectionHeader: String = "") {
        self.filterId = filterId
        self.id = id
        self.categoryId = categoryId
        self.title = title
        self.sectionHeader = sectionHeader
        FilterApplyLogic.shared.addSubF(id: id, subFilter: self)
    }
    
    required init(json: JSON?) {
        if let json = json {
            self.id = json["id"].intValue
            self.filterId = json["filterId"].intValue
            self.categoryId = json["categoryId"].intValue
            self.title = json["title"].stringValue
            self.enabled = json["enabled"].boolValue
            self.sectionHeader = json["sectionHeader"].stringValue
            FilterApplyLogic.shared.addSubF(id: id, subFilter: self)
        }
    }
}




public struct SectionOfSubFilterModel {
    var header: String
    public var items: [SubfilterModel]
}


extension SectionOfSubFilterModel: SectionModelType {
    public typealias Item = SubfilterModel
    
    public init(original: SectionOfSubFilterModel, items: [Item]) {
        self = original
        self.items = items
    }
}

