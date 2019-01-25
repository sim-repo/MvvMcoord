import UIKit



class SubFilterSectionCell : UITableViewCell{
    
    @IBOutlet weak var subFilterLabel: UILabel!
    
    func configCell(model: SubfilterModel, isCheckmark: Bool){
        subFilterLabel.text = model.title
        self.accessoryType = isCheckmark ? .checkmark : .none
    }
    
    func selectedCell() -> Bool{
        let checkmarked = self.accessoryType == .checkmark ? false : true
        self.accessoryType = checkmarked ? .checkmark : .none
        return checkmarked
    }
}
