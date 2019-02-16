import UIKit

class CatalogSquareCell : UICollectionViewCell{
    
    @IBOutlet weak var cartButton: UIButton!
    @IBOutlet weak var favouriteButton: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var discountView: DiscountLabel!
    @IBOutlet weak var itemNameLabel: UILabel!
    @IBOutlet weak var oldPriceLabel: UILabel!
    @IBOutlet weak var newPriceLabel: UILabel!
    @IBOutlet weak var starsLabel: UILabel!
    
    
    func configCell(model: CatalogModel?){
        guard let `model` = model else {return}
        
        imageView.image = UIImage(named: model.thumbnail)
        discountView.label?.text = "    -" + String(model.discount) + "%"
        itemNameLabel.text = model.name
        newPriceLabel.text = model.newPrice
        oldPriceLabel.attributedText = model.oldPrice
        starsLabel.attributedText = model.stars
    }
    
}
