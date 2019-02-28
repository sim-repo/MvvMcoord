import UIKit


enum CellState {
    case collapsed
    case expanded
}


class FilterCell : UITableViewCell{
    
    var id: Int!

    @IBOutlet weak var priceTitle: UILabel!
    @IBOutlet weak var rangeSlider: RangeSeekSlider!
    @IBOutlet weak var containerView: UIView!
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
        rangeSlider.delegate = self
        setupRangeSlider()
    }


    public func setupRangeSlider(){
        (rangeSlider.minValue,
         rangeSlider.maxValue,
         rangeSlider.selectedMinValue,
         rangeSlider.selectedMaxValue) = viewModel.filterActionDelegate?.getRangePrice() ?? (0,0,0,0)
         priceTitle.text = "\(Int(floor(rangeSlider.selectedMinValue))) - \(Int(floor(rangeSlider.selectedMaxValue)))"
    }
    
    private func toggle() {
        stackView.arrangedSubviews[expandedViewIndex].isHidden = stateIsCollapsed()
    }
    
    private func stateIsCollapsed() -> Bool {
        return state == .collapsed
    }
}



extension FilterCell: RangeSeekSliderDelegate {
    
    func rangeSeekSlider(_ slider: RangeSeekSlider, didChange minValue: CGFloat, maxValue: CGFloat) {
        viewModel.rangePriceChangedNow(minPrice: minValue, maxPrice: maxValue)
    }
    
    func didStartTouches(in slider: RangeSeekSlider) {
    }
    
    func didEndTouches(in slider: RangeSeekSlider) {
        viewModel.rangePriceTouchEnd()
    }
}
