import UIKit


class DiscountLabel : UIView {
    
    var label: UILabel? = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 21))

    
    override init(frame: CGRect) {
        super .init(frame: frame)
        self.layer.masksToBounds = true
        self.clipsToBounds = true
        self.setLabel()
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        super .init(coder: aDecoder)
        self.clipsToBounds = true
        self.backgroundColor = UIColor.clear
        self.setLabel()
    }
    
    
    private func setLabel() {
        
        label = UILabel(frame: CGRect(x: 0, y: 0, width: self.frame.size.width*2, height: self.frame.size.width/2.5))
        
        label!.center = CGPoint(x: self.frame.width/4.5, y: self.frame.height/2)
        label!.textAlignment = .center
        label!.backgroundColor = UIColor.init(displayP3Red: 244/255, green: 66/255, blue: 131/255, alpha: 1.0)
        label!.text = "  -30%"
        label!.font = UIFont.systemFont(ofSize: 12.0)
        label?.textColor = UIColor.white
        label!.transform = CGAffineTransform(rotationAngle: -CGFloat.pi / 4)
        self.addSubview(label!)
    }
}
