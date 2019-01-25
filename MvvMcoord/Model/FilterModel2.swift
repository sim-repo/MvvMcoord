import Foundation
import RxSwift
import RxDataSources
import SwiftyJSON

//  loc - можно хранить локально
//  remote - хранится на сервере

var bag = DisposeBag()

//var filters: [Int:FilterModel] = [:]    //loc
//var subfiltersByFilter: [Int:[Int]] = [:]   // loc
//var sectionedSubFiltersByFilter: [Int:[SectionOfSubFilterModel]] = [:]  //loc
//
//var subfiltersByItem: [Int: [Int]] = [:]    //remote
//var itemsBySubfilter: [Int: [Int]] = [:]    //remote
//var subFilters: [Int:SubfilterModel] = [:]  //loc
//
//var appliedSubFilters: Set<Int> = Set() //loc
//var selectedSubFilters: Set<Int> = Set()    //loc
//var applyingByFilter: [Int:[Int]] = [:] //loc


enum FilterEnum : String{
    case select, range, section
}

protocol ModelProtocol: class {
    init(json: JSON?) // need for AlamofireNetworkManager.parseJSON
}

class FilterModel : ModelProtocol {
    
    var id = 0
    var title: String = ""
    var categoryId = 0
    var filterEnum: FilterEnum = .select
    var enabled = true
    
    init(id: Int, title: String, categoryId: Int, filterEnum: FilterEnum = .select){
        self.id = id
        self.title = title
        self.categoryId = categoryId
        self.filterEnum = filterEnum
        
        BackendLogic.shared.addFilter(id: id, filter: self)
    }
    
    required init(json: JSON?) {
        if let json = json {
            id = json["id"].intValue
            title = json["title"].stringValue
            categoryId = json["categoryId"].intValue
            filterEnum = FilterEnum(rawValue: json["type"].stringValue) ?? .select
            enabled = true
        }
    }
    
    
    
    
    
    //
    //    static func nerworkRequest(categoryId: Int)->Observable<[FilterModel]?> {
    //        let res = filters
    //            .filter({$0.value.categoryId == categoryId})
    //            .compactMap({$0.value})
    //        return Observable.just(res)
    //    }
    //
    //
    //    static func localRequest(categoryId: Int) -> Observable<[FilterModel?]> {
    //        let res = filters
    //            .filter({$0.value.categoryId == categoryId})
    //            .compactMap({$0.value})
    //            .filter({$0.enabled == true})
    //            .sorted(by: {$0.id < $1.id})
    //        return Observable.just(res)
    //    }
    
    //
    //    static func localAppliedTitles(filterId: Int) -> String {
    //        var res = ""
    //        let arr = appliedSubFilters
    //                    .compactMap({subFilters[$0]})
    //                    .filter({$0.filterId == filterId && $0.enabled == true})
    //        arr.forEach({ subf in
    //            res.append(subf.title + ",")
    //        })
    //        if res.count > 0 {
    //            res.removeLast()
    //        }
    //        return res
    //    }
    //
    //    static func enableFilters(filterId: Int){
    //        filters[filterId]?.enabled = true
    //    }
    //
    //    static func enableAllFilters(exceptFilterId: Int = 0 ,enable: Bool){
    //        for (_, val) in filters {
    //            val.enabled = enable
    //        }
    //        if exceptFilterId != 0 {
    //            filters[exceptFilterId]?.enabled = true
    //        }
    //    }
    //
    //    static func applyFilters(){
    //        let selected = selectedSubFilters
    //        let applied = SubfilterModel.getApplied()
    //        let applying = selected.union(applied)
    //        if applying.count > 0 {
    //
    //            SubfilterModel.groupApplying(applying: applying)
    //
    //            let items = SubfilterModel.getItems()
    //
    //            let rem = SubfilterModel.getSubFilters(by: items)
    //
    //            FilterModel.enableAllFilters(enable: false)
    //            SubfilterModel.enableAllSubFilters( enable: false)
    //
    //            rem.forEach{ id in
    //                if let subFilter = subFilters[id] {
    //                    subFilter.enabled = true
    //                    FilterModel.enableFilters(filterId: subFilter.filterId)
    //                }
    //            }
    //            selectedSubFilters = Set(applying)
    //            appliedSubFilters = Set(applying)
    //        }
    //    }
    //
    //    static func removeFilter(filterId: Int) {
    //        SubfilterModel.removeApplied(filterId: filterId)
    //        SubfilterModel.applyAfterRemove()
    //    }
}



class SubfilterModel {
    var filterId = 0
    var id = 0
    var title: String
    var enabled = true
    var sectionHeader = ""
    
    init(id: Int, filterId: Int, title: String, sectionHeader: String = "") {
        self.filterId = filterId
        self.id = id
        self.title = title
        self.sectionHeader = sectionHeader
        BackendLogic.shared.addSubF(id: id, subFilter: self)
    }
    
    
    
    
    static func loadItems(filterId: Int = 0) -> [SubfilterModel] {
        var tmp: [SubfilterModel] = []
        
        // Brands
        if filterId == 1 || filterId == 0{
            let f10 = SubfilterModel(id:1, filterId: 1, title: "Abby", sectionHeader: "A")
            let f11 = SubfilterModel(id:2, filterId: 1, title: "ABODIE", sectionHeader: "A")
            let f12 = SubfilterModel(id:3, filterId: 1, title: "Acasta", sectionHeader: "A")
            let f13 = SubfilterModel(id:4, filterId: 1, title: "Adelante", sectionHeader: "A")
            let f14 = SubfilterModel(id:5, filterId: 1, title: "Adele", sectionHeader: "A")
            let f15 = SubfilterModel(id:6, filterId: 1, title: "Adelin Fostayn", sectionHeader: "A")
            let f16 = SubfilterModel(id:7, filterId: 1, title: "Adidas", sectionHeader: "A")
            let f17 = SubfilterModel(id:8, filterId: 1, title: "ADZHERO", sectionHeader: "A")
            let f18 = SubfilterModel(id:9, filterId: 1, title: "Aelite", sectionHeader: "A")
            let f19 = SubfilterModel(id:10, filterId: 1, title: "AFFARI", sectionHeader: "A")
            let f20 = SubfilterModel(id:11, filterId: 1, title: "B&Co", sectionHeader: "B")
            let f21 = SubfilterModel(id:12, filterId: 1, title: "B&H", sectionHeader: "B")
            let f22 = SubfilterModel(id:13, filterId: 1, title: "Babylon", sectionHeader: "B")
            let f23 = SubfilterModel(id:14, filterId: 1, title: "Balasko", sectionHeader: "B")
            let f24 = SubfilterModel(id:15, filterId: 1, title: "Baon", sectionHeader: "B")
            let f25 = SubfilterModel(id:16, filterId: 1, title: "Barboleta", sectionHeader: "B")
            let f26 = SubfilterModel(id:17, filterId: 1, title: "Barcelonica", sectionHeader: "B")
            let f27 = SubfilterModel(id:18, filterId: 1, title: "Barkhat", sectionHeader: "B")
            let f28 = SubfilterModel(id:19, filterId: 1, title: "Basia", sectionHeader: "B")
            let f29 = SubfilterModel(id:20, filterId: 1, title: "C.H.I.C", sectionHeader: "C")
            let f30 = SubfilterModel(id:21, filterId: 1, title: "Calista", sectionHeader: "C")
            let f31 = SubfilterModel(id:22, filterId: 1, title: "Calvin Klein", sectionHeader: "C")
            
            let f32 = SubfilterModel(id:23, filterId: 1, title: "Camelia", sectionHeader: "C")
            let f33 = SubfilterModel(id:24, filterId: 1, title: "Camelot", sectionHeader: "C")
            let f34 = SubfilterModel(id:25, filterId: 1, title: "Can Nong", sectionHeader: "C")
            let f35 = SubfilterModel(id:26, filterId: 1, title: "Caprice", sectionHeader: "C")
            let f36 = SubfilterModel(id:27, filterId: 1, title: "Camart", sectionHeader: "C")
            
            tmp.append(contentsOf: [f10,f11,f12,f13,f14,f15,f16,f17,f18,f19,f20,f21,f22, f23, f24, f25, f26, f27, f28, f29, f30 ,f31, f32, f33, f34, f35, f36])
            
            
            let sectionA = SectionOfSubFilterModel(header: "A", items: [f10, f11, f12, f13, f14, f15, f16, f17, f18, f19])
            let sectionB = SectionOfSubFilterModel(header: "B", items: [f20, f21, f22, f23, f24, f25, f26, f27, f28])
            let sectionC = SectionOfSubFilterModel(header: "C", items: [f29, f30 ,f31, f32, f33, f34, f35, f36])
        }
        //  sectionedSubFiltersByFilter[1] = [sectionA, sectionB, sectionC]
        
        
        
        
        // Size
        if filterId == 2  || filterId == 0{
            let size34 = SubfilterModel(id:28, filterId: 2, title: "34")
            let size36 = SubfilterModel(id:29, filterId: 2, title: "36")
            let size37 = SubfilterModel(id:30, filterId: 2, title: "37")
            let size38 = SubfilterModel(id:31, filterId: 2, title: "38")
            let size39 = SubfilterModel(id:32, filterId: 2, title: "39")
            let size40 = SubfilterModel(id:33, filterId: 2, title: "40")
            let size41 = SubfilterModel(id:34, filterId: 2, title: "41")
            let size42 = SubfilterModel(id:35, filterId: 2, title: "42")
            let size43 = SubfilterModel(id:37, filterId: 2, title: "43")
            let size44 = SubfilterModel(id:38, filterId: 2, title: "44")
            let size45 = SubfilterModel(id:39, filterId: 2, title: "45")
            let size46 = SubfilterModel(id:40, filterId: 2, title: "46")
            let size47 = SubfilterModel(id:41, filterId: 2, title: "47")
            let size48 = SubfilterModel(id:42, filterId: 2, title: "48")
            
            let tmpModels2 = [28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41]
            tmp.append(contentsOf: [size34, size36, size37, size38, size39, size40, size41, size42, size43, size44, size45, size46, size47, size48])
        }
        
        //  subfiltersByFilter[2] = tmpModels2
        
        
        
        
        // Season
        if filterId == 3  || filterId == 0{
            let демисезон = SubfilterModel(id:43, filterId: 3, title: "демисезон")
            let зима = SubfilterModel(id:44, filterId: 3, title: "зима")
            let круглогодичный = SubfilterModel(id:45, filterId: 3, title: "круглогодичный")
            let лето = SubfilterModel(id:46, filterId: 3, title: "лето")
            
            tmp.append(contentsOf: [демисезон, зима, круглогодичный, лето])
            let tmpModels3 = [43, 44, 45, 46]
        }
        //    subfiltersByFilter[3] = tmpModels3
        
        
        
        // Materials
        if filterId == 4  || filterId == 0{
            let ангора = SubfilterModel(id:47, filterId: 4, title: "ангора")
            let вискоза = SubfilterModel(id:48, filterId: 4, title: "вискоза")
            let полиамид = SubfilterModel(id:49, filterId: 4, title: "полиамид")
            let полиуретан = SubfilterModel(id:50, filterId: 4, title: "полиуретан")
            let полиэстер = SubfilterModel(id:51, filterId: 4, title: "полиэстер")
            let хлопок = SubfilterModel(id:52, filterId: 4, title: "хлопок")
            let шелк = SubfilterModel(id:53, filterId: 4, title: "шелк")
            let шерсть = SubfilterModel(id:54, filterId: 4, title: "шерсть")
            let эластан = SubfilterModel(id:55, filterId: 4, title: "эластан")
            
            
            tmp.append(contentsOf: [ангора, вискоза, полиамид, полиуретан, полиэстер, хлопок, шелк, шерсть, эластан])
            let tmpModels4 = [47, 48, 49, 50, 51, 52, 53, 54, 55]
            //  subfiltersByFilter[4] = tmpModels4
        }
        
        
        // Delivery
        if filterId == 5  || filterId == 0{
            let день1 = SubfilterModel(id:56, filterId: 5, title: "1 день")
            let дня3 = SubfilterModel(id:57, filterId: 5, title: "3 дня")
            let дня4 = SubfilterModel(id:58, filterId: 5, title: "4 дня")
            let дней5 = SubfilterModel(id:59, filterId: 5, title: "5 дней")
            
            tmp.append(contentsOf: [день1, дня3, дня4, дней5])
            let tmpModels5 = [56, 57, 58, 59]
            //    subfiltersByFilter[5] = tmpModels5
        }
        
        
        
        // Color
        if filterId == 6  || filterId == 0{
            let бежевый = SubfilterModel(id:60, filterId: 6, title: "бежевый")
            let белый = SubfilterModel(id:61, filterId: 6, title: "белый")
            let голубой = SubfilterModel(id:62, filterId: 6, title: "голубой")
            let желтый = SubfilterModel(id:63, filterId: 6, title: "желтый")
            let зеленый = SubfilterModel(id:64, filterId: 6, title: "зеленый")
            let коричневый = SubfilterModel(id:65, filterId: 6, title: "коричневый")
            let красный = SubfilterModel(id:66, filterId: 6, title: "красный")
            let оранжевый = SubfilterModel(id:67, filterId: 6, title: "оранжевый")
            let розовый = SubfilterModel(id:68, filterId: 6, title: "розовый")
            let серый = SubfilterModel(id:69, filterId: 6, title: "серый")
            let синий = SubfilterModel(id:70, filterId: 6, title: "синий")
            let фиолетовый = SubfilterModel(id:71, filterId: 6, title: "фиолетовый")
            let черный = SubfilterModel(id:72, filterId: 6, title: "черный")
            
            tmp.append(contentsOf: [бежевый, белый, голубой, желтый, зеленый, коричневый, красный, оранжевый, розовый, серый, синий, фиолетовый, черный ])
            let tmpModels6 = [60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72]
            //  subfiltersByFilter[6] = tmpModels6
        }
        
        
        //        subfByItem(item: 3, subfilters: [f11.id, size38.id, size39.id, size40.id, круглогодичный.id, полиамид.id, дня4.id,  желтый.id])
        //        subfByItem(item: 7, subfilters: [f13.id, size42.id, size42.id, size44.id, круглогодичный.id, шелк.id, дня4.id,  оранжевый.id])
        //        subfByItem(item: 11, subfilters: [f14.id, size46.id, size47.id, size48.id, круглогодичный.id, вискоза.id, дня4.id,  фиолетовый.id]) //f50.id?
        //        subfByItem(item: 17, subfilters: [f17.id, size34.id, size36.id, size42.id, круглогодичный.id, шерсть.id, день1.id,  коричневый.id])
        //        subfByItem(item: 21, subfilters: [f20.id, size34.id, size36.id, size46.id, демисезон.id, полиамид.id, день1.id,  серый.id])
        //        subfByItem(item: 25, subfilters: [f23.id, size34.id, зима.id, ангора.id, день1.id,  белый.id])
        //        subfByItem(item: 29, subfilters: [f25.id, size34.id, зима.id, ангора.id, день1.id,  красный.id])
        //        subfByItem(item: 33, subfilters: [f28.id, size34.id, зима.id, ангора.id, день1.id,  белый.id])
        //        subfByItem(item: 37, subfilters: [f30.id, size34.id, зима.id, ангора.id, день1.id,  белый.id])
        //
        //
        //
        //
        //        subfByItem(item: 1, subfilters: [f10.id, size34.id, зима.id, ангора.id, день1.id,  белый.id])
        //        subfByItem(item: 2, subfilters: [f11.id, size36.id, size37.id, демисезон.id, вискоза.id, дня3.id, желтый.id])
        //
        //        subfByItem(item: 4, subfilters: [f12.id, size39.id, size40.id, size41.id, лето.id, полиуретан.id, дней5.id,  зеленый.id])
        //        subfByItem(item: 5, subfilters: [f12.id, size40.id, size41.id, size42.id, демисезон.id, полиэстер.id, день1.id,  коричневый.id])
        //        subfByItem(item: 6, subfilters: [f12.id, size36.id, size37.id, зима.id, хлопок.id, дня3.id, черный.id])
        //
        //
        //
        //        subfByItem(item: 8, subfilters: [f14.id, size42.id, size44.id, size45.id, лето.id, шерсть.id, дней5.id, розовый.id])
        //        subfByItem(item: 9, subfilters: [f14.id, size44.id, size45.id, size46.id, демисезон.id, эластан.id, день1.id, серый.id])
        //        subfByItem(item: 10, subfilters: [f14.id, size36.id, size37.id, зима.id, ангора.id, дня3.id,  черный.id])
        //
        //
        //        subfByItem(item: 12, subfilters: [f15.id, size36.id, size37.id, лето.id, полиамид.id, дней5.id,  черный.id])
        //        subfByItem(item: 13, subfilters: [f15.id, size34.id, зима.id, полиуретан.id, день1.id,  белый.id])
        //
        //
        //        subfByItem(item: 14, subfilters: [f16.id,size36.id, size37.id, демисезон.id, полиэстер.id, дня3.id, черный.id])
        //
        //        subfByItem(item: 15, subfilters: [f17.id, size36.id, size37.id, демисезон.id, хлопок.id, дня3.id,  красный.id])
        //        subfByItem(item: 16, subfilters: [f17.id, size34.id, size36.id, size41.id, зима.id, шелк.id, дней5.id, зеленый.id])
        //
        //
        //        subfByItem(item: 18, subfilters: [f18.id, size36.id, size37.id, лето.id, эластан.id, дня3.id,  черный.id])
        //        subfByItem(item: 19, subfilters: [f18.id, size34.id, size36.id, size44.id, демисезон.id, ангора.id, дня4.id,  оранжевый.id])
        //
        //        subfByItem(item: 20, subfilters: [f19.id, size34.id, size36.id, size45.id, зима.id, вискоза.id, дней5.id, розовый.id])
        //
        //
        //
        //        subfByItem(item: 22, subfilters: [f21.id, size36.id, size37.id, лето.id, полиуретан.id, дня3.id,  черный.id])
        //
        //        subfByItem(item: 23, subfilters: [f22.id, size34.id, size36.id, size48.id, демисезон.id, шерсть.id, дня4.id,  фиолетовый.id])
        //        subfByItem(item: 24, subfilters: [f22.id,size36.id, size37.id, зима.id, хлопок.id, дня3.id, синий.id])
        //
        //
        //        subfByItem(item: 26, subfilters: [f23.id, size34.id,  лето.id, эластан.id, дня3.id, белый.id])
        //
        //        subfByItem(item: 27, subfilters: [f24.id, size34.id, зима.id, эластан.id, дня4.id,  белый.id])
        //        subfByItem(item: 28, subfilters: [f24.id, size34.id,  зима.id, ангора.id, дней5.id, белый.id])
        //
        //        subfByItem(item: 30, subfilters: [f26.id, size45.id,  лето.id, хлопок.id, дней5.id,  бежевый.id])
        //        subfByItem(item: 31, subfilters: [f27.id, size34.id,  лето.id, полиуретан.id, дня4.id, белый.id])
        //        subfByItem(item: 32, subfilters: [f27.id, size34.id,  зима.id, полиуретан.id, дней5.id, белый.id])
        //
        //
        //        subfByItem(item: 34, subfilters: [f29.id, size34.id,  лето.id, хлопок.id, дня3.id, белый.id])
        //        subfByItem(item: 35, subfilters: [f29.id, size34.id,  лето.id, эластан.id, дня4.id,  белый.id])
        //
        //
        //
        //        subfByItem(item: 36, subfilters: [f30.id, size34.id,  зима.id, эластан.id, дней5.id, белый.id])
        
        return tmp
    }
    
    
    //    static func getEnabledSubFilters(ids: [Int]) -> [SubfilterModel?] {
    //        let res = ids
    //            .compactMap({subFilters[$0]})
    //            .filter({$0.enabled == true})
    //        return res
    //    }
    //
    //
    //    static func nerworkRequest(filterId: Int)->Observable<[SubfilterModel?]> {
    //        var res = [SubfilterModel?]()
    //        applyBeforeEnter(filterId: filterId)
    //        if let ids = subfiltersByFilter[filterId] {
    //            res = getEnabledSubFilters(ids: ids)
    //        }
    //        return Observable.just(res)
    //    }
    //
    //
    //    static func localSelectSubFilter(subFilterId: Int, selected: Bool) {
    //        if selected {
    //            selectedSubFilters.insert(subFilterId)
    //        } else {
    //            selectedSubFilters.remove(subFilterId)
    //        }
    //    }
    //
    //
    //    static func localSelectedSubFilter(subFilterId: Int) -> Bool {
    //        var res = false
    //        res = selectedSubFilters.contains(subFilterId)
    //        return res
    //    }
    //
    //
    //    static func nerworkRequestSection(filterId: Int)->Observable< [SectionOfSubFilterModel]? > {
    //        return Observable.just(sectionedSubFiltersByFilter[filterId])
    //    }
    //
    //
    ////    static func getSubFilters2(by subFilterIds: Set<Int>, filterId: Int) -> [SubfilterModel] {
    ////        return subFilterIds
    ////            .filter({subFilters[$0]?.filterId == filterId})
    ////            .compactMap({subFilters[$0]})
    ////    }
    //
    //
    //    static func groupApplying(applying: Set<Int>){
    //        applyingByFilter.removeAll()
    //        applying.forEach{id in
    //            if let subFilter = subFilters[id] {
    //                let filterId = subFilter.filterId
    //                if applyingByFilter[filterId] == nil {
    //                    applyingByFilter[filterId] = []
    //                }
    //                applyingByFilter[filterId]?.append(id)
    //            }
    //        }
    //    }
    //
    //
    //    private static func getItemIds(by subFilterIds: [Int]) -> [Int] {
    //        let r = subFilterIds.compactMap({itemsBySubfilter[$0]})
    //        return r.flatMap{$0}
    //    }
    //
    //
    //    static func getItems(exceptFilterId: Int = 0) -> Set<Int> {
    //        var res = Set<Int>()
    //        var tmp = Set<Int>()
    //
    //        for (filterId, applying) in applyingByFilter {
    //            if filterId != exceptFilterId || exceptFilterId == 0  {
    //                tmp = Set(getItemIds(by: applying))
    //            }
    //            res = (res.count == 0) ? tmp : res.intersection(tmp)
    //        }
    //        return res
    //    }
    //
    //
    //    static func getSubFilters(by items: Set<Int>) -> [Int] {
    //        let sub = items.compactMap{subfiltersByItem[$0]}
    //        return sub.flatMap{$0}
    //    }
    //
    //
    //    static func getApplied(exceptFilterId: Int = 0) -> Set<Int>{
    //        if exceptFilterId == 0 {
    //            return appliedSubFilters
    //        }
    //        let res = appliedSubFilters.filter({subFilters[$0]?.filterId != exceptFilterId})
    //        return res
    //    }
    //
    //
    //    static func removeApplied(filterId: Int = 0) {
    //        var removing = Set<Int>()
    //        if filterId == 0 {
    //            removing = appliedSubFilters
    //        } else {
    //            removing = appliedSubFilters.filter({subFilters[$0]?.filterId == filterId})
    //        }
    //        appliedSubFilters.subtract(removing)
    //        selectedSubFilters.subtract(removing)
    //    }
    //
    //
    //    static func applyAfterRemove(){
    //
    //        let applying = getApplied()
    //
    //        if applying.count == 0 {
    //            resetFilters()
    //            return
    //        }
    //
    //        groupApplying(applying: applying)
    //        let items = getItems()
    //
    //        if items.count == 0 {
    //            resetFilters()
    //            return
    //        }
    //
    //        var filterId = 0
    //        if applyingByFilter.count == 1 {
    //            filterId = applyingByFilter.first?.key ?? 0
    //        }
    //        let rem = getSubFilters(by: items)
    //
    //        FilterModel.enableAllFilters(enable: false)
    //
    //        enableAllSubFilters2(except: filterId, enable: false)
    //
    //        rem.forEach{ id in
    //            if let subFilter = subFilters[id] {
    //                subFilter.enabled = true
    //                FilterModel.enableFilters(filterId: subFilter.filterId)
    //            }
    //        }
    //        selectedSubFilters = Set(applying)
    //        appliedSubFilters = Set(applying)
    //    }
    //
    //
    //    static func applySubFilters(filterId: Int){
    //
    //        var inFilter: Set<Int> = Set()
    //
    //        if let ids = subfiltersByFilter[filterId] {
    //            inFilter = Set(ids)
    //        }
    //
    //        let selected = selectedSubFilters.intersection(inFilter)
    //
    //        let applied = getApplied(exceptFilterId: filterId)
    //        let applying = selected.union(applied)
    //
    //        if applying.count == 0 {
    //            resetFilters(exceptFilterId: filterId)
    //            return
    //        }
    //
    //        groupApplying(applying: applying)
    //
    //
    //        // network >>>
    //        let items = getItems()
    //
    //        if items.count == 0 {
    //            FilterModel.enableAllFilters(exceptFilterId: filterId, enable: false)
    //            enableAllSubFilters(except: filterId, enable: true)
    //            selectedSubFilters = Set(applying)
    //            appliedSubFilters = Set(applying)
    //            return
    //        }
    //
    //        let rem = getSubFilters(by: items)
    //
    //        FilterModel.enableAllFilters(enable: false)
    //
    //        enableAllSubFilters(except: filterId, enable: false)
    //
    //        rem.forEach{ id in
    //            if let subFilter = subFilters[id] {
    //                subFilter.enabled = true
    //                FilterModel.enableFilters(filterId: subFilter.filterId)
    //            }
    //        }
    //        selectedSubFilters = Set(applying)
    //        appliedSubFilters = Set(applying)
    //    }
    //
    //
    //    static func applyBeforeEnter(filterId: Int){
    //
    //        let applied = getApplied(exceptFilterId: filterId)
    //        let applying = applied
    //
    //        if applying.count == 0 {
    //            return
    //        }
    //
    //        groupApplying(applying: applying)
    //
    //        let items = getItems()
    //
    //        if items.count == 0 {
    //            resetFilters(exceptFilterId: filterId)
    //            return
    //        }
    //
    //        let rem = getSubFilters(by: items)
    //
    //        disableSubFilters(filterId: filterId)
    //        rem.forEach{ id in
    //            if let subFilter = subFilters[id] {
    //                subFilter.enabled = true
    //            }
    //        }
    //    }
    //
    //    private static func resetFilters(exceptFilterId: Int = 0){
    //        selectedSubFilters = []
    //        appliedSubFilters = []
    //        FilterModel.enableAllFilters(enable: true)
    //        enableAllSubFilters(except: exceptFilterId, enable: true)
    //    }
    //
    //    static func getOtherApplied(except subFilters: Set<Int>)-> Set<Int>{
    //        return appliedSubFilters.subtracting(subFilters)
    //    }
    //
    //
    //    static func enableAllSubFilters(except filterId: Int = 0, enable: Bool){
    //        for (_, val) in subFilters {
    //            if val.filterId != filterId || filterId == 0 {
    //                val.enabled = enable
    //            }
    //        }
    //    }
    //
    //    static func disableSubFilters(filterId: Int){
    //        for (_, val) in subFilters {
    //            if val.filterId == filterId {
    //                val.enabled = false
    //            }
    //        }
    //    }
    //
    //    static func enableAllSubFilters2(except filterId: Int = 0, enable: Bool){
    //        for (_, val) in subFilters {
    //            if val.filterId != filterId || filterId == 0 {
    //                val.enabled = enable
    //            }
    //        }
    //
    //        if filterId == 0 {
    //            return
    //        }
    //
    //        for (_, val) in subFilters {
    //            if val.filterId == filterId{
    //                val.enabled = !enable
    //            }
    //        }
    //    }
    //
    //
    //    static func getTitle(filterId: Int)->Observable<String> {
    //        guard
    //            let filter = filters[filterId]
    //            else { return .empty()}
    //
    //        return Observable.just(filter.title)
    //    }
    //
    //    static func getFilterEnum(filterId: Int)->Observable<FilterEnum> {
    //        guard
    //            let filter = filters[filterId]
    //            else { return .empty()}
    //
    //        return Observable.just(filter.filterEnum)
    //    }
    
}




struct SectionOfSubFilterModel {
    var header: String
    var items: [SubfilterModel]
}


extension SectionOfSubFilterModel: SectionModelType {
    typealias Item = SubfilterModel
    
    init(original: SectionOfSubFilterModel, items: [Item]) {
        self = original
        self.items = items
    }
}

