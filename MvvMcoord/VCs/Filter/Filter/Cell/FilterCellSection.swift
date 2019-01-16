import UIKit



class FilterCellSection : UITableViewCell{
    var id: Int!
    @IBOutlet weak var filterLabel: UILabel!
    
    func configCell(model: FilterModel){
        id = model.id
        filterLabel.text = model.title
    }
}
