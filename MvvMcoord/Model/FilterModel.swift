import Foundation
import RxSwift
import RxDataSources


var filtersByCategory: [Int:[FilterModel]] = [:]
var subfiltersByFilter: [Int:[SubfilterModel]] = [:]
var subfiltersByFilter2: [Int:[SectionOfSubFilterModel]] = [:] //sections
var filters: [Int:FilterModel] = [:]


// 2: catalogModel.id : subfilter.id
var subfiltersByModel: [Int: [Int]] = [:]
var modelsBySubfilter: [Int: [Int]] = [:]


enum FilterEnum {
    case select, range, section
}

class FilterModel {
    var id = 0
    var title: String
    var categoryId = 0
    var filterEnum: FilterEnum = .select
    
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
        
        
        let tmpModels1 = [f00, f10, f11, f12, f13, f14, f15, f16, f17, f18, f19, f20, f21 ]
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

    }
    
    static func nerworkRequest(categoryId: Int)->Observable<[FilterModel]?> {
        return Observable.just(filtersByCategory[categoryId])
    }
    
}



class SubfilterModel {
    var filterId = 0
    var id = 0
    var title: String
    
    init(id: Int, filterId: Int, title: String) {
        self.filterId = filterId
        self.id = id
        self.title = title
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
        let f37 = SubfilterModel(id:28, filterId: 2, title: "34")
        let f38 = SubfilterModel(id:29, filterId: 2, title: "36")
        let f39 = SubfilterModel(id:30, filterId: 2, title: "37")
        let f40 = SubfilterModel(id:31, filterId: 2, title: "38")
        let f41 = SubfilterModel(id:32, filterId: 2, title: "39")
        let f42 = SubfilterModel(id:33, filterId: 2, title: "40")
        let f43 = SubfilterModel(id:34, filterId: 2, title: "41")
        let f44 = SubfilterModel(id:34, filterId: 2, title: "42")
        let f45 = SubfilterModel(id:34, filterId: 2, title: "43")
        let f46 = SubfilterModel(id:34, filterId: 2, title: "44")
        let f47 = SubfilterModel(id:34, filterId: 2, title: "45")
        let f48 = SubfilterModel(id:34, filterId: 2, title: "46")
        let f49 = SubfilterModel(id:34, filterId: 2, title: "47")
        let f50 = SubfilterModel(id:34, filterId: 2, title: "48")
        
        let tmpModels2 = [f37, f38, f39, f40, f41, f42, f43, f44, f45, f46, f47, f48, f49, f50]
        subfiltersByFilter[2] = tmpModels2
        
        // Season
        let f51 = SubfilterModel(id:28, filterId: 3, title: "демисезон")
        let f52 = SubfilterModel(id:29, filterId: 3, title: "зима")
        let f53 = SubfilterModel(id:30, filterId: 3, title: "круглогодичный")
        let f54 = SubfilterModel(id:31, filterId: 3, title: "лето")
        
        
        let tmpModels3 = [f51, f52, f53, f54]
        subfiltersByFilter[3] = tmpModels3
        
        
        
        // Materials
        let f55 = SubfilterModel(id:32, filterId: 4, title: "ангора")
        let f56 = SubfilterModel(id:33, filterId: 4, title: "вискоза")
        let f57 = SubfilterModel(id:34, filterId: 4, title: "полиамид")
        let f58 = SubfilterModel(id:35, filterId: 4, title: "полиуретан")
        let f59 = SubfilterModel(id:36, filterId: 4, title: "полиэстер")
        let f60 = SubfilterModel(id:37, filterId: 4, title: "хлопок")
        let f61 = SubfilterModel(id:38, filterId: 4, title: "шелк")
        let f62 = SubfilterModel(id:39, filterId: 4, title: "шерсть")
        let f63 = SubfilterModel(id:40, filterId: 4, title: "эластан")
        
        let tmpModels4 = [f55, f56, f57, f58, f59, f60, f61, f62, f63]
        subfiltersByFilter[4] = tmpModels4
        
        
        
        // Delivery
        let f64 = SubfilterModel(id:41, filterId: 5, title: "1 день")
        let f65 = SubfilterModel(id:42, filterId: 5, title: "3 дня")
        let f66 = SubfilterModel(id:43, filterId: 5, title: "4 дня")
        let f67 = SubfilterModel(id:44, filterId: 5, title: "5 дней")
        
        let tmpModels5 = [f64, f65, f66, f67]
        subfiltersByFilter[5] = tmpModels5
        
        
        
        // Color
        let f68 = SubfilterModel(id:45, filterId: 6, title: "бежевый")
        let f69 = SubfilterModel(id:46, filterId: 6, title: "белый")
        let f70 = SubfilterModel(id:47, filterId: 6, title: "голубой")
        let f71 = SubfilterModel(id:48, filterId: 6, title: "желтый")
        let f72 = SubfilterModel(id:49, filterId: 6, title: "зеленый")
        let f73 = SubfilterModel(id:50, filterId: 6, title: "коричневый")
        let f74 = SubfilterModel(id:51, filterId: 6, title: "красный")
        let f75 = SubfilterModel(id:52, filterId: 6, title: "оранжевый")
        let f76 = SubfilterModel(id:53, filterId: 6, title: "розовый")
        let f77 = SubfilterModel(id:54, filterId: 6, title: "серый")
        let f78 = SubfilterModel(id:55, filterId: 6, title: "синий")
        let f79 = SubfilterModel(id:56, filterId: 6, title: "фиолетовый")
        let f80 = SubfilterModel(id:57, filterId: 6, title: "черный")
        
        let tmpModels6 = [f68, f69, f70, f71, f72, f73, f74, f75, f76, f77, f78, f79, f80]
        subfiltersByFilter[6] = tmpModels6
        
        
        
        subfiltersByModel[1] = [f10.id, f37.id, f38.id, f39.id, f40.id, f41.id, f42.id, f43.id, f44.id, f45.id, f46.id, f47.id, f48.id, f49.id, f50.id,  f51.id, f52.id, f53.id, f54.id,
        f55.id,f56.id,f57.id,f58.id,f59.id,f60.id,f61.id,f62.id, f63.id, f64.id,f65.id, f66.id, f67.id,
        f68.id, f69.id, f70.id,f71.id,f72.id,f73.id,f74.id,f75.id,f76.id,f77.id,f78.id,f79.id,f80.id]
        
        subfiltersByModel[2] = [f10.id, f37.id, f38.id, f39.id, f40.id, f41.id, f42.id, f43.id, f44.id, f45.id, f46.id, f47.id, f48.id, f49.id, f50.id,  f51.id, f52.id, f53.id, f54.id,
                                f55.id,f56.id,f57.id,f58.id,f59.id,f60.id,f61.id,f62.id, f63.id, f64.id,f65.id, f66.id, f67.id,
                                f68.id, f69.id, f70.id,f71.id,f72.id,f73.id,f74.id,f75.id,f76.id,f77.id,f78.id,f79.id,f80.id]
        
        modelsBySubfilter[f10.id] = [1,2]
        modelsBySubfilter[f37.id] = [1,2]
    }
    
    static func nerworkRequest(filterId: Int)->Observable<[SubfilterModel]?> {
        return Observable.just(subfiltersByFilter[filterId])
    }
    
    
    static func nerworkRequestSection(filterId: Int)->Observable< [SectionOfSubFilterModel]? > {
        return Observable.just(subfiltersByFilter2[filterId])
    }
    

    
    static func applyFilters(selected: [Int]){
        var next = 0
        var chain = Set<Int> ()
        
        SubfilterModel.getModelsBySubfilters(selected: selected, next: &next, chain: &chain)
        
        let subfilters = SubfilterModel.getSubfiltersByModels(chain: chain)
        
    }
    
    
    static func getModelsBySubfilters(selected: [Int], next: inout Int, chain: inout Set<Int>){
        var res = Set<Int>()
        if selected.count > next {
            return
        }
        let subfilterId = selected[next]
        let modelsIds = modelsBySubfilter[subfilterId]
        if let ids = modelsIds {
            res = Set(ids)
        }
        chain = chain.union(res)
        next += 1
        SubfilterModel.getModelsBySubfilters(selected: selected, next: &next, chain: &chain)
    }
    
    
    
    static func getSubfiltersByModels(chain: Set<Int>)->[Int]{
        var res: [Int] = []
        let arr = Array(chain)
        for i in arr {
            if let subfilterIds = subfiltersByModel[i] {
                for id in subfilterIds {
                     res.append(id)
                }
            }
        }
        return res
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
