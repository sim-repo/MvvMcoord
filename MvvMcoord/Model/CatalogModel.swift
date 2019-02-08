import Foundation
import RxSwift

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

    
    static func localTitle(categoryId: Int)->Observable<String> {
        guard
            let parent = models2[categoryId]
            else { return .empty()}
        
        return Observable.just(parent.title)
    }

}
