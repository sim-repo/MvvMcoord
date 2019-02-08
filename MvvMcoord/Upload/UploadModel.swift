import Foundation
import Firebase
import FirebaseDatabase

var itemsBySubfilter: [Int: [Int]] = [:]
var subfiltersByFilter: [Int:[Int]] = [:]
class FilterModel1 {
    
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
        firebaseStore()
    }
    
    func getDictionary()->[String: Any]  {
        return ["id": id, "title":title, "categoryId":categoryId, "enabled":enabled, "filterEnum":filterEnum.rawValue]
    }
    
    func firebaseStore(){
        let rootRef = Database.database().reference()
        let childRef = rootRef.child("filters")
        let itemsRef = childRef.child("filter\(id)")
        let dict = getDictionary()
        itemsRef.setValue(dict)
    }
    
}


class SubfilterModel1 {
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
        
        fillSubfiltersByFilter(filterId: filterId, subfilterId: id)
        
        firebaseStore()
    }
    
    func getDictionary()->[String: Any]  {
        return ["id": id, "filterId":filterId, "title":title, "enabled":enabled, "sectionHeader":sectionHeader]
    }
    
    func firebaseStore(){
        let rootRef = Database.database().reference()
        let childRef = rootRef.child("subfilters")
        let itemsRef = childRef.child("subfilter\(id)")
        let dict = getDictionary()
        itemsRef.setValue(dict)
    }
}


class Item {
    var id = 0
    var subfilters: [Int] = []
    
    
    init(id: Int, subfilters: [Int]) {
        self.id = id
        self.subfilters = subfilters
        fillItemsBySubfilter(item: id, subfilters: subfilters)
        firebaseStore()
    }
    
    func getDictionary()->[String: Any]  {
        return ["id": id, "subfilters": subfilters]
    }
    
    func firebaseStore(){
        let rootRef = Database.database().reference()
        let childRef = rootRef.child("subfiltersByItem")
        let itemsRef = childRef.child("item\(id)")
        let dict = getDictionary()
        itemsRef.setValue(dict)
    }
    
}






func firebaseStore(){
    let rootRef = Database.database().reference()
    let childRef = rootRef.child("itemsBySubfilter")
    for (key, val) in itemsBySubfilter {
        let itemsRef = childRef.child("subfilter\(key)")
        itemsRef.setValue(["id": key, "items": val])
    }
}

func fillItemsBySubfilter(item: Int, subfilters: [Int]){
    subfilters.forEach{ id in
        if itemsBySubfilter[id] == nil {
            itemsBySubfilter[id] = []
            itemsBySubfilter[id]?.append(item)
        } else {
            itemsBySubfilter[id]?.append(item)
        }
    }
}



func firebaseStore2(){
    let rootRef = Database.database().reference()
    let childRef = rootRef.child("subfiltersByFilter")
    for (key, val) in subfiltersByFilter {
        let itemsRef = childRef.child("filter\(key)")
        itemsRef.setValue(["id": key, "subfilters": val])
    }
}

func fillSubfiltersByFilter(filterId:Int, subfilterId: Int){
    if subfiltersByFilter[filterId] == nil {
        subfiltersByFilter[filterId] = []
    }
    subfiltersByFilter[filterId]?.append(subfilterId)
}



func runUpload(){
    let _ = FilterModel1(id:0, title: "Цена", categoryId: 01010101, filterEnum: .range)
    let _ = FilterModel1(id:1, title: "Бренд", categoryId: 01010101, filterEnum: .section)
    let _ = FilterModel1(id:2, title: "Размер", categoryId: 01010101)
    let _ = FilterModel1(id:3, title: "Сезон", categoryId: 01010101)
    let _ = FilterModel1(id:4, title: "Состав", categoryId: 01010101)
    let _ = FilterModel1(id:5, title: "Срок доставки", categoryId: 01010101)
    let _ = FilterModel1(id:6, title: "Цвет", categoryId: 01010101)
    let _ = FilterModel1(id:7, title: "Вид застежки", categoryId: 01010101)
    let _ = FilterModel1(id:8, title: "Вырез горловины", categoryId: 01010101)
    let _ = FilterModel1(id:9, title: "Декоративные элементы", categoryId: 01010101)
    let _ = FilterModel1(id:10, title: "Длина юбки/платья", categoryId: 01010101)
    let _ = FilterModel1(id:11, title: "Конструктивные элементы", categoryId: 01010101)
    let _ = FilterModel1(id:12, title: "Тип рукава", categoryId: 01010101)
    let _ = FilterModel1(id:13, title: "Цена2", categoryId: 01010101, filterEnum: .range)
    
    
    
    let f10 = SubfilterModel1(id:1, filterId: 1, title: "Abby", sectionHeader: "A")
    let f11 = SubfilterModel1(id:2, filterId: 1, title: "ABODIE", sectionHeader: "A")
    let f12 = SubfilterModel1(id:3, filterId: 1, title: "Acasta", sectionHeader: "A")
    let f13 = SubfilterModel1(id:4, filterId: 1, title: "Adelante", sectionHeader: "A")
    let f14 = SubfilterModel1(id:5, filterId: 1, title: "Adele", sectionHeader: "A")
    let f15 = SubfilterModel1(id:6, filterId: 1, title: "Adelin Fostayn", sectionHeader: "A")
    let f16 = SubfilterModel1(id:7, filterId: 1, title: "Adidas", sectionHeader: "A")
    let f17 = SubfilterModel1(id:8, filterId: 1, title: "ADZHERO", sectionHeader: "A")
    let f18 = SubfilterModel1(id:9, filterId: 1, title: "Aelite", sectionHeader: "A")
    let f19 = SubfilterModel1(id:10, filterId: 1, title: "AFFARI", sectionHeader: "A")
    let f20 = SubfilterModel1(id:11, filterId: 1, title: "B&Co", sectionHeader: "B")
    let f21 = SubfilterModel1(id:12, filterId: 1, title: "B&H", sectionHeader: "B")
    let f22 = SubfilterModel1(id:13, filterId: 1, title: "Babylon", sectionHeader: "B")
    let f23 = SubfilterModel1(id:14, filterId: 1, title: "Balasko", sectionHeader: "B")
    let f24 = SubfilterModel1(id:15, filterId: 1, title: "Baon", sectionHeader: "B")
    let f25 = SubfilterModel1(id:16, filterId: 1, title: "Barboleta", sectionHeader: "B")
    let f26 = SubfilterModel1(id:17, filterId: 1, title: "Barcelonica", sectionHeader: "B")
    let f27 = SubfilterModel1(id:18, filterId: 1, title: "Barkhat", sectionHeader: "B")
    let f28 = SubfilterModel1(id:19, filterId: 1, title: "Basia", sectionHeader: "B")
    let f29 = SubfilterModel1(id:20, filterId: 1, title: "C.H.I.C", sectionHeader: "C")
    let f30 = SubfilterModel1(id:21, filterId: 1, title: "Calista", sectionHeader: "C")
    let f31 = SubfilterModel1(id:22, filterId: 1, title: "Calvin Klein", sectionHeader: "C")
    let f32 = SubfilterModel1(id:23, filterId: 1, title: "Camelia", sectionHeader: "C")
    let f33 = SubfilterModel1(id:24, filterId: 1, title: "Camelot", sectionHeader: "C")
    let f34 = SubfilterModel1(id:25, filterId: 1, title: "Can Nong", sectionHeader: "C")
    let f35 = SubfilterModel1(id:26, filterId: 1, title: "Caprice", sectionHeader: "C")
    let f36 = SubfilterModel1(id:27, filterId: 1, title: "Camart", sectionHeader: "C")
    
    let size34 = SubfilterModel1(id:28, filterId: 2, title: "34")
    let size36 = SubfilterModel1(id:29, filterId: 2, title: "36")
    let size37 = SubfilterModel1(id:30, filterId: 2, title: "37")
    let size38 = SubfilterModel1(id:31, filterId: 2, title: "38")
    let size39 = SubfilterModel1(id:32, filterId: 2, title: "39")
    let size40 = SubfilterModel1(id:33, filterId: 2, title: "40")
    let size41 = SubfilterModel1(id:34, filterId: 2, title: "41")
    let size42 = SubfilterModel1(id:35, filterId: 2, title: "42")
    let size43 = SubfilterModel1(id:37, filterId: 2, title: "43")
    let size44 = SubfilterModel1(id:38, filterId: 2, title: "44")
    let size45 = SubfilterModel1(id:39, filterId: 2, title: "45")
    let size46 = SubfilterModel1(id:40, filterId: 2, title: "46")
    let size47 = SubfilterModel1(id:41, filterId: 2, title: "47")
    let size48 = SubfilterModel1(id:42, filterId: 2, title: "48")
    
    let демисезон = SubfilterModel1(id:43, filterId: 3, title: "демисезон")
    let зима = SubfilterModel1(id:44, filterId: 3, title: "зима")
    let круглогодичный = SubfilterModel1(id:45, filterId: 3, title: "круглогодичный")
    let лето = SubfilterModel1(id:46, filterId: 3, title: "лето")
    
    let ангора = SubfilterModel1(id:47, filterId: 4, title: "ангора")
    let вискоза = SubfilterModel1(id:48, filterId: 4, title: "вискоза")
    let полиамид = SubfilterModel1(id:49, filterId: 4, title: "полиамид")
    let полиуретан = SubfilterModel1(id:50, filterId: 4, title: "полиуретан")
    let полиэстер = SubfilterModel1(id:51, filterId: 4, title: "полиэстер")
    let хлопок = SubfilterModel1(id:52, filterId: 4, title: "хлопок")
    let шелк = SubfilterModel1(id:53, filterId: 4, title: "шелк")
    let шерсть = SubfilterModel1(id:54, filterId: 4, title: "шерсть")
    let эластан = SubfilterModel1(id:55, filterId: 4, title: "эластан")
    
    let день1 = SubfilterModel1(id:56, filterId: 5, title: "1 день")
    let дня3 = SubfilterModel1(id:57, filterId: 5, title: "3 дня")
    let дня4 = SubfilterModel1(id:58, filterId: 5, title: "4 дня")
    let дней5 = SubfilterModel1(id:59, filterId: 5, title: "5 дней")
    
    let бежевый = SubfilterModel1(id:60, filterId: 6, title: "бежевый")
    let белый = SubfilterModel1(id:61, filterId: 6, title: "белый")
    let голубой = SubfilterModel1(id:62, filterId: 6, title: "голубой")
    let желтый = SubfilterModel1(id:63, filterId: 6, title: "желтый")
    let зеленый = SubfilterModel1(id:64, filterId: 6, title: "зеленый")
    let коричневый = SubfilterModel1(id:65, filterId: 6, title: "коричневый")
    let красный = SubfilterModel1(id:66, filterId: 6, title: "красный")
    let оранжевый = SubfilterModel1(id:67, filterId: 6, title: "оранжевый")
    let розовый = SubfilterModel1(id:68, filterId: 6, title: "розовый")
    let серый = SubfilterModel1(id:69, filterId: 6, title: "серый")
    let синий = SubfilterModel1(id:70, filterId: 6, title: "синий")
    let фиолетовый = SubfilterModel1(id:71, filterId: 6, title: "фиолетовый")
    let черный = SubfilterModel1(id:72, filterId: 6, title: "черный")
    
    
    
    
    subfByItem(item: 3,  subfilters: [f11.id, size38.id, круглогодичный.id, полиамид.id,    дня4.id,    желтый.id])
    subfByItem(item: 7,  subfilters: [f13.id, size42.id, круглогодичный.id, полиэстер.id,   дня4.id,    оранжевый.id])
    subfByItem(item: 11, subfilters: [f14.id, size46.id, круглогодичный.id, полиуретан.id,  дня4.id,    фиолетовый.id])
    subfByItem(item: 17, subfilters: [f17.id, size34.id, круглогодичный.id, эластан.id,     день1.id,   коричневый.id])
    subfByItem(item: 21, subfilters: [f20.id, size34.id, демисезон.id,      вискоза.id,     день1.id,   желтый.id])
    subfByItem(item: 2,  subfilters: [f11.id, size36.id, демисезон.id,      вискоза.id,     дня3.id,    желтый.id])
    subfByItem(item: 5,  subfilters: [f12.id, size40.id, демисезон.id,      вискоза.id,     день1.id,   коричневый.id])
    subfByItem(item: 9,  subfilters: [f14.id, size44.id, демисезон.id,      вискоза.id,     день1.id,   коричневый.id])
    subfByItem(item: 14, subfilters: [f16.id, size36.id, демисезон.id,      шерсть.id,      дня3.id,    черный.id])
    subfByItem(item: 15, subfilters: [f17.id, size36.id, демисезон.id,      шерсть.id,      дня3.id,    красный.id])
    subfByItem(item: 23, subfilters: [f22.id, size34.id, демисезон.id,      шерсть.id,      дня4.id,    фиолетовый.id])
    subfByItem(item: 19, subfilters: [f18.id, size34.id, демисезон.id,      шерсть.id,      дня4.id,    оранжевый.id])
    subfByItem(item: 25, subfilters: [f23.id, size34.id, зима.id,           ангора.id,      день1.id,   синий.id])
    subfByItem(item: 29, subfilters: [f25.id, size34.id, зима.id,           ангора.id,      день1.id,   синий.id])
    subfByItem(item: 33, subfilters: [f28.id, size34.id, зима.id,           ангора.id,      день1.id,   синий.id])
    subfByItem(item: 37, subfilters: [f30.id, size34.id, зима.id,           ангора.id,      день1.id,   синий.id])
    subfByItem(item: 1,  subfilters: [f10.id, size34.id, зима.id,           ангора.id,      день1.id,   синий.id])
    subfByItem(item: 10, subfilters: [f14.id, size36.id, зима.id,           ангора.id,      дня4.id,    синий.id])
    subfByItem(item: 28, subfilters: [f24.id, size34.id, зима.id,           ангора.id,      дня4.id,    синий.id])
    subfByItem(item: 6,  subfilters: [f12.id, size36.id, зима.id,           шерсть.id,      дня4.id,    синий.id])
    subfByItem(item: 24, subfilters: [f22.id, size36.id, зима.id,           шерсть.id,      дня4.id,    синий.id])
    subfByItem(item: 13, subfilters: [f15.id, size34.id, зима.id,           шерсть.id,      дня4.id,    белый.id])
    subfByItem(item: 32, subfilters: [f27.id, size34.id, зима.id,           шерсть.id,      дня4.id,    белый.id])
    subfByItem(item: 16, subfilters: [f17.id, size34.id, зима.id,           шерсть.id,      дня4.id,    белый.id])
    subfByItem(item: 20, subfilters: [f19.id, size34.id, зима.id,           шерсть.id,      дня4.id,    белый.id])
    subfByItem(item: 27, subfilters: [f24.id, size34.id, зима.id,           эластан.id,     дня4.id,    белый.id])
    subfByItem(item: 36, subfilters: [f30.id, size34.id, зима.id,           эластан.id,     дня4.id,    белый.id])
    subfByItem(item: 4,  subfilters: [f12.id, size39.id, лето.id,           хлопок.id,      день1.id,   зеленый.id])
    subfByItem(item: 8,  subfilters: [f14.id, size42.id, лето.id,           хлопок.id,      день1.id,   розовый.id])
    subfByItem(item: 12, subfilters: [f15.id, size36.id, лето.id,           хлопок.id,      день1.id,   черный.id])
    subfByItem(item: 18, subfilters: [f18.id, size36.id, лето.id,           хлопок.id,      день1.id,   черный.id])
    subfByItem(item: 22, subfilters: [f21.id, size36.id, лето.id,           шелк.id,        день1.id,   черный.id])
    subfByItem(item: 26, subfilters: [f23.id, size34.id, лето.id,           шелк.id,        дня3.id,    белый.id])
    subfByItem(item: 30, subfilters: [f26.id, size45.id, лето.id,           шелк.id,        дня3.id,    бежевый.id])
    subfByItem(item: 31, subfilters: [f27.id, size34.id, лето.id,           эластан.id,     дня3.id,    белый.id])
    subfByItem(item: 34, subfilters: [f29.id, size34.id, лето.id,           эластан.id,     дня3.id,    белый.id])
    subfByItem(item: 35, subfilters: [f31.id, size34.id, лето.id,           эластан.id,     дня3.id,    белый.id])
    
    
    firebaseStore()
    
    firebaseStore2()
}


func subfByItem(item: Int, subfilters: [Int]){
    Item(id: item, subfilters: subfilters)
}
