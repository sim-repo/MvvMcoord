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
    
    var id: Int!

    @IBOutlet weak var rangeSlider: RangeSeekSlider!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var collapseImageView: UIImageView!
    @IBOutlet weak var filterLabel: UILabel!
    @IBOutlet weak var stackView: UIStackView!
    private let expandedViewIndex: Int = 1
    var viewModel: FilterVM!
    
    
    var state: CellState = .collapsed {
        didSet {
            toggle()
        }
    }
    
    override func awakeFromNib() {
        selectionStyle = .none
        containerView.layer.cornerRadius = 5.0
    }
    
    public func configCell(model: FilterModel, viewModel: FilterVM){
        id = model.id
        self.viewModel = viewModel
        filterLabel.text = model.title
        setupRangeSlider()
    }

    
    private func setupRangeSlider(){
        rangeSlider.delegate = self
        (rangeSlider.minValue,
         rangeSlider.maxValue,
         rangeSlider.selectedMinValue,
         rangeSlider.selectedMaxValue) = viewModel.filterActionDelegate?.getPriceRange() ?? (0,0,0,0)
    }
    
    private func toggle() {
        stackView.arrangedSubviews[expandedViewIndex].isHidden = stateIsCollapsed()
        collapseImageView.image = state.collapseImage
    }
    
    private func stateIsCollapsed() -> Bool {
        return state == .collapsed
    }
}



extension FilterCell: RangeSeekSliderDelegate {
    
    func rangeSeekSlider(_ slider: RangeSeekSlider, didChange minValue: CGFloat, maxValue: CGFloat) {
        viewModel.setTmpRangePrice(minPrice: minValue, maxPrice: maxValue)
    }
    
    
    func didStartTouches(in slider: RangeSeekSlider) {
        print("did start touches")
    }
    
    func didEndTouches(in slider: RangeSeekSlider) {
        print("did end touches")
    }
}
