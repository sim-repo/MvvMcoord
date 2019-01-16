import UIKit



class SubFilterSelectCell : UITableViewCell{
    var id: Int!
    @IBOutlet weak var subFilterLabel: UILabel!
    
    func configCell(model: SubfilterModel){
        id = model.id
        subFilterLabel.text = model.title
        self.accessoryType = SubfilterModel.localSelectedSubFilter(subFilterId: id) ? .checkmark : .none
    }
    
    func selectedCell() -> Bool{
        let checkmarked = self.accessoryType == .checkmark ? false : true
        self.accessoryType = checkmarked ? .checkmark : .none
        return checkmarked
    }
}
