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
    var categoryId = 0
    var title: String
    var enabled = true
    var sectionHeader = ""
    
    init(id: Int, filterId: Int, title: String, sectionHeader: String = "", categoryId: Int) {
        self.categoryId = categoryId
        self.filterId = filterId
        self.id = id
        self.title = title
        self.sectionHeader = sectionHeader
        
        addSubF(id: id, subFilter: self)
        fillSubfiltersByFilter(filterId: filterId, subfilterId: id)
        
        subfilterFirebaseStore()
    }
    
    func getDictionary()->[String: Any]  {
        return ["categoryId": categoryId, "id": id, "filterId":filterId, "title":title, "enabled":enabled, "sectionHeader":sectionHeader]
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
    var categoryId = 0
    
    init(id: Int, subfilters: [Int], categoryId: Int) {
        self.id = id
        self.subfilters = subfilters
        self.categoryId = categoryId
        fillItemsBySubfilter(item: id, subfilters: subfilters)
        itemFirebaseStore()
    }
    
    func getDictionary()->[String: Any]  {
        return ["categoryId": categoryId, "id": id, "subfilters": subfilters]
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
        catalogFirebaseStore2(categoryId)
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
    
    
    func catalogFirebaseStore2(_ categoryId: Int){
        let rootRef = Database.database().reference()
        let childRef = rootRef.child("pricesByItem")
        let itemsRef = childRef.child("item\(id)")
        itemsRef.setValue(["categoryId": categoryId, "id": id, "price": newPrice])
    }
}




func firebaseStore(_ categoryId: Int){
    let rootRef = Database.database().reference()
    let childRef = rootRef.child("itemsBySubfilter")
    for (key, val) in itemsBySubfilter {
        let itemsRef = childRef.child("subfilter\(key)")
        itemsRef.setValue(["categoryId": categoryId, "id": key, "items": val])
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

//
//func firebaseStore2(){
//    let rootRef = Database.database().reference()
//    let childRef = rootRef.child("subfiltersByFilter")
//    for (key, val) in subfiltersByFilter {
//        let itemsRef = childRef.child("filter\(key)")
//        itemsRef.setValue(["id": key, "subfilters": val])
//    }
//}

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



func subfByItem(item: Int, subfilters: [Int], categoryId: Int){
    let _ = Item(id: item, subfilters: subfilters, categoryId: categoryId)
    subfiltersByItem[item] = subfilters
}
