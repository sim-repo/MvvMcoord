import UIKit
import RxCocoa
import RxSwift


class FilterCellSelect : UITableViewCell{
    var id: Int!
    let bag = DisposeBag()
    @IBOutlet weak var filterLabel: UILabel!
    @IBOutlet weak var conCenterY: NSLayoutConstraint!
    
    private var subFiltersLabel : UILabel?
    private var removeSubFiltersButton : UIButton?
    private weak var tableView: UITableView?
    private weak var parent: FilterVC?
    
    
    
    private func initSubFiltersControls(){
        subFiltersLabel = {
            let label = UILabel()
            label.text = "test"
            label.translatesAutoresizingMaskIntoConstraints = false // enable auto-layout
            label.textAlignment = .left
            label.font = UIFont(name: "System", size: 10)
            label.textColor = UIColor.lightGray
            return label
        }()
        
        removeSubFiltersButton = {
            let button = UIButton(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
            button.setTitle("✖︎", for: .normal)
            button.setTitleColor(UIColor.white, for: .normal)
            button.backgroundColor = UIColor.init(displayP3Red: 210/255, green: 210/255, blue: 210/255, alpha: 1.0)
            button.translatesAutoresizingMaskIntoConstraints = false // enable auto-layout
            return button
        }()
    }
    
    private func removeSubFiltersEvent(){
        let marginGuide = contentView.layoutMarginsGuide
        
        conCenterY.constant = 0
        
        NSLayoutConstraint.deactivate([
            subFiltersLabel!.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.95),
            subFiltersLabel!.leadingAnchor.constraint(equalTo: filterLabel.leadingAnchor),
            subFiltersLabel!.topAnchor.constraint(equalTo: filterLabel.bottomAnchor, constant: 1.0),
            subFiltersLabel!.bottomAnchor.constraint(equalTo: marginGuide.bottomAnchor)
            ])
        
        NSLayoutConstraint.deactivate([
            removeSubFiltersButton!.widthAnchor.constraint(equalToConstant: 40),
            removeSubFiltersButton!.heightAnchor.constraint(equalToConstant: 40),
            removeSubFiltersButton!.trailingAnchor.constraint(equalTo: marginGuide.trailingAnchor),
            removeSubFiltersButton!.centerYAnchor.constraint(equalTo: marginGuide.centerYAnchor)
            ])
        subFiltersLabel?.removeFromSuperview()
        removeSubFiltersButton?.removeFromSuperview()
        
        subFiltersLabel = nil
        removeSubFiltersButton = nil
        
        self.tableView?.beginUpdates()
        self.tableView?.endUpdates()
        
        parent?.removeFilterEvent
        .asObserver()
        .onNext(id)
    }
    
    
    private func addLabel(title: String) {
        
        guard subFiltersLabel == nil
            else {
                subFiltersLabel?.text = title
                return
            }
        
        initSubFiltersControls()
        conCenterY.constant = -10.0
       
        
        guard let `subFiltersLabel` = subFiltersLabel,
            let `removeSubFiltersButton` = removeSubFiltersButton
        else {return}
        
        let marginGuide = contentView.layoutMarginsGuide
        subFiltersLabel.text = title
        //subFiltersLabel.numberOfLines = 0
        contentView.addSubview(subFiltersLabel)
        contentView.addSubview(removeSubFiltersButton)
        
        
        NSLayoutConstraint.activate([
            subFiltersLabel.leadingAnchor.constraint(equalTo: filterLabel.leadingAnchor),
            subFiltersLabel.trailingAnchor.constraint(equalTo: removeSubFiltersButton.leadingAnchor),
            subFiltersLabel.topAnchor.constraint(equalTo: filterLabel.bottomAnchor, constant: 1.0),
            subFiltersLabel.bottomAnchor.constraint(equalTo: marginGuide.bottomAnchor)
            ])
        NSLayoutConstraint.activate([
            removeSubFiltersButton.widthAnchor.constraint(equalToConstant: 40),
            removeSubFiltersButton.heightAnchor.constraint(equalToConstant: 40),
            removeSubFiltersButton.trailingAnchor.constraint(equalTo: marginGuide.trailingAnchor),
            removeSubFiltersButton.centerYAnchor.constraint(equalTo: marginGuide.centerYAnchor)
            ])
        
        
        removeSubFiltersButton.rx.tap
            .subscribe( onNext: {[weak self] _ in
                self?.removeSubFiltersEvent()
            })
            .disposed(by: bag)
    }
    
    
    func configCell(model: FilterModel, appliedTitles: String, tableView: UITableView, parent: FilterVC){
        id = model.id
        filterLabel.text = model.title
        self.tableView = tableView
        self.parent = parent
        if appliedTitles != "" {
            addLabel(title: appliedTitles)
        }
    }

}
