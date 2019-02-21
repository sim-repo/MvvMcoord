import UIKit



class SubFilterSectionCell : UITableViewCell{
    var id: Int!
    @IBOutlet weak var subFilterLabel: UILabel!
    
    func configCell(model: SubfilterModel, isCheckmark: Bool){
        id = model.id
        
        var cnt = ""
        if model.countItems > 0 {
            cnt = " (\(model.countItems))"
        }
        subFilterLabel.text = model.title + cnt
        self.accessoryType = isCheckmark ? .checkmark : .none
    }
    
    func selectedCell() -> Bool{
        let checkmarked = self.accessoryType == .checkmark ? false : true
        self.accessoryType = checkmarked ? .checkmark : .none
        return checkmarked
    }
    
    func selectCell() {
        let checkmarked = self.accessoryType == .checkmark ? false : true
        self.accessoryType = checkmarked ? .checkmark : .none
    }
}
