import Foundation
import RxSwift
import RxDataSources


var filtersByCategory: [Int:[FilterModel]] = [:]
var subfiltersByFilter: [Int:[Int]] = [:]
var subfiltersByFilter2: [Int:[SectionOfSubFilterModel]] = [:] //sections
var filters: [Int:FilterModel] = [:]


// 2: catalogModel.id : subfilter.id
var subfiltersByModel: [Int: [Int]] = [:]
var modelsBySubfilter: [Int: [Int]] = [:]
var subFilters: [Int:SubfilterModel] = [:]


var appliedSubFilters: Set<Int> = Set()
var selectedSubFilters: Set<Int> = Set()
var applyingByFilter: [Int:[Int]] = [:]



enum FilterEnum {
    case select, range, section
}

class FilterModel {
    var id = 0
    var title: String
    var categoryId = 0
    var filterEnum: FilterEnum = .select
    var enabled = true
    
    init(id: Int, title: String, categoryId: Int, filterEnum: FilterEnum = .select){
        self.id = id
        self.title = title
        self.categoryId = categoryId
        self.filterEnum = filterEnum
    }
    
    static func fillModels(){
        let f00 = FilterModel(id:0, title: "Цена", categoryId: 01010101, filterEnum: .range)
        let f10 = FilterModel(id:1, title: "Бренд", categoryId: 01010101, filterEnum: .section)
        let f11 = FilterModel(id:2, title: "Размер", categoryId: 01010101)
        let f12 = FilterModel(id:3, title: "Сезон", categoryId: 01010101)
        let f13 = FilterModel(id:4, title: "Состав", categoryId: 01010101)
        let f14 = FilterModel(id:5, title: "Срок доставки", categoryId: 01010101)
        let f15 = FilterModel(id:6, title: "Цвет", categoryId: 01010101)
        let f16 = FilterModel(id:7, title: "Вид застежки", categoryId: 01010101)
        let f17 = FilterModel(id:8, title: "Вырез горловины", categoryId: 01010101)
        let f18 = FilterModel(id:9, title: "Декоративные элементы", categoryId: 01010101)
        let f19 = FilterModel(id:10, title: "Длина юбки/платья", categoryId: 01010101)
        let f20 = FilterModel(id:11, title: "Конструктивные элементы", categoryId: 01010101)
        let f21 = FilterModel(id:12, title: "Тип рукава", categoryId: 01010101)
        let f22 = FilterModel(id:13, title: "Цена2", categoryId: 01010101, filterEnum: .range)
        
        
        let tmpModels1 = [f00, f10, f11, f12, f13, f14, f15, f16, f17, f18, f19, f20, f21, f22 ]
        filtersByCategory[01010101] = tmpModels1
     
        filters[0] = f00
        filters[1] = f10
        filters[2] = f11
        
        filters[3] = f12
        filters[4] = f13
        filters[5] = f14
        
        filters[6] = f15
        filters[7] = f16
        filters[8] = f17
        
        filters[9] = f18
        filters[10] = f19
        filters[11] = f20
        filters[12] = f21
        filters[13] = f22

    }
    
    static func nerworkRequest(categoryId: Int)->Observable<[FilterModel]?> {
        return Observable.just(filtersByCategory[categoryId])
    }
    
    static func localRequest(categoryId: Int) -> Observable<[FilterModel?]> {
        var res = [FilterModel?]()
        
        let filters = filtersByCategory[categoryId]
        filters?.forEach{ filter in
            if filter.enabled {
                res.append(filter)
            }
        }
        return Observable.just(res)
    }
    
    
    static func localAppliedTitles(filterId: Int) -> String {
        var res = ""
        appliedSubFilters.forEach{ id in
            if let subf = subFilters[id],
                subf.filterId == filterId {
                res.append(subf.title + ",")
            }
        }
        if res.count > 0 {
            res.removeLast()
        }
        return res
    }
    
    static func enableFilters(filterId: Int){
        filters[filterId]?.enabled = true
    }
    
    static func enableAllFilters(enable: Bool){
        for (_, val) in filters {
            val.enabled = enable
        }
    }
    
    static func applyFilters(){
        let selected = selectedSubFilters
        let applied = SubfilterModel.getApplied()
        let applying = selected.union(applied)
        if applying.count > 0 {
            
            SubfilterModel.groupApplying(applying: applying)
            
            let items = SubfilterModel.getItems()
            
            let rem = SubfilterModel.getSubFilters(by: items)
            
            FilterModel.enableAllFilters(enable: false)
            SubfilterModel.enableAllSubFilters( enable: false)
            
            rem.forEach{ id in
                if let subFilter = subFilters[id] {
                    subFilter.enabled = true
                    FilterModel.enableFilters(filterId: subFilter.filterId)
                    SubfilterModel.enableSubFilters(subFilterId: id)
                }
            }
            selectedSubFilters = Set(applying)
            appliedSubFilters = Set(applying)
        }
    }
}



class SubfilterModel {
    var filterId = 0
    var id = 0
    var title: String
    var enabled = true
    
    init(id: Int, filterId: Int, title: String) {
        self.filterId = filterId
        self.id = id
        self.title = title
        
        
        
        subFilters[self.id] = self
    }
    

    static func subfByModel(item: Int, subfilters: [Int]){
        subfiltersByModel[item] = subfilters
        subfilters.forEach{ id in
            if modelsBySubfilter[id] == nil {
                modelsBySubfilter[id] = []
                modelsBySubfilter[id]?.append(item)
            } else {
                modelsBySubfilter[id]?.append(item)
            }
            
        }
    }
    
    static func fillModels(){
        
        // Brands
        let f10 = SubfilterModel(id:1, filterId: 1, title: "Abby")
        let f11 = SubfilterModel(id:2, filterId: 1, title: "ABODIE")
        let f12 = SubfilterModel(id:3, filterId: 1, title: "Acasta")
        let f13 = SubfilterModel(id:4, filterId: 1, title: "Adelante")
        let f14 = SubfilterModel(id:5, filterId: 1, title: "Adele")
        let f15 = SubfilterModel(id:6, filterId: 1, title: "Adelin Fostayn")
        let f16 = SubfilterModel(id:7, filterId: 1, title: "Adidas")
        let f17 = SubfilterModel(id:8, filterId: 1, title: "ADZHERO")
        let f18 = SubfilterModel(id:9, filterId: 1, title: "Aelite")
        let f19 = SubfilterModel(id:10, filterId: 1, title: "AFFARI")
        let f20 = SubfilterModel(id:11, filterId: 1, title: "B&Co")
        let f21 = SubfilterModel(id:12, filterId: 1, title: "B&H")
        let f22 = SubfilterModel(id:13, filterId: 1, title: "Babylon")
        let f23 = SubfilterModel(id:14, filterId: 1, title: "Balasko")
        let f24 = SubfilterModel(id:15, filterId: 1, title: "Baon")
        let f25 = SubfilterModel(id:16, filterId: 1, title: "Barboleta")
        let f26 = SubfilterModel(id:17, filterId: 1, title: "Barcelonica")
        let f27 = SubfilterModel(id:18, filterId: 1, title: "Barkhat")
        let f28 = SubfilterModel(id:19, filterId: 1, title: "Basia")
        let f29 = SubfilterModel(id:20, filterId: 1, title: "C.H.I.C")
        let f30 = SubfilterModel(id:21, filterId: 1, title: "Calista")
        let f31 = SubfilterModel(id:22, filterId: 1, title: "Calvin Klein")
        
        let f32 = SubfilterModel(id:23, filterId: 1, title: "Camelia")
        let f33 = SubfilterModel(id:24, filterId: 1, title: "Camelot")
        let f34 = SubfilterModel(id:25, filterId: 1, title: "Can Nong")
        let f35 = SubfilterModel(id:26, filterId: 1, title: "Caprice")
        let f36 = SubfilterModel(id:27, filterId: 1, title: "Camart")
        
        
        let sectionA = SectionOfSubFilterModel(header: "A", items: [f10, f11, f12, f13, f14, f15, f16, f17, f18, f19])
        let sectionB = SectionOfSubFilterModel(header: "B", items: [f20, f21, f22, f23, f24, f25, f26, f27, f28])
        let sectionC = SectionOfSubFilterModel(header: "C", items: [f29, f30 ,f31, f32, f33, f34, f35, f36])
        
        subfiltersByFilter2[1] = [sectionA, sectionB, sectionC]

       
        
        
        // Size
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
        subfiltersByFilter[2] = tmpModels2
        
      
        
        
        // Season
        let демисезон = SubfilterModel(id:43, filterId: 3, title: "демисезон")
        let зима = SubfilterModel(id:44, filterId: 3, title: "зима")
        let круглогодичный = SubfilterModel(id:45, filterId: 3, title: "круглогодичный")
        let лето = SubfilterModel(id:46, filterId: 3, title: "лето")
        
        
        let tmpModels3 = [43, 44, 45, 46]
        subfiltersByFilter[3] = tmpModels3

        
        
        // Materials
        let ангора = SubfilterModel(id:47, filterId: 4, title: "ангора")
        let вискоза = SubfilterModel(id:48, filterId: 4, title: "вискоза")
        let полиамид = SubfilterModel(id:49, filterId: 4, title: "полиамид")
        let полиуретан = SubfilterModel(id:50, filterId: 4, title: "полиуретан")
        let полиэстер = SubfilterModel(id:51, filterId: 4, title: "полиэстер")
        let хлопок = SubfilterModel(id:52, filterId: 4, title: "хлопок")
        let шелк = SubfilterModel(id:53, filterId: 4, title: "шелк")
        let шерсть = SubfilterModel(id:54, filterId: 4, title: "шерсть")
        let эластан = SubfilterModel(id:55, filterId: 4, title: "эластан")
        
        let tmpModels4 = [47, 48, 49, 50, 51, 52, 53, 54, 55]
        subfiltersByFilter[4] = tmpModels4
        
        
        
        // Delivery
        let день1 = SubfilterModel(id:56, filterId: 5, title: "1 день")
        let дня3 = SubfilterModel(id:57, filterId: 5, title: "3 дня")
        let дня4 = SubfilterModel(id:58, filterId: 5, title: "4 дня")
        let дней5 = SubfilterModel(id:59, filterId: 5, title: "5 дней")
        
        let tmpModels5 = [56, 57, 58, 59]
        subfiltersByFilter[5] = tmpModels5
        
        
        
        // Color
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
        
        let tmpModels6 = [60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72]
        subfiltersByFilter[6] = tmpModels6
        
        
        
        // Бренды - ABODIE, Adelante, Adele, ADZHERO, B&Co, Balasko, Barboleta, Basia, Calista
        // Размеры - 34, 36, 38, 39, 40, 42, 43, 44, 46, 47, 48
        // Сезон - круглогодичный
        // Состав- полиамид шелк вискоза шерсть хлопок ангора
        // Цвет - бежевый желтый оранжевый фиолетовый коричневый серый белый
        // Доставка 4 дня 1день
        
        // 3 7 11 17 21 25 29 33 37
        // 2 4 5 8 11 14
     

        
        
        subfByModel(item: 3, subfilters: [f11.id, size38.id, size39.id, size40.id, круглогодичный.id, полиамид.id, дня4.id,  желтый.id])
        subfByModel(item: 7, subfilters: [f13.id, size42.id, size42.id, size44.id, круглогодичный.id, шелк.id, дня4.id,  оранжевый.id])
        subfByModel(item: 11, subfilters: [f14.id, size46.id, size47.id, size48.id, круглогодичный.id, вискоза.id, дня4.id,  фиолетовый.id]) //f50.id?
        subfByModel(item: 17, subfilters: [f17.id, size34.id, size36.id, size42.id, круглогодичный.id, шерсть.id, день1.id,  коричневый.id])
        subfByModel(item: 21, subfilters: [f20.id, size34.id, size36.id, size46.id, круглогодичный.id, полиамид.id, день1.id,  серый.id])
        subfByModel(item: 25, subfilters: [f23.id, size34.id, зима.id, ангора.id, день1.id,  белый.id])
        subfByModel(item: 29, subfilters: [f25.id, size34.id, зима.id, ангора.id, день1.id,  белый.id])
        subfByModel(item: 33, subfilters: [f28.id, size34.id, зима.id, ангора.id, день1.id,  белый.id])
        subfByModel(item: 37, subfilters: [f30.id, size34.id, зима.id, ангора.id, день1.id,  белый.id])
        
        
        
        
        subfByModel(item: 1, subfilters: [f10.id, size34.id, зима.id, ангора.id, день1.id,  белый.id])
        subfByModel(item: 2, subfilters: [f11.id, size36.id, size37.id, демисезон.id, вискоза.id, дня3.id, черный.id])
        
        subfByModel(item: 4, subfilters: [f12.id, size39.id, size40.id, size41.id, лето.id, полиуретан.id, дней5.id,  зеленый.id])
        subfByModel(item: 5, subfilters: [f12.id, size40.id, size41.id, size42.id, демисезон.id, полиэстер.id, день1.id,  коричневый.id])
        subfByModel(item: 6, subfilters: [f12.id, size36.id, size37.id, зима.id, хлопок.id, дня3.id, черный.id])
        
        
        
        subfByModel(item: 8, subfilters: [f14.id, size42.id, size44.id, size45.id, лето.id, шерсть.id, дней5.id, розовый.id])
        subfByModel(item: 9, subfilters: [f14.id, size44.id, size45.id, size46.id, демисезон.id, эластан.id, день1.id, серый.id])
        subfByModel(item: 10, subfilters: [f14.id, size36.id, size37.id, зима.id, ангора.id, дня3.id,  черный.id])
        
        
        subfByModel(item: 12, subfilters: [f15.id, size36.id, size37.id, лето.id, полиамид.id, дней5.id,  черный.id])
        subfByModel(item: 13, subfilters: [f15.id, size34.id, зима.id, полиуретан.id, день1.id,  белый.id])
        
        
        subfByModel(item: 14, subfilters: [f16.id,size36.id, size37.id, демисезон.id, полиэстер.id, дня3.id, черный.id])
    
        subfByModel(item: 15, subfilters: [f17.id, size36.id, size37.id, демисезон.id, хлопок.id, дня3.id,  красный.id])
        subfByModel(item: 16, subfilters: [f17.id, size34.id, size36.id, size41.id, зима.id, шелк.id, дней5.id, зеленый.id])
        
        
        subfByModel(item: 18, subfilters: [f18.id, size36.id, size37.id, лето.id, эластан.id, дня3.id,  черный.id])
        subfByModel(item: 19, subfilters: [f18.id, size34.id, size36.id, size44.id, демисезон.id, ангора.id, дня4.id,  оранжевый.id])
        
        subfByModel(item: 20, subfilters: [f19.id, size34.id, size36.id, size45.id, зима.id, вискоза.id, дней5.id, розовый.id])
        
        
    
        subfByModel(item: 22, subfilters: [f21.id, size36.id, size37.id, лето.id, полиуретан.id, дня3.id,  черный.id])
    
        subfByModel(item: 23, subfilters: [f22.id, size34.id, size36.id, size48.id, демисезон.id, шерсть.id, дня4.id,  фиолетовый.id])
        subfByModel(item: 24, subfilters: [f22.id,size36.id, size37.id, зима.id, хлопок.id, дня3.id, синий.id])
        
        
        subfByModel(item: 26, subfilters: [f23.id, size34.id,  лето.id, эластан.id, дня3.id, белый.id])
        
        subfByModel(item: 27, subfilters: [f24.id, size34.id, зима.id, эластан.id, дня4.id,  белый.id])
        subfByModel(item: 28, subfilters: [f24.id, size34.id,  зима.id, ангора.id, дней5.id, белый.id])
        
        subfByModel(item: 30, subfilters: [f26.id, size45.id,  лето.id, хлопок.id, дней5.id,  бежевый.id])
        subfByModel(item: 31, subfilters: [f27.id, size34.id,  лето.id, полиуретан.id, дня4.id, белый.id])
        subfByModel(item: 32, subfilters: [f27.id, size34.id,  зима.id, полиуретан.id, дней5.id, белый.id])
        
        
        subfByModel(item: 34, subfilters: [f29.id, size34.id,  лето.id, хлопок.id, дня3.id, белый.id])
        subfByModel(item: 35, subfilters: [f29.id, size34.id,  лето.id, эластан.id, дня4.id,  белый.id])
        
        
        subfByModel(item: 36, subfilters: [f30.id, size34.id,  зима.id, эластан.id, дней5.id, белый.id])
        
        // белый ->  ангора, полиуретан, эластан, хлопок
        // голубой -> вискоза, полиэстер
        // фиолетовый -> шерсть, вискоза
        // белый -> зима, лето
        // голубой -> демисезон
        // фиолетовый -> круглогодичный, демисезон
        
        // хлопок -> дня3, дней5
        // дня3 -> бежевый, белый, черный
        // белый -> size34
        // черный -> size36, size37
        // бежевый -> size45
    }
    
    
    static func getEnabledSubFilters(ids: [Int]) -> [SubfilterModel?] {
        
        var res = [SubfilterModel?]()
        
        ids.forEach{ id in
            if let subf = subFilters[id],
               subf.enabled == true {
                res.append(subf)
            }
        }
        return res
    }
    
    
    static func nerworkRequest(filterId: Int)->Observable<[SubfilterModel?]> {
        // Fill subfiltersByFilter with merge approuch
        // cause subfiltersByFilter is in cache with selected filters
        
        var res = [SubfilterModel?]()
        if let ids = subfiltersByFilter[filterId] {
            res = getEnabledSubFilters(ids: ids)
        }
        return Observable.just(res)
    }
    
    
    static func localSelectSubFilter(subFilterId: Int, selected: Bool) {
        if selected {
            selectedSubFilters.insert(subFilterId)
        } else {
            selectedSubFilters.remove(subFilterId)
        }
    }
    
    
    static func localSelectedSubFilter(subFilterId: Int) -> Bool {
        var res = false
        res = selectedSubFilters.contains(subFilterId)
//        if res == false {
//            res = appliedSubFilters.contains(subFilterId)
//        }
        return res
    }
    
    
    static func nerworkRequestSection(filterId: Int)->Observable< [SectionOfSubFilterModel]? > {
        return Observable.just(subfiltersByFilter2[filterId])
    }
    
    
    static func getSubFilters2(by subFilterIds: Set<Int>, filterId: Int) -> [SubfilterModel] {
        var res = [SubfilterModel]()
        subFilterIds.forEach{ id in
            if let subF = subFilters[id] {
                if subF.filterId == filterId {
                    res.append(subF)
                }
            }
        }
        return res
    }
    
    
    static func groupApplying(applying: Set<Int>){
        applyingByFilter.removeAll()
        
        applying.forEach{id in
            if let subFilter = subFilters[id] {
            
                let filterId = subFilter.filterId
                if applyingByFilter[filterId] == nil {
                    applyingByFilter[filterId] = []
                }
                applyingByFilter[filterId]?.append(id)
            }
        }
    }
    
    
    private static func getModelIds(by subFilterIds: [Int]) -> [Int] {
        var res = [Int]()
        subFilterIds.forEach{ id in
            if let itemIds = modelsBySubfilter[id] {
                res = res + itemIds
            }
        }
        return res
    }
    
    
    static func getItems(exceptFilterId: Int = 0) -> Set<Int> {
        var res = Set<Int>()
        
        var tmp = Set<Int>()
        
        for (filterId, applying) in applyingByFilter {
            if filterId != exceptFilterId || exceptFilterId == 0 {
                tmp = Set(getModelIds(by: applying))
            }
            
            res = (res.count == 0) ? tmp : res.intersection(tmp)
        }
        return res
    }
    
    
    static func getSubFilters(by items: Set<Int>) -> [Int] {
        var res = [Int]()
        items.forEach{ id in
            if let subfilters = subfiltersByModel[id] {
                for sf in subfilters {
                    res.append(sf)
                }
            }
        }
        return res
    }
    
    static func getApplied(exceptFilterId: Int = 0) -> Set<Int>{
        var res = Set<Int>()
        appliedSubFilters.forEach{ id in
            if let subf = subFilters[id] {
                if subf.filterId != exceptFilterId || exceptFilterId == 0 {
                    res.insert(id)
                }
            }
        }
        return res
    }
        
    
    static func applySubFilters(filterId: Int){
        
        var inFilter: Set<Int> = Set()
        
        if let ids = subfiltersByFilter[filterId] {
            inFilter = Set(ids)
        }
        
        let selected = selectedSubFilters.intersection(inFilter)
        
        let applied = getApplied(exceptFilterId: filterId)
        let applying = selected.union(applied)
        
        if applying.count == 0 {
            resetFilters(exceptFilterId: filterId)
            return
        }
        

        groupApplying(applying: applying)
        
        let items = getItems()
        
        if items.count == 0 {
            resetFilters(exceptFilterId: filterId)
            return
        }
        
        let rem = getSubFilters(by: items)
        
        FilterModel.enableAllFilters(enable: false)
        enableAllSubFilters(except: filterId, enable: false)
        
        rem.forEach{ id in
            if let subFilter = subFilters[id] {
                subFilter.enabled = true
                FilterModel.enableFilters(filterId: subFilter.filterId)
                enableSubFilters(subFilterId: id)
            }
        }
        selectedSubFilters = Set(applying)
        appliedSubFilters = Set(applying)
    }
    
    private static func resetFilters(exceptFilterId: Int){
        selectedSubFilters = []
        appliedSubFilters = []
        FilterModel.enableAllFilters(enable: true)
        enableAllSubFilters(except: exceptFilterId, enable: true)
    }
    
    static func getOtherApplied(except subFilters: Set<Int>)-> Set<Int>{
        return appliedSubFilters.subtracting(subFilters)
    }
    
    
    static func enableSubFilters(subFilterId: Int){
        subFilters[subFilterId]?.enabled = true
    }
    
    static func enableAllSubFilters(except filterId: Int = 0, enable: Bool){
        for (_, val) in subFilters {
            if val.filterId != filterId || filterId == 0 {
                val.enabled = enable
            }
        }
    }
    
    
    
    static func getTitle(filterId: Int)->Observable<String> {
        guard
            let filter = filters[filterId]
            else { return .empty()}
        
        return Observable.just(filter.title)
    }
    
    static func getFilterEnum(filterId: Int)->Observable<FilterEnum> {
        guard
            let filter = filters[filterId]
            else { return .empty()}
        
        return Observable.just(filter.filterEnum)
    }
    
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
