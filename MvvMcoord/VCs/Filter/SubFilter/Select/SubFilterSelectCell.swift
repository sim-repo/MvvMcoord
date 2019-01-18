import UIKit



class SubFilterSelectCell : UITableViewCell{
    var id: Int!
    @IBOutlet weak var subFilterLabel: UILabel!
    
    
    func configCell(model: SubfilterModel, isCheckmark: Bool){
        id = model.id
        subFilterLabel.text = model.title
        self.accessoryType = isCheckmark ? .checkmark : .none
    }
    
    func selectedCell() -> Bool{
        let checkmarked = self.accessoryType == .checkmark ? false : true
        self.accessoryType = checkmarked ? .checkmark : .none
        return checkmarked
    }
}
