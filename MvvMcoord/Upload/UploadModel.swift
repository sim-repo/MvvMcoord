import Foundation
import Firebase
import FirebaseDatabase

private var itemsBySubfilter: [Int: [Int]] = [:]
private var subfiltersByFilter: [Int:[Int]] = [:]
private var subFilters: [Int:SubfilterModel1] = [:]
private var subfiltersByItem: [Int:[Int]] = [:]

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
        filterFirebaseStore()
    }
    
    func getDictionary()->[String: Any]  {
        return ["id": id, "title":title, "categoryId":categoryId, "enabled":enabled, "filterEnum":filterEnum.rawValue]
    }
    
    func filterFirebaseStore(){
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
        
        addSubF(id: id, subFilter: self)
        fillSubfiltersByFilter(filterId: filterId, subfilterId: id)
        
        subfilterFirebaseStore()
    }
    
    func getDictionary()->[String: Any]  {
        return ["id": id, "filterId":filterId, "title":title, "enabled":enabled, "sectionHeader":sectionHeader]
    }
    
    func subfilterFirebaseStore(){
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
        itemFirebaseStore()
    }
    
    func getDictionary()->[String: Any]  {
        return ["id": id, "subfilters": subfilters]
    }
    
    func itemFirebaseStore(){
        let rootRef = Database.database().reference()
        let childRef = rootRef.child("subfiltersByItem")
        let itemsRef = childRef.child("item\(id)")
        let dict = getDictionary()
        itemsRef.setValue(dict)
    }
    
}


func addSubF(id: Int, subFilter: SubfilterModel1){
    subFilters[id] = subFilter
}

class CatalogModel1{
    let id: Int
    let categoryId: Int
    var name: String
    let thumbnail: String
    let stars: Int
    let newPrice: Int
    let oldPrice: Int
    let votes: Int
    let discount: Int
    
    
    init(id: Int, categoryId: Int, name: String, thumbnail: String, stars: Int, newPrice: Int, oldPrice: Int, votes: Int, discount: Int) {
        self.id = id
        self.categoryId = categoryId
        self.name = name
        self.thumbnail = thumbnail
        self.stars = stars
        self.newPrice = newPrice
        self.oldPrice = oldPrice
        self.votes = votes
        self.discount = discount
        
        let subfilters = subfiltersByItem[id]!
        var newName = "(\(id))"
        for id in subfilters {
            let model = subFilters[id]!
            newName += model.title+","
        }
        self.name = newName
        
        catalogFirebaseStore()
        catalogFirebaseStore2()
    }
    
    func getDictionary()->[String: Any]  {
        return ["id": id, "categoryId": categoryId, "name":name, "thumbnail":thumbnail, "stars":stars, "newPrice":newPrice, "oldPrice":oldPrice, "votes":votes, "discount":discount]
    }
    
    func catalogFirebaseStore(){
        let rootRef = Database.database().reference()
        let childRef = rootRef.child("catalog")
        let itemsRef = childRef.child("item\(id)")
        let dict = getDictionary()
        itemsRef.setValue(dict)
    }
    
    
    func catalogFirebaseStore2(){
        let rootRef = Database.database().reference()
        let childRef = rootRef.child("pricesByItem")
        let itemsRef = childRef.child("item\(id)")
        itemsRef.setValue(["id": id, "price": newPrice])
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

func firebaseStore3(categoryId: Int, minPrice: CGFloat, maxPrice: CGFloat){
    let rootRef = Database.database().reference()
    let childRef = rootRef.child("rangePriceByCategory")
    let itemsRef = childRef.child("category\(categoryId)")
    itemsRef.setValue(["id": categoryId, "minPrice": minPrice, "maxPrice": maxPrice])
}

func cleanupFirebase(){
    let rootRef = Database.database().reference()
    var ref = rootRef.child("catalog");
    ref.removeValue()
    
    ref = rootRef.child("filters");
    ref.removeValue()
    
    ref = rootRef.child("itemsBySubfilter");
    ref.removeValue()
    
    ref = rootRef.child("subfilters");
    ref.removeValue()
    
    ref = rootRef.child("subfiltersByFilter");
    ref.removeValue()
    
    ref = rootRef.child("subfiltersByItem");
    ref.removeValue()
    
    ref = rootRef.child("priceByItem");
    ref.removeValue()
    
    ref = rootRef.child("rangePriceByCategory");
    ref.removeValue()
}

func runUpload(){
    
    cleanupFirebase()
    
    
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
    let _ = SubfilterModel1(id:62, filterId: 6, title: "голубой")
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
    
    

   
    for i in stride(from: 0, to: 30135, by: 135) {
       // let i = 0
        subfByItem(item: i+1,  subfilters: [f10.id, size34.id, зима.id,           ангора.id,      день1.id,   синий.id])
        subfByItem(item: i+2,  subfilters: [f11.id, size36.id, демисезон.id,      вискоза.id,     дня3.id,    желтый.id])
        subfByItem(item: i+3,  subfilters: [f11.id, size38.id, круглогодичный.id, полиамид.id,    дня4.id,    желтый.id])
        subfByItem(item: i+4,  subfilters: [f12.id, size39.id, лето.id,           хлопок.id,      день1.id,   зеленый.id])
        subfByItem(item: i+5,  subfilters: [f12.id, size40.id, демисезон.id,      вискоза.id,     день1.id,   коричневый.id])
        subfByItem(item: i+6,  subfilters: [f12.id, size36.id, зима.id,           шерсть.id,      дня4.id,    синий.id])
        subfByItem(item: i+7,  subfilters: [f13.id, size42.id, круглогодичный.id, полиэстер.id,   дня4.id,    оранжевый.id])
        subfByItem(item: i+8,  subfilters: [f14.id, size42.id, лето.id,           хлопок.id,      день1.id,   розовый.id])
        subfByItem(item: i+9,  subfilters: [f14.id, size44.id, демисезон.id,      вискоза.id,     день1.id,   коричневый.id])
        subfByItem(item: i+10, subfilters: [f14.id, size36.id, зима.id,           ангора.id,      дня4.id,    синий.id])
        subfByItem(item: i+11, subfilters: [f14.id, size46.id, круглогодичный.id, полиуретан.id,  дня4.id,    фиолетовый.id])
        subfByItem(item: i+12, subfilters: [f36.id, size36.id, лето.id,           хлопок.id,      день1.id,   черный.id])
        subfByItem(item: i+13, subfilters: [f15.id, size34.id, зима.id,           шерсть.id,      дня4.id,    белый.id])
        subfByItem(item: i+14, subfilters: [f16.id, size36.id, демисезон.id,      шерсть.id,      дня3.id,    черный.id])
        subfByItem(item: i+15, subfilters: [f35.id, size36.id, демисезон.id,      шерсть.id,      дня3.id,    красный.id])
        subfByItem(item: i+16, subfilters: [f34.id, size34.id, зима.id,           шерсть.id,      дня4.id,    белый.id])
        subfByItem(item: i+17, subfilters: [f17.id, size34.id, круглогодичный.id, эластан.id,     день1.id,   коричневый.id])
        subfByItem(item: i+18, subfilters: [f18.id, size36.id, лето.id,           хлопок.id,      день1.id,   черный.id])
        subfByItem(item: i+19, subfilters: [f18.id, size34.id, демисезон.id,      шерсть.id,      дня4.id,    оранжевый.id])
        subfByItem(item: i+20, subfilters: [f19.id, size34.id, зима.id,           шерсть.id,      дня4.id,    белый.id])
        subfByItem(item: i+21, subfilters: [f20.id, size34.id, демисезон.id,      вискоза.id,     день1.id,   желтый.id])
        subfByItem(item: i+22, subfilters: [f21.id, size36.id, лето.id,           шелк.id,        дней5.id,   черный.id])
        subfByItem(item: i+23, subfilters: [f22.id, size34.id, демисезон.id,      шерсть.id,      дня4.id,    фиолетовый.id])
        subfByItem(item: i+24, subfilters: [f33.id, size36.id, зима.id,           шерсть.id,      дня4.id,    синий.id])
        subfByItem(item: i+25, subfilters: [f23.id, size37.id, зима.id,           ангора.id,      день1.id,   синий.id])
        subfByItem(item: i+26, subfilters: [f23.id, size34.id, лето.id,           шелк.id,        дня3.id,    белый.id])
        subfByItem(item: i+27, subfilters: [f24.id, size34.id, зима.id,           эластан.id,     дня4.id,    белый.id])
        subfByItem(item: i+28, subfilters: [f24.id, size34.id, зима.id,           ангора.id,      дня4.id,    синий.id])
        subfByItem(item: i+29, subfilters: [f25.id, size34.id, зима.id,           ангора.id,      день1.id,   синий.id])
        subfByItem(item: i+30, subfilters: [f26.id, size45.id, лето.id,           шелк.id,        дня3.id,    бежевый.id])
        subfByItem(item: i+31, subfilters: [f27.id, size34.id, лето.id,           эластан.id,     дня3.id,    белый.id])
        subfByItem(item: i+32, subfilters: [f27.id, size34.id, зима.id,           шерсть.id,      дня4.id,    белый.id])
        subfByItem(item: i+33, subfilters: [f28.id, size34.id, зима.id,           ангора.id,      день1.id,   синий.id])
        subfByItem(item: i+34, subfilters: [f29.id, size34.id, лето.id,           эластан.id,     дня3.id,    белый.id])
        subfByItem(item: i+35, subfilters: [f31.id, size34.id, лето.id,           эластан.id,     дня3.id,    белый.id])
        subfByItem(item: i+36, subfilters: [f32.id, size34.id, зима.id,           эластан.id,     дня4.id,    белый.id])
        subfByItem(item: i+37, subfilters: [f30.id, size41.id, зима.id,           ангора.id,      день1.id,   синий.id])
        subfByItem(item: i+38, subfilters: [f26.id, size45.id, лето.id,           шелк.id,        дня3.id,    бежевый.id])
        subfByItem(item: i+39, subfilters: [f26.id, size45.id, лето.id,           шелк.id,        дня3.id,    бежевый.id])
        subfByItem(item: i+40, subfilters: [f26.id, size45.id, лето.id,           шелк.id,        дня3.id,    бежевый.id])
        subfByItem(item: i+41, subfilters: [f26.id, size45.id, лето.id,           шелк.id,        дней5.id,   бежевый.id])
        subfByItem(item: i+42, subfilters: [f26.id, size45.id, лето.id,           шелк.id,        дня3.id,    бежевый.id])
        subfByItem(item: i+43, subfilters: [f26.id, size45.id, лето.id,           шелк.id,        дня3.id,    бежевый.id])
        subfByItem(item: i+44, subfilters: [f26.id, size45.id, лето.id,           шелк.id,        дня3.id,    бежевый.id])
        
        subfByItem(item: i+45, subfilters: [f11.id, size38.id, круглогодичный.id, полиамид.id,    дня4.id,    желтый.id])
        subfByItem(item: i+46, subfilters: [f11.id, size38.id, круглогодичный.id, полиамид.id,    дня4.id,    желтый.id])
        subfByItem(item: i+47, subfilters: [f11.id, size38.id, круглогодичный.id, полиамид.id,    дня4.id,    желтый.id])
        subfByItem(item: i+48, subfilters: [f11.id, size48.id, круглогодичный.id, полиамид.id,    дня4.id,    желтый.id])
        subfByItem(item: i+49, subfilters: [f11.id, size38.id, круглогодичный.id, полиамид.id,    дня4.id,    желтый.id])
        subfByItem(item: i+50, subfilters: [f11.id, size38.id, круглогодичный.id, полиамид.id,    дня4.id,    желтый.id])
        subfByItem(item: i+51, subfilters: [f11.id, size47.id, круглогодичный.id, полиамид.id,    дня4.id,    желтый.id])
        subfByItem(item: i+52, subfilters: [f11.id, size38.id, круглогодичный.id, полиамид.id,    дня4.id,    желтый.id])
        subfByItem(item: i+53, subfilters: [f11.id, size38.id, круглогодичный.id, полиамид.id,    дня4.id,    желтый.id])
        subfByItem(item: i+54, subfilters: [f11.id, size43.id, круглогодичный.id, полиамид.id,    дня4.id,    желтый.id])
        subfByItem(item: i+55, subfilters: [f11.id, size38.id, круглогодичный.id, полиамид.id,    дня4.id,    желтый.id])
        subfByItem(item: i+56, subfilters: [f11.id, size38.id, круглогодичный.id, полиамид.id,    дня4.id,    желтый.id])
        subfByItem(item: i+57, subfilters: [f11.id, size38.id, круглогодичный.id, полиамид.id,    дня4.id,    желтый.id])
        subfByItem(item: i+58, subfilters: [f11.id, size38.id, круглогодичный.id, полиамид.id,    дня4.id,    желтый.id])
        
        subfByItem(item: i+59,  subfilters: [f12.id, size39.id, лето.id,           хлопок.id,      день1.id,   зеленый.id])
        subfByItem(item: i+60,  subfilters: [f12.id, size39.id, лето.id,           хлопок.id,      день1.id,   зеленый.id])
        subfByItem(item: i+61,  subfilters: [f12.id, size39.id, лето.id,           хлопок.id,      день1.id,   зеленый.id])
        subfByItem(item: i+62,  subfilters: [f12.id, size39.id, лето.id,           хлопок.id,      день1.id,   зеленый.id])
        subfByItem(item: i+63,  subfilters: [f12.id, size39.id, лето.id,           хлопок.id,      день1.id,   зеленый.id])
        subfByItem(item: i+64,  subfilters: [f12.id, size39.id, лето.id,           хлопок.id,      день1.id,   зеленый.id])
        subfByItem(item: i+65,  subfilters: [f12.id, size39.id, лето.id,           хлопок.id,      день1.id,   зеленый.id])
        subfByItem(item: i+66,  subfilters: [f12.id, size39.id, лето.id,           хлопок.id,      день1.id,   зеленый.id])
        
        
        subfByItem(item: i+67,  subfilters: [f12.id, size40.id, демисезон.id,      вискоза.id,     день1.id,   коричневый.id])
        subfByItem(item: i+68,  subfilters: [f12.id, size40.id, демисезон.id,      вискоза.id,     день1.id,   коричневый.id])
        subfByItem(item: i+69,  subfilters: [f12.id, size40.id, демисезон.id,      вискоза.id,     день1.id,   коричневый.id])
        subfByItem(item: i+70,  subfilters: [f12.id, size40.id, демисезон.id,      вискоза.id,     день1.id,   коричневый.id])
        subfByItem(item: i+71,  subfilters: [f12.id, size40.id, демисезон.id,      вискоза.id,     день1.id,   коричневый.id])
        subfByItem(item: i+72,  subfilters: [f12.id, size40.id, демисезон.id,      вискоза.id,     день1.id,   коричневый.id])
        subfByItem(item: i+73,  subfilters: [f12.id, size40.id, демисезон.id,      вискоза.id,     день1.id,   коричневый.id])
        subfByItem(item: i+74,  subfilters: [f12.id, size40.id, демисезон.id,      вискоза.id,     день1.id,   коричневый.id])
        subfByItem(item: i+75,  subfilters: [f12.id, size40.id, демисезон.id,      вискоза.id,     день1.id,   коричневый.id])
        subfByItem(item: i+76,  subfilters: [f12.id, size40.id, демисезон.id,      вискоза.id,     день1.id,   коричневый.id])
        subfByItem(item: i+77,  subfilters: [f12.id, size40.id, демисезон.id,      вискоза.id,     день1.id,   коричневый.id])
        subfByItem(item: i+78,  subfilters: [f12.id, size40.id, демисезон.id,      вискоза.id,     день1.id,   коричневый.id])
        subfByItem(item: i+79,  subfilters: [f12.id, size40.id, демисезон.id,      вискоза.id,     день1.id,   коричневый.id])
        subfByItem(item: i+80,  subfilters: [f12.id, size40.id, демисезон.id,      вискоза.id,     день1.id,   коричневый.id])
        
        subfByItem(item: i+81, subfilters: [f17.id, size36.id, демисезон.id,      шерсть.id,      дня3.id,    красный.id])
        subfByItem(item: i+82, subfilters: [f17.id, size36.id, демисезон.id,      шерсть.id,      дня3.id,    красный.id])
        subfByItem(item: i+83, subfilters: [f17.id, size36.id, демисезон.id,      шерсть.id,      дня3.id,    красный.id])
        subfByItem(item: i+84, subfilters: [f17.id, size36.id, демисезон.id,      шерсть.id,      дня3.id,    красный.id])
        subfByItem(item: i+85, subfilters: [f17.id, size36.id, демисезон.id,      шерсть.id,      дня3.id,    красный.id])
        subfByItem(item: i+86, subfilters: [f17.id, size36.id, демисезон.id,      шерсть.id,      дня3.id,    красный.id])
        subfByItem(item: i+87, subfilters: [f17.id, size36.id, демисезон.id,      шерсть.id,      дня3.id,    красный.id])
        subfByItem(item: i+88, subfilters: [f17.id, size36.id, демисезон.id,      шерсть.id,      дня3.id,    красный.id])
        subfByItem(item: i+89, subfilters: [f17.id, size36.id, демисезон.id,      шерсть.id,      дня3.id,    красный.id])
        subfByItem(item: i+90, subfilters: [f17.id, size36.id, демисезон.id,      шерсть.id,      дня3.id,    красный.id])
        
        subfByItem(item: i+91, subfilters: [f18.id, size34.id, демисезон.id,      шерсть.id,      дня4.id,    оранжевый.id])
        subfByItem(item: i+92, subfilters: [f18.id, size34.id, демисезон.id,      шерсть.id,      дня4.id,    оранжевый.id])
        subfByItem(item: i+93, subfilters: [f18.id, size34.id, демисезон.id,      шерсть.id,      дня4.id,    оранжевый.id])
        subfByItem(item: i+94, subfilters: [f18.id, size34.id, демисезон.id,      шерсть.id,      дня4.id,    оранжевый.id])
        subfByItem(item: i+95, subfilters: [f18.id, size34.id, демисезон.id,      шерсть.id,      дня4.id,    оранжевый.id])
        subfByItem(item: i+96, subfilters: [f18.id, size34.id, демисезон.id,      шерсть.id,      дня4.id,    оранжевый.id])
        subfByItem(item: i+97, subfilters: [f18.id, size34.id, демисезон.id,      шерсть.id,      дня4.id,    оранжевый.id])
        
        subfByItem(item: i+98,  subfilters: [f14.id, size42.id, лето.id,           хлопок.id,      день1.id,   розовый.id])
        subfByItem(item: i+99,  subfilters: [f14.id, size42.id, лето.id,           хлопок.id,      день1.id,   розовый.id])
        subfByItem(item: i+100,  subfilters: [f14.id, size42.id, лето.id,           хлопок.id,      день1.id,   розовый.id])
        subfByItem(item: i+101,  subfilters: [f14.id, size42.id, лето.id,           хлопок.id,      день1.id,   розовый.id])
        subfByItem(item: i+102,  subfilters: [f14.id, size42.id, лето.id,           хлопок.id,      день1.id,   розовый.id])
        subfByItem(item: i+103,  subfilters: [f14.id, size42.id, лето.id,           хлопок.id,      день1.id,   розовый.id])
 
        subfByItem(item: i+104,  subfilters: [f14.id, size42.id, лето.id,           хлопок.id,      день1.id,   серый.id])
        subfByItem(item: i+105,  subfilters: [f14.id, size42.id, лето.id,           хлопок.id,      день1.id,   серый.id])
        subfByItem(item: i+106,  subfilters: [f14.id, size42.id, лето.id,           хлопок.id,      дня4.id,   серый.id])
        subfByItem(item: i+107,  subfilters: [f14.id, size42.id, лето.id,           хлопок.id,      день1.id,   серый.id])
        subfByItem(item: i+108,  subfilters: [f14.id, size42.id, лето.id,           хлопок.id,      день1.id,   серый.id])
        subfByItem(item: i+109,  subfilters: [f14.id, size42.id, лето.id,           хлопок.id,      дня4.id,   серый.id])
        subfByItem(item: i+110,  subfilters: [f14.id, size42.id, лето.id,           хлопок.id,      день1.id,   серый.id])
        subfByItem(item: i+111,  subfilters: [f14.id, size42.id, лето.id,           хлопок.id,      день1.id,   серый.id])
        
        subfByItem(item: i+112, subfilters: [f23.id, size34.id, зима.id,           ангора.id,      день1.id,   синий.id])
        subfByItem(item: i+113, subfilters: [f23.id, size34.id, зима.id,           ангора.id,      день1.id,   синий.id])
        subfByItem(item: i+114, subfilters: [f23.id, size34.id, зима.id,           ангора.id,      день1.id,   синий.id])
        subfByItem(item: i+115, subfilters: [f23.id, size34.id, зима.id,           ангора.id,      день1.id,   синий.id])
        subfByItem(item: i+116, subfilters: [f23.id, size34.id, зима.id,           ангора.id,      день1.id,   синий.id])
        subfByItem(item: i+117, subfilters: [f23.id, size34.id, зима.id,           ангора.id,      день1.id,   синий.id])
        subfByItem(item: i+118, subfilters: [f23.id, size34.id, зима.id,           ангора.id,      день1.id,   синий.id])
        subfByItem(item: i+119, subfilters: [f23.id, size34.id, зима.id,           ангора.id,      день1.id,   синий.id])
        subfByItem(item: i+120, subfilters: [f23.id, size34.id, зима.id,           ангора.id,      день1.id,   синий.id])
        subfByItem(item: i+121, subfilters: [f23.id, size34.id, зима.id,           ангора.id,      день1.id,   синий.id])
        subfByItem(item: i+122, subfilters: [f23.id, size34.id, зима.id,           ангора.id,      день1.id,   синий.id])
        subfByItem(item: i+123, subfilters: [f23.id, size34.id, зима.id,           ангора.id,      день1.id,   синий.id])
        subfByItem(item: i+124, subfilters: [f23.id, size34.id, зима.id,           ангора.id,      день1.id,   синий.id])
        subfByItem(item: i+125, subfilters: [f23.id, size34.id, зима.id,           ангора.id,      день1.id,   синий.id])
        subfByItem(item: i+126, subfilters: [f23.id, size34.id, зима.id,           ангора.id,      день1.id,   синий.id])
        subfByItem(item: i+127, subfilters: [f23.id, size34.id, зима.id,           ангора.id,      день1.id,   синий.id])
        subfByItem(item: i+128, subfilters: [f23.id, size34.id, зима.id,           ангора.id,      день1.id,   синий.id])
        
        subfByItem(item: i+129, subfilters: [f22.id, size34.id, демисезон.id,      шерсть.id,      дня4.id,    фиолетовый.id])
        subfByItem(item: i+130, subfilters: [f22.id, size34.id, демисезон.id,      шерсть.id,      дня4.id,    фиолетовый.id])
        subfByItem(item: i+131, subfilters: [f22.id, size34.id, демисезон.id,      шерсть.id,      дня4.id,    фиолетовый.id])
        subfByItem(item: i+132, subfilters: [f22.id, size34.id, демисезон.id,      шерсть.id,      дня4.id,    фиолетовый.id])
        subfByItem(item: i+133, subfilters: [f22.id, size34.id, демисезон.id,      шерсть.id,      дня4.id,    фиолетовый.id])
        subfByItem(item: i+134, subfilters: [f22.id, size34.id, демисезон.id,      шерсть.id,      дня4.id,    фиолетовый.id])
        subfByItem(item: i+135, subfilters: [f22.id, size34.id, демисезон.id,      шерсть.id,      дня4.id,    фиолетовый.id])
    }
    
    firebaseStore()
    
    firebaseStore2()
    
    firebaseStore3(categoryId: 01010101, minPrice: 2200, maxPrice: 15600)
    firebaseStore3(categoryId: 01010102, minPrice: 3000, maxPrice: 19000)
    firebaseStore3(categoryId: 01010103, minPrice: 5555, maxPrice: 55000)
    
    //stride(from: 0, to: 30038, by: 38)
    for i in stride(from: 0, to: 30135, by: 135) {
        let _ = CatalogModel1(id: i+1, categoryId: 01010101, name: "", thumbnail: "blue-1", stars: 3, newPrice: 2200, oldPrice: 6500, votes: 145, discount: 30)
        let _ = CatalogModel1(id: i+2, categoryId: 01010101, name: "", thumbnail: "yellow-1", stars: 1, newPrice: 2300, oldPrice: 5200, votes: 245, discount: 30)
        let _ = CatalogModel1(id: i+3, categoryId: 01010101, name: "", thumbnail: "yellow-2", stars: 4, newPrice: 2400, oldPrice: 3000, votes: 545, discount: 50)
        let _ = CatalogModel1(id: i+4, categoryId: 01010101, name: "", thumbnail: "green-1", stars: 5, newPrice: 2500, oldPrice: 7500, votes: 45, discount: 50)
        let _ = CatalogModel1(id: i+5, categoryId: 01010101, name: "", thumbnail: "brown-1", stars: 1, newPrice: 2600, oldPrice: 6400, votes: 45, discount: 50)
        let _ = CatalogModel1(id: i+6, categoryId: 01010101, name: "", thumbnail: "blue-2", stars: 2, newPrice: 2700, oldPrice: 6350, votes: 45, discount: 40)
        let _ = CatalogModel1(id: i+7, categoryId: 01010101, name: "", thumbnail: "orange-1", stars: 2, newPrice: 2800, oldPrice: 8400, votes: 1, discount: 40)
        let _ = CatalogModel1(id: i+8, categoryId: 01010101, name: "", thumbnail: "pink-1", stars: 3, newPrice: 2900, oldPrice: 10500, votes: 433, discount: 40)
        let _ = CatalogModel1(id: i+9, categoryId: 01010101, name: "", thumbnail: "brown-2", stars: 4, newPrice: 3000, oldPrice: 11200, votes: 1003, discount: 30)
        let _ = CatalogModel1(id: i+10, categoryId: 01010101, name: "", thumbnail: "blue-3", stars: 4, newPrice: 3100, oldPrice: 4700, votes: 445, discount: 30)
        let _ = CatalogModel1(id: i+11, categoryId: 01010101, name: "", thumbnail: "violet-1", stars: 4, newPrice: 3100, oldPrice: 6500, votes: 33, discount: 20)
        let _ = CatalogModel1(id: i+12, categoryId: 01010101, name: "", thumbnail: "black-1", stars: 5, newPrice: 3300, oldPrice: 6500, votes: 54, discount: 20)
        let _ = CatalogModel1(id: i+13, categoryId: 01010101, name: "", thumbnail: "white-1", stars: 5, newPrice: 3400, oldPrice: 6500, votes: 45, discount: 30)
        let _ = CatalogModel1(id: i+14, categoryId: 01010101, name: "", thumbnail: "black-2", stars: 4, newPrice: 3500, oldPrice: 6500, votes: 45, discount: 40)
        let _ = CatalogModel1(id: i+15, categoryId: 01010101, name: "", thumbnail: "red-1", stars: 1, newPrice: 3600, oldPrice: 6500, votes: 45, discount: 25)
        let _ = CatalogModel1(id: i+16, categoryId: 01010101, name: "", thumbnail: "white-2", stars: 2, newPrice: 3700, oldPrice: 6500, votes: 45, discount: 35)
        let _ = CatalogModel1(id: i+17, categoryId: 01010101, name: "", thumbnail: "brown-3", stars: 2, newPrice: 3800, oldPrice: 6500, votes: 45, discount: 50)
        let _ = CatalogModel1(id: i+18, categoryId: 01010101, name: "", thumbnail: "black-3", stars: 2, newPrice: 3900, oldPrice: 6500, votes: 45, discount: 50)
        let _ = CatalogModel1(id: i+19, categoryId: 01010101, name: "", thumbnail: "orange-2", stars: 1, newPrice: 4000, oldPrice: 6500, votes: 45, discount: 50)
        let _ = CatalogModel1(id: i+20, categoryId: 01010101, name: "", thumbnail: "white-3", stars: 3, newPrice: 4100, oldPrice: 6500, votes: 45, discount: 40)
        let _ = CatalogModel1(id: i+21, categoryId: 01010101, name: "", thumbnail: "yellow-3", stars: 3, newPrice: 4200, oldPrice: 6500, votes: 45, discount: 30)
        let _ = CatalogModel1(id: i+22, categoryId: 01010101, name: "", thumbnail: "black-4", stars: 3, newPrice: 4300, oldPrice: 6500, votes: 45, discount: 30)
        let _ = CatalogModel1(id: i+23, categoryId: 01010101, name: "", thumbnail: "violet-2", stars: 3, newPrice: 4400, oldPrice: 6500, votes: 45, discount: 30)
        let _ = CatalogModel1(id: i+24, categoryId: 01010101, name: "", thumbnail: "blue-4", stars: 3, newPrice: 4500, oldPrice: 6500, votes: 45, discount: 30)
        let _ = CatalogModel1(id: i+25, categoryId: 01010101, name: "", thumbnail: "blue-5", stars: 3, newPrice: 4600, oldPrice: 6500, votes: 45, discount: 30)
        let _ = CatalogModel1(id: i+26, categoryId: 01010101, name: "", thumbnail: "white-4", stars: 3, newPrice: 4700, oldPrice: 6500, votes: 45, discount: 30)
        let _ = CatalogModel1(id: i+27, categoryId: 01010101, name: "", thumbnail: "white-5", stars: 3, newPrice: 4800, oldPrice: 6500, votes: 45, discount: 30)
        let _ = CatalogModel1(id: i+28, categoryId: 01010101, name: "", thumbnail: "blue-6", stars: 3, newPrice: 4900, oldPrice: 6500, votes: 45, discount: 30)
        let _ = CatalogModel1(id: i+29, categoryId: 01010101, name: "", thumbnail: "blue-7", stars: 3, newPrice: 5000, oldPrice: 6500, votes: 45, discount: 30)
        let _ = CatalogModel1(id: i+30, categoryId: 01010101, name: "", thumbnail: "beige1", stars: 3, newPrice: 5100, oldPrice: 6500, votes: 45, discount: 30) // --->
        let _ = CatalogModel1(id: i+31, categoryId: 01010101, name: "", thumbnail: "white-5", stars: 3, newPrice: 5200, oldPrice: 6500, votes: 45, discount: 30)
        let _ = CatalogModel1(id: i+32, categoryId: 01010101, name: "", thumbnail: "white-6", stars: 3, newPrice: 5300, oldPrice: 6500, votes: 45, discount: 30)
        let _ = CatalogModel1(id: i+33, categoryId: 01010101, name: "", thumbnail: "blue-8", stars: 3, newPrice: 5400, oldPrice: 6500, votes: 45, discount: 30)
        let _ = CatalogModel1(id: i+34, categoryId: 01010101, name: "", thumbnail: "white-7", stars: 3, newPrice: 5500, oldPrice: 6500, votes: 45, discount: 30)
        let _ = CatalogModel1(id: i+35, categoryId: 01010101, name: "", thumbnail: "white-8", stars: 3, newPrice: 5600, oldPrice: 6500, votes: 45, discount: 30)
        let _ = CatalogModel1(id: i+36, categoryId: 01010101, name: "", thumbnail: "white-9", stars: 3, newPrice: 5700, oldPrice: 6500, votes: 45, discount: 30)
        let _ = CatalogModel1(id: i+37, categoryId: 01010101, name: "", thumbnail: "blue-9", stars: 3, newPrice: 5800, oldPrice: 6500, votes: 45, discount: 30)
        let _ = CatalogModel1(id: i+38, categoryId: 01010101, name: "", thumbnail: "beige2", stars: 3, newPrice: 5900, oldPrice: 6500, votes: 45, discount: 30)
        let _ = CatalogModel1(id: i+39, categoryId: 01010101, name: "", thumbnail: "beige3", stars: 3, newPrice: 6000, oldPrice: 6500, votes: 45, discount: 30)// --->
        let _ = CatalogModel1(id: i+40, categoryId: 01010101, name: "", thumbnail: "beige4", stars: 3, newPrice: 6100, oldPrice: 6500, votes: 45, discount: 30)
        let _ = CatalogModel1(id: i+41, categoryId: 01010101, name: "", thumbnail: "beige5", stars: 3, newPrice: 6200, oldPrice: 6500, votes: 45, discount: 30)
        let _ = CatalogModel1(id: i+42, categoryId: 01010101, name: "", thumbnail: "beige6", stars: 3, newPrice: 6300, oldPrice: 6500, votes: 45, discount: 30)
        let _ = CatalogModel1(id: i+43, categoryId: 01010101, name: "", thumbnail: "beige7", stars: 3, newPrice: 6400, oldPrice: 6500, votes: 45, discount: 30)
        let _ = CatalogModel1(id: i+44, categoryId: 01010101, name: "", thumbnail: "beige8", stars: 3, newPrice: 6500, oldPrice: 6500, votes: 45, discount: 30)
        
        
        let _ = CatalogModel1(id: i+45, categoryId: 01010101, name: "", thumbnail: "yellow-4", stars: 3, newPrice: 6600, oldPrice: 7500, votes: 45, discount: 30)
        let _ = CatalogModel1(id: i+46, categoryId: 01010101, name: "", thumbnail: "yellow-5", stars: 3, newPrice: 6700, oldPrice: 7500, votes: 45, discount: 30)
        let _ = CatalogModel1(id: i+47, categoryId: 01010101, name: "", thumbnail: "yellow-6", stars: 3, newPrice: 6800, oldPrice: 7500, votes: 45, discount: 30)
        let _ = CatalogModel1(id: i+48, categoryId: 01010101, name: "", thumbnail: "yellow-7", stars: 3, newPrice: 6900, oldPrice: 7500, votes: 45, discount: 30)
        let _ = CatalogModel1(id: i+49, categoryId: 01010101, name: "", thumbnail: "yellow-8", stars: 3, newPrice: 7000, oldPrice: 7500, votes: 45, discount: 30)
        let _ = CatalogModel1(id: i+50, categoryId: 01010101, name: "", thumbnail: "yellow-9", stars: 3, newPrice: 7100, oldPrice: 7500, votes: 45, discount: 30)
        let _ = CatalogModel1(id: i+51, categoryId: 01010101, name: "", thumbnail: "yellow-10", stars: 3, newPrice: 7200, oldPrice: 7500, votes: 45, discount: 30)
        let _ = CatalogModel1(id: i+52, categoryId: 01010101, name: "", thumbnail: "yellow-11", stars: 3, newPrice: 7300, oldPrice: 8500, votes: 45, discount: 30)
        let _ = CatalogModel1(id: i+53, categoryId: 01010101, name: "", thumbnail: "yellow-12", stars: 3, newPrice: 7400, oldPrice: 8500, votes: 45, discount: 30)
        let _ = CatalogModel1(id: i+54, categoryId: 01010101, name: "", thumbnail: "yellow-13", stars: 3, newPrice: 7500, oldPrice: 8500, votes: 45, discount: 30)
        let _ = CatalogModel1(id: i+55, categoryId: 01010101, name: "", thumbnail: "yellow-14", stars: 3, newPrice: 7600, oldPrice: 8500, votes: 45, discount: 30)
        let _ = CatalogModel1(id: i+56, categoryId: 01010101, name: "", thumbnail: "yellow-15", stars: 3, newPrice: 7700, oldPrice: 8500, votes: 45, discount: 30)
        let _ = CatalogModel1(id: i+57, categoryId: 01010101, name: "", thumbnail: "yellow-16", stars: 3, newPrice: 7800, oldPrice: 8500, votes: 45, discount: 30)
        let _ = CatalogModel1(id: i+58, categoryId: 01010101, name: "", thumbnail: "yellow-17", stars: 3, newPrice: 7900, oldPrice: 8500, votes: 45, discount: 30)
        
        let _ = CatalogModel1(id: i+59, categoryId: 01010101, name: "", thumbnail: "green-2", stars: 3, newPrice: 8000, oldPrice: 8500, votes: 45, discount: 30)
        let _ = CatalogModel1(id: i+60, categoryId: 01010101, name: "", thumbnail: "green-3", stars: 3, newPrice: 8100, oldPrice: 8500, votes: 45, discount: 30)
        let _ = CatalogModel1(id: i+61, categoryId: 01010101, name: "", thumbnail: "green-4", stars: 3, newPrice: 8200, oldPrice: 8500, votes: 45, discount: 30)
        let _ = CatalogModel1(id: i+62, categoryId: 01010101, name: "", thumbnail: "green-5", stars: 3, newPrice: 8300, oldPrice: 9500, votes: 45, discount: 30)
        let _ = CatalogModel1(id: i+63, categoryId: 01010101, name: "", thumbnail: "green-6", stars: 3, newPrice: 8400, oldPrice: 9500, votes: 45, discount: 30)
        let _ = CatalogModel1(id: i+64, categoryId: 01010101, name: "", thumbnail: "green-7", stars: 3, newPrice: 8500, oldPrice: 9500, votes: 45, discount: 30)
        let _ = CatalogModel1(id: i+65, categoryId: 01010101, name: "", thumbnail: "green-8", stars: 3, newPrice: 8600, oldPrice: 9500, votes: 45, discount: 30)
        let _ = CatalogModel1(id: i+66, categoryId: 01010101, name: "", thumbnail: "green-9", stars: 3, newPrice: 8700, oldPrice: 9500, votes: 45, discount: 30)
        
        let _ = CatalogModel1(id: i+67, categoryId: 01010101, name: "", thumbnail: "brown-4", stars: 4, newPrice: 8800, oldPrice: 11200, votes: 1003, discount: 30)
        let _ = CatalogModel1(id: i+68, categoryId: 01010101, name: "", thumbnail: "brown-5", stars: 4, newPrice: 8900, oldPrice: 11200, votes: 1003, discount: 30)
        let _ = CatalogModel1(id: i+69, categoryId: 01010101, name: "", thumbnail: "brown-6", stars: 4, newPrice: 9000, oldPrice: 11200, votes: 1003, discount: 30)
        let _ = CatalogModel1(id: i+70, categoryId: 01010101, name: "", thumbnail: "brown-7", stars: 4, newPrice: 9100, oldPrice: 11200, votes: 1003, discount: 30)
        let _ = CatalogModel1(id: i+71, categoryId: 01010101, name: "", thumbnail: "brown-8", stars: 4, newPrice: 9200, oldPrice: 11200, votes: 1003, discount: 30)
        let _ = CatalogModel1(id: i+72, categoryId: 01010101, name: "", thumbnail: "brown-9", stars: 4, newPrice: 9300, oldPrice: 11200, votes: 1003, discount: 30)
        let _ = CatalogModel1(id: i+73, categoryId: 01010101, name: "", thumbnail: "brown-10", stars: 4, newPrice: 9400, oldPrice: 11200, votes: 1003, discount: 30)
        let _ = CatalogModel1(id: i+74, categoryId: 01010101, name: "", thumbnail: "brown-11", stars: 4, newPrice: 9500, oldPrice: 11200, votes: 1003, discount: 30)
        let _ = CatalogModel1(id: i+75, categoryId: 01010101, name: "", thumbnail: "brown-12", stars: 4, newPrice: 9600, oldPrice: 11200, votes: 1003, discount: 30)
        let _ = CatalogModel1(id: i+76, categoryId: 01010101, name: "", thumbnail: "brown-13", stars: 4, newPrice: 9700, oldPrice: 11200, votes: 1003, discount: 30)
        let _ = CatalogModel1(id: i+77, categoryId: 01010101, name: "", thumbnail: "brown-14", stars: 4, newPrice: 9800, oldPrice: 11200, votes: 1003, discount: 30)
        let _ = CatalogModel1(id: i+78, categoryId: 01010101, name: "", thumbnail: "brown-15", stars: 4, newPrice: 9900, oldPrice: 11200, votes: 1003, discount: 30)
        let _ = CatalogModel1(id: i+79, categoryId: 01010101, name: "", thumbnail: "brown-16", stars: 4, newPrice: 10000, oldPrice: 11200, votes: 1003, discount: 30)
        let _ = CatalogModel1(id: i+80, categoryId: 01010101, name: "", thumbnail: "brown-17", stars: 4, newPrice: 10100, oldPrice: 11200, votes: 1003, discount: 30)

        let _ = CatalogModel1(id: i+81, categoryId: 01010101, name: "", thumbnail: "red-2", stars: 1, newPrice: 10200, oldPrice: 16500, votes: 45, discount: 25)
        let _ = CatalogModel1(id: i+82, categoryId: 01010101, name: "", thumbnail: "red-3", stars: 1, newPrice: 10300, oldPrice: 16500, votes: 45, discount: 25)
        let _ = CatalogModel1(id: i+83, categoryId: 01010101, name: "", thumbnail: "red-4", stars: 1, newPrice: 10400, oldPrice: 16500, votes: 45, discount: 25)
        let _ = CatalogModel1(id: i+84, categoryId: 01010101, name: "", thumbnail: "red-5", stars: 1, newPrice: 10500, oldPrice: 16500, votes: 45, discount: 25)
        let _ = CatalogModel1(id: i+85, categoryId: 01010101, name: "", thumbnail: "red-6", stars: 1, newPrice: 10600, oldPrice: 16500, votes: 45, discount: 25)
        let _ = CatalogModel1(id: i+86, categoryId: 01010101, name: "", thumbnail: "red-7", stars: 1, newPrice: 10700, oldPrice: 16500, votes: 45, discount: 25)
        let _ = CatalogModel1(id: i+87, categoryId: 01010101, name: "", thumbnail: "red-8", stars: 1, newPrice: 10800, oldPrice: 16500, votes: 45, discount: 25)
        let _ = CatalogModel1(id: i+88, categoryId: 01010101, name: "", thumbnail: "red-9", stars: 1, newPrice: 10900, oldPrice: 16500, votes: 45, discount: 25)
        let _ = CatalogModel1(id: i+89, categoryId: 01010101, name: "", thumbnail: "red-10", stars: 1, newPrice: 11000, oldPrice: 16500, votes: 45, discount: 25)
        let _ = CatalogModel1(id: i+90, categoryId: 01010101, name: "", thumbnail: "red-11", stars: 1, newPrice: 11100, oldPrice: 16500, votes: 45, discount: 25)
        
        let _ = CatalogModel1(id: i+91, categoryId: 01010101, name: "", thumbnail: "orange-3", stars: 1, newPrice: 11200, oldPrice: 16500, votes: 45, discount: 50)
        let _ = CatalogModel1(id: i+92, categoryId: 01010101, name: "", thumbnail: "orange-4", stars: 1, newPrice: 11300, oldPrice: 16500, votes: 45, discount: 50)
        let _ = CatalogModel1(id: i+93, categoryId: 01010101, name: "", thumbnail: "orange-5", stars: 1, newPrice: 11400, oldPrice: 16500, votes: 45, discount: 50)
        let _ = CatalogModel1(id: i+94, categoryId: 01010101, name: "", thumbnail: "orange-6", stars: 1, newPrice: 11500, oldPrice: 16500, votes: 45, discount: 50)
        let _ = CatalogModel1(id: i+95, categoryId: 01010101, name: "", thumbnail: "orange-7", stars: 1, newPrice: 11600, oldPrice: 16500, votes: 45, discount: 50)
        let _ = CatalogModel1(id: i+96, categoryId: 01010101, name: "", thumbnail: "orange-8", stars: 1, newPrice: 11700, oldPrice: 16500, votes: 45, discount: 50)
        let _ = CatalogModel1(id: i+97, categoryId: 01010101, name: "", thumbnail: "orange-9", stars: 1, newPrice: 11800, oldPrice: 16500, votes: 45, discount: 50)
        
        let _ = CatalogModel1(id: i+98, categoryId: 01010101, name: "", thumbnail: "pink-2", stars: 3, newPrice: 11900, oldPrice: 12500, votes: 433, discount: 40)
        let _ = CatalogModel1(id: i+99, categoryId: 01010101, name: "", thumbnail: "pink-3", stars: 3, newPrice: 12000, oldPrice: 15500, votes: 433, discount: 40)
        let _ = CatalogModel1(id: i+100, categoryId: 01010101, name: "", thumbnail: "pink-4", stars: 3, newPrice: 12100, oldPrice: 15500, votes: 433, discount: 40)
        let _ = CatalogModel1(id: i+101, categoryId: 01010101, name: "", thumbnail: "pink-5", stars: 3, newPrice: 12200, oldPrice: 15500, votes: 433, discount: 40)
        let _ = CatalogModel1(id: i+102, categoryId: 01010101, name: "", thumbnail: "pink-6", stars: 3, newPrice: 12300, oldPrice: 16500, votes: 433, discount: 40)
        let _ = CatalogModel1(id: i+103, categoryId: 01010101, name: "", thumbnail: "pink-7", stars: 3, newPrice: 12400, oldPrice: 17500, votes: 433, discount: 40)
        
        
        let _ = CatalogModel1(id: i+104, categoryId: 01010101, name: "", thumbnail: "gray-1", stars: 3, newPrice: 12500, oldPrice: 18500, votes: 433, discount: 40)
        let _ = CatalogModel1(id: i+105, categoryId: 01010101, name: "", thumbnail: "gray-2", stars: 3, newPrice: 12600, oldPrice: 19500, votes: 433, discount: 40)
        let _ = CatalogModel1(id: i+106, categoryId: 01010101, name: "", thumbnail: "gray-3", stars: 3, newPrice: 12700, oldPrice: 13500, votes: 433, discount: 40)
        let _ = CatalogModel1(id: i+107, categoryId: 01010101, name: "", thumbnail: "gray-4", stars: 3, newPrice: 12800, oldPrice: 12500, votes: 433, discount: 40)
        let _ = CatalogModel1(id: i+108, categoryId: 01010101, name: "", thumbnail: "gray-5", stars: 3, newPrice: 12900, oldPrice: 13500, votes: 433, discount: 40)
        let _ = CatalogModel1(id: i+109, categoryId: 01010101, name: "", thumbnail: "gray-6", stars: 3, newPrice: 13000, oldPrice: 14500, votes: 433, discount: 40)
        let _ = CatalogModel1(id: i+110, categoryId: 01010101, name: "", thumbnail: "gray-7", stars: 3, newPrice: 13100, oldPrice: 15500, votes: 433, discount: 40)
        let _ = CatalogModel1(id: i+111, categoryId: 01010101, name: "", thumbnail: "gray-8", stars: 3, newPrice: 13200, oldPrice: 16500, votes: 433, discount: 40)
        
        
        let _ = CatalogModel1(id: i+112, categoryId: 01010101, name: "", thumbnail: "blue-11", stars: 3, newPrice: 13300, oldPrice: 16500, votes: 45, discount: 30)
        let _ = CatalogModel1(id: i+113, categoryId: 01010101, name: "", thumbnail: "blue-12", stars: 3, newPrice: 13400, oldPrice: 16500, votes: 45, discount: 30)
        let _ = CatalogModel1(id: i+114, categoryId: 01010101, name: "", thumbnail: "blue-13", stars: 3, newPrice: 13500, oldPrice: 16500, votes: 45, discount: 30)
        let _ = CatalogModel1(id: i+115, categoryId: 01010101, name: "", thumbnail: "blue-14", stars: 3, newPrice: 13600, oldPrice: 16500, votes: 45, discount: 30)
        let _ = CatalogModel1(id: i+116, categoryId: 01010101, name: "", thumbnail: "blue-15", stars: 3, newPrice: 13700, oldPrice: 16500, votes: 45, discount: 30)
        let _ = CatalogModel1(id: i+117, categoryId: 01010101, name: "", thumbnail: "blue-16", stars: 3, newPrice: 13800, oldPrice: 16500, votes: 45, discount: 30)
        let _ = CatalogModel1(id: i+118, categoryId: 01010101, name: "", thumbnail: "blue-17", stars: 3, newPrice: 13900, oldPrice: 16500, votes: 45, discount: 30)
        let _ = CatalogModel1(id: i+119, categoryId: 01010101, name: "", thumbnail: "blue-18", stars: 3, newPrice: 14000, oldPrice: 16500, votes: 45, discount: 30)
        let _ = CatalogModel1(id: i+120, categoryId: 01010101, name: "", thumbnail: "blue-19", stars: 3, newPrice: 14100, oldPrice: 16500, votes: 45, discount: 30)
        let _ = CatalogModel1(id: i+121, categoryId: 01010101, name: "", thumbnail: "blue-20", stars: 3, newPrice: 14200, oldPrice: 16500, votes: 45, discount: 30)
        let _ = CatalogModel1(id: i+122, categoryId: 01010101, name: "", thumbnail: "blue-21", stars: 3, newPrice: 14300, oldPrice: 16500, votes: 45, discount: 30)
        let _ = CatalogModel1(id: i+123, categoryId: 01010101, name: "", thumbnail: "blue-22", stars: 3, newPrice: 14400, oldPrice: 16500, votes: 45, discount: 30)
        let _ = CatalogModel1(id: i+124, categoryId: 01010101, name: "", thumbnail: "blue-23", stars: 3, newPrice: 14500, oldPrice: 16500, votes: 45, discount: 30)
        let _ = CatalogModel1(id: i+125, categoryId: 01010101, name: "", thumbnail: "blue-24", stars: 3, newPrice: 14600, oldPrice: 16500, votes: 45, discount: 30)
        let _ = CatalogModel1(id: i+126, categoryId: 01010101, name: "", thumbnail: "blue-25", stars: 3, newPrice: 14700, oldPrice: 16500, votes: 45, discount: 30)
        let _ = CatalogModel1(id: i+127, categoryId: 01010101, name: "", thumbnail: "blue-26", stars: 3, newPrice: 14800, oldPrice: 16500, votes: 45, discount: 30)
        let _ = CatalogModel1(id: i+128, categoryId: 01010101, name: "", thumbnail: "blue-27", stars: 3, newPrice: 14900, oldPrice: 16500, votes: 45, discount: 30)
        
        let _ = CatalogModel1(id: i+129, categoryId: 01010101, name: "", thumbnail: "violet-3", stars: 4, newPrice: 15000, oldPrice: 16500, votes: 33, discount: 20)
        let _ = CatalogModel1(id: i+130, categoryId: 01010101, name: "", thumbnail: "violet-4", stars: 4, newPrice: 15100, oldPrice: 26500, votes: 33, discount: 20)
        let _ = CatalogModel1(id: i+131, categoryId: 01010101, name: "", thumbnail: "violet-5", stars: 4, newPrice: 15200, oldPrice: 26500, votes: 33, discount: 20)
        let _ = CatalogModel1(id: i+132, categoryId: 01010101, name: "", thumbnail: "violet-6", stars: 4, newPrice: 15300, oldPrice: 26500, votes: 33, discount: 20)
        let _ = CatalogModel1(id: i+133, categoryId: 01010101, name: "", thumbnail: "violet-7", stars: 4, newPrice: 15400, oldPrice: 26500, votes: 33, discount: 20)
        let _ = CatalogModel1(id: i+134, categoryId: 01010101, name: "", thumbnail: "violet-8", stars: 4, newPrice: 15500, oldPrice: 26500, votes: 33, discount: 20)
        let _ = CatalogModel1(id: i+135, categoryId: 01010101, name: "", thumbnail: "violet-9", stars: 4, newPrice: 15600, oldPrice: 26500, votes: 33, discount: 20)
    }

}


func subfByItem(item: Int, subfilters: [Int]){
    let _ = Item(id: item, subfilters: subfilters)
    subfiltersByItem[item] = subfilters
}
