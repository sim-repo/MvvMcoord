import Foundation
import RxSwift


var catalogs: [Int:[CatalogModel]] = [:]


class CatalogModel{
    let id: Int
    let categoryId: Int
    let name: String
    let thumbnail: String
    let stars: NSMutableAttributedString
    let newPrice: String
    let oldPrice: NSMutableAttributedString
    let votes: Int
    let discount: Int
    
    
    init(id: Int, categoryId: Int, name: String, thumbnail: String, stars: Int, newPrice: NSNumber, oldPrice: NSNumber, votes: Int, discount: Int) {
        self.id = id
        self.categoryId = categoryId
        self.name = name
        self.thumbnail = thumbnail
        self.stars = Formatter.starsFormat(stars: stars, votes: votes)
        self.newPrice = Formatter.priceFormat(price: newPrice, localeIdentifier: "ru_RU")!
        self.oldPrice = Formatter.strikePriceFormat(price: oldPrice, localeIdentifier: "ru_RU")!
        self.votes = votes
        self.discount = discount
    }
    
    static func fillModels(){
        let w1 = [
            CatalogModel(id: 1, categoryId: 01010101, name: "Abby", thumbnail: "pic", stars: 3, newPrice: 4500, oldPrice: 6500, votes: 145, discount: 30),
            CatalogModel(id: 2, categoryId: 01010101, name: "ABODIE", thumbnail: "pic2", stars: 1, newPrice: 4700, oldPrice: 5200, votes: 245, discount: 30),
            CatalogModel(id: 3, categoryId: 01010101, name: "ABODIE", thumbnail: "pic5", stars: 4, newPrice: 2200, oldPrice: 3000, votes: 545, discount: 50),
            CatalogModel(id: 4, categoryId: 01010101, name: "Acasta", thumbnail: "pic6", stars: 5, newPrice: 5500, oldPrice: 7500, votes: 45, discount: 50),
            CatalogModel(id: 5, categoryId: 01010101, name: "Acasta", thumbnail: "pic7", stars: 1, newPrice: 4555, oldPrice: 6400, votes: 45, discount: 50),
            CatalogModel(id: 6, categoryId: 01010101, name: "Acasta", thumbnail: "pic", stars: 2, newPrice: 4555, oldPrice: 6350, votes: 45, discount: 40),
            CatalogModel(id: 7, categoryId: 01010101, name: "Adelante", thumbnail: "pic2", stars: 2, newPrice: 5800, oldPrice: 8400, votes: 1, discount: 40),
            CatalogModel(id: 8, categoryId: 01010101, name: "Adele", thumbnail: "pic5", stars: 3, newPrice: 8540, oldPrice: 10500, votes: 433, discount: 40),
            CatalogModel(id: 9, categoryId: 01010101, name: "Adele", thumbnail: "pic6", stars: 4, newPrice: 9000, oldPrice: 11200, votes: 1003, discount: 30),
            CatalogModel(id: 10, categoryId: 01010101, name: "Adele", thumbnail: "pic7", stars: 4, newPrice: 3000, oldPrice: 4700, votes: 445, discount: 30),
            CatalogModel(id: 11, categoryId: 01010101, name: "Adele", thumbnail: "pic", stars: 4, newPrice: 4555, oldPrice: 6500, votes: 33, discount: 20),
            CatalogModel(id: 12, categoryId: 01010101, name: "Adelin Fostayn", thumbnail: "pic2", stars: 5, newPrice: 4555, oldPrice: 6500, votes: 54, discount: 20),
            CatalogModel(id: 13, categoryId: 01010101, name: "Adelin Fostayn", thumbnail: "pic5", stars: 5, newPrice: 4555, oldPrice: 6500, votes: 45, discount: 30),
            CatalogModel(id: 14, categoryId: 01010101, name: "Adidas", thumbnail: "pic6", stars: 4, newPrice: 4555, oldPrice: 6500, votes: 45, discount: 40),
            CatalogModel(id: 15, categoryId: 01010101, name: "ADZHERO", thumbnail: "pic7", stars: 1, newPrice: 4555, oldPrice: 6500, votes: 45, discount: 25),
            CatalogModel(id: 16, categoryId: 01010101, name: "ADZHERO", thumbnail: "pic", stars: 2, newPrice: 4555, oldPrice: 6500, votes: 45, discount: 35),
            CatalogModel(id: 17, categoryId: 01010101, name: "ADZHERO", thumbnail: "pic2", stars: 2, newPrice: 4555, oldPrice: 6500, votes: 45, discount: 50),
            CatalogModel(id: 18, categoryId: 01010101, name: "Aelite", thumbnail: "pic5", stars: 2, newPrice: 4555, oldPrice: 6500, votes: 45, discount: 50),
            CatalogModel(id: 19, categoryId: 01010101, name: "Aelite", thumbnail: "pic6", stars: 1, newPrice: 4555, oldPrice: 6500, votes: 45, discount: 50),
            CatalogModel(id: 20, categoryId: 01010101, name: "AFFARI", thumbnail: "pic7", stars: 3, newPrice: 4555, oldPrice: 6500, votes: 45, discount: 40),
            CatalogModel(id: 21, categoryId: 01010101, name: "B&Co", thumbnail: "pic10", stars: 3, newPrice: 4555, oldPrice: 6500, votes: 45, discount: 30),
        ]
        catalogs[01010101] = w1
        
        
        let w2 = [
            CatalogModel(id: 22, categoryId: 01010101, name: "B&H", thumbnail: "pic10", stars: 3, newPrice: 4555, oldPrice: 6500, votes: 45, discount: 50),
            CatalogModel(id: 23, categoryId: 01010101, name: "Babylon", thumbnail: "pic12", stars: 3, newPrice: 4555, oldPrice: 6500, votes: 45, discount: 50),
            CatalogModel(id: 24, categoryId: 01010101, name: "Babylon", thumbnail: "pic14", stars: 3, newPrice: 4555, oldPrice: 6500, votes: 45, discount: 50),
            CatalogModel(id: 25, categoryId: 01010101, name: "Balasko", thumbnail: "pic16", stars: 3, newPrice: 4555, oldPrice: 6500, votes: 45, discount: 50),
            CatalogModel(id: 26, categoryId: 01010101, name: "Balasko", thumbnail: "pic18", stars: 3, newPrice: 4555, oldPrice: 6500, votes: 45, discount: 50),
            CatalogModel(id: 27, categoryId: 01010101, name: "Baon", thumbnail: "pic10", stars: 3, newPrice: 4555, oldPrice: 6500, votes: 45, discount: 50),
            CatalogModel(id: 28, categoryId: 01010101, name: "Baon", thumbnail: "pic12", stars: 3, newPrice: 4555, oldPrice: 6500, votes: 45, discount: 50),
            CatalogModel(id: 29, categoryId: 01010101, name: "Barboleta", thumbnail: "pic14", stars: 3, newPrice: 4555, oldPrice: 6500, votes: 45, discount: 50),
            CatalogModel(id: 30, categoryId: 01010101, name: "Barcelonica", thumbnail: "pic18", stars: 3, newPrice: 4555, oldPrice: 6500, votes: 45, discount: 50)
            ]
        catalogs[01010102] = w2
        
        
        let w3 = [
            CatalogModel(id: 31, categoryId: 01010101, name: "Barkhat", thumbnail: "pic", stars: 3, newPrice: 4555, oldPrice: 6500, votes: 45, discount: 50),
            CatalogModel(id: 32, categoryId: 01010101, name: "Barkhat", thumbnail: "pic", stars: 3, newPrice: 4555, oldPrice: 6500, votes: 45, discount: 50),
            CatalogModel(id: 33, categoryId: 01010101, name: "Basia", thumbnail: "pic", stars: 3, newPrice: 4555, oldPrice: 6500, votes: 45, discount: 50),
            CatalogModel(id: 34, categoryId: 01010101, name: "C.H.I.C", thumbnail: "pic", stars: 3, newPrice: 4555, oldPrice: 6500, votes: 45, discount: 50),
            CatalogModel(id: 35, categoryId: 01010101, name: "C.H.I.C", thumbnail: "pic", stars: 3, newPrice: 4555, oldPrice: 6500, votes: 45, discount: 50),
            CatalogModel(id: 36, categoryId: 01010101, name: "Calista", thumbnail: "pic", stars: 3, newPrice: 4555, oldPrice: 6500, votes: 45, discount: 50),
            CatalogModel(id: 37, categoryId: 01010101, name: "Calista", thumbnail: "pic", stars: 3, newPrice: 4555, oldPrice: 6500, votes: 45, discount: 50)
            ]
        catalogs[01010103] = w3
        
    }
    
    static func nerworkRequest(baseId: Int)->Observable<[CatalogModel]?> {
        return Observable.just(catalogs[baseId])
    }
    
    
    
    static func localTitle(categoryId: Int)->Observable<String> {
        guard
            let parent = models2[categoryId]
            else { return .empty()}
        
        return Observable.just(parent.title)
    }

}
