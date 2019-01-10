import UIKit



class FilterCellSelect : UITableViewCell{
    
    @IBOutlet weak var filterLabel: UILabel!
    
    func configCell(model: FilterModel){
        filterLabel.text = model.title
    }
}
