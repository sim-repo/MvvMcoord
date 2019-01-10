import UIKit


enum CellState {
    case collapsed
    case expanded
    
    var collapseImage: UIImage {
        switch self {
        case .collapsed:
            return #imageLiteral(resourceName: "expand")
        case .expanded:
            return #imageLiteral(resourceName: "collapse")
        }
    }
}


class FilterCell : UITableViewCell{
    


    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var collapseImageView: UIImageView!
    @IBOutlet weak var filterLabel: UILabel!
    @IBOutlet weak var stackView: UIStackView!
    private let expandedViewIndex: Int = 1

    var state: CellState = .collapsed {
        didSet {
            toggle()
        }
    }
    
    override func awakeFromNib() {
        selectionStyle = .none
        containerView.layer.cornerRadius = 5.0
    }
    
    func configCell(model: FilterModel){
        filterLabel.text = model.title
    }

    
    private func toggle() {
        stackView.arrangedSubviews[expandedViewIndex].isHidden = stateIsCollapsed()
        collapseImageView.image = state.collapseImage
    }
    
    private func stateIsCollapsed() -> Bool {
        return state == .collapsed
    }
}
