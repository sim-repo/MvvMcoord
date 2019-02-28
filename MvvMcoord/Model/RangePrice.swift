import UIKit


class RangePrice {
    var original = false
    var initialMinPrice: CGFloat = 0
    var initialMaxPrice: CGFloat = 0
    var userMinPrice: CGFloat = 0
    var userMaxPrice: CGFloat = 0
    var tipMinPrice: CGFloat = 0
    var tipMaxPrice: CGFloat = 0
    
    private init(original: Bool){
        self.original = original
    }
    
    public static var shared = RangePrice(original: true)
    
    public func clone() -> RangePrice {
        let newRangePrice = RangePrice(original: false)
        newRangePrice.setupRangePrice(rangePrice: self)
        return newRangePrice
    }
    
    public func setupRangePrice(minPrice: CGFloat, maxPrice: CGFloat){
        self.initialMinPrice = minPrice
        self.initialMaxPrice = maxPrice
        self.userMinPrice = minPrice
        self.userMaxPrice = maxPrice
        self.tipMinPrice = minPrice
        self.tipMaxPrice = maxPrice
    }
    
    private func setupRangePrice(rangePrice: RangePrice){
        self.initialMinPrice = rangePrice.initialMinPrice
        self.initialMaxPrice = rangePrice.initialMaxPrice
        self.userMinPrice = rangePrice.userMinPrice
        self.userMaxPrice = rangePrice.userMaxPrice
        self.tipMinPrice = rangePrice.tipMinPrice
        self.tipMaxPrice = rangePrice.tipMaxPrice
    }
    
    public func getRangePrice()-> (CGFloat, CGFloat, CGFloat, CGFloat) {
        let leftLimit = tipMinPrice
        let rightLimit = tipMaxPrice
        let curUserMinPrice = tipMinPrice < userMinPrice ? userMinPrice : tipMinPrice
        let curUserMazPrice = tipMaxPrice < userMaxPrice ? tipMaxPrice : userMaxPrice
        return (leftLimit, rightLimit, curUserMinPrice, curUserMazPrice)
    }
    
    public func setTipRangePrice(minPrice: CGFloat, maxPrice: CGFloat) {
        guard minPrice > 0 && maxPrice > 0 else { return }
        self.tipMinPrice = minPrice
        self.tipMaxPrice = maxPrice
    }
    
    public func setUserRangePrice(minPrice: CGFloat, maxPrice: CGFloat) {
        guard minPrice > 0 && maxPrice > 0 else { return }
        self.userMinPrice = minPrice
        self.userMaxPrice = maxPrice
    }
    
    public func isUserChangedPriceFilter() -> Bool {
        return userMinPrice != initialMinPrice ||
            userMaxPrice != initialMaxPrice
    }
    
    public func getPricesWhenApplyFilter() -> RangePrice {
        return getPricesWnenUserChanged()
    }
    
    public func getPricesWhenApplySubFilter() -> RangePrice {
        return getPricesWnenUserChanged()
    }
    
    public func getPricesWhenApplyByPrices() -> RangePrice {
        return self
    }
    
    public func getPricesWhenRemoveFilter() -> RangePrice {
        return getPricesWnenUserChanged()
    }
    
    public func getPricesWhenRequestSubFilters() -> RangePrice {
        return getPricesWnenUserChanged()
    }
    
    private func getPricesWnenUserChanged() -> RangePrice {
        let tmpRangePrice = self.clone()
        
        if isUserChangedPriceFilter() {
            tmpRangePrice.setUserRangePrice(minPrice: userMinPrice, maxPrice: userMaxPrice)
        } else {
            tmpRangePrice.setUserRangePrice(minPrice: 0, maxPrice: 0)
        }
        return tmpRangePrice
    }
    
}
