import UIKit


class Formatter {

    static func priceFormat(price: NSNumber, localeIdentifier: String) -> String? {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = NSLocale(localeIdentifier: localeIdentifier) as Locale
        let formatPrice = formatter.string(from: price)
        return formatPrice
    }
    
    
    static func strikePriceFormat(price: NSNumber, localeIdentifier: String) -> NSMutableAttributedString? {
        var res: NSMutableAttributedString?
        let fprice = priceFormat(price: price, localeIdentifier: localeIdentifier)
        
        if let formatPrice = fprice {
            let attributeString =  NSMutableAttributedString(string: formatPrice)
            
            attributeString.addAttribute(NSAttributedString.Key.strikethroughStyle,
                                         value: NSUnderlineStyle.single.rawValue,
                                         range: NSMakeRange(0, attributeString.length))
            res = attributeString
        }
        return res
    }
    
    static func starsFormat(stars: Int, votes: Int) -> NSMutableAttributedString {

        let res = NSMutableAttributedString(
            string: "★ ★ ★ ★ ★ \(votes)",
            attributes: [:])
        
        res.addAttribute(
            NSAttributedString.Key.foregroundColor,
            value: UIColor.orange,
            range: NSRange(
                location:0,
                length:stars*2))
        
        res.addAttribute(
            NSAttributedString.Key.foregroundColor,
            value: UIColor.lightGray,
            range: NSRange(
                location: stars*2,
                length: res.length - stars*2))
        
        return res
    }

}
