import UIKit

class CategoryVC: UITableViewController {
    
    var viewModel: CategoryVM!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        uitCurrMemVCs += 1  // uitest
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bindNavigation()
        setupNavigation()
    }

    
    private func setupNavigation(){
        navigationController?.navigationBar.barTintColor = UIColor.init(displayP3Red: 128/255, green: 0, blue: 96/255, alpha: 1.0)
        navigationController?.navigationBar.tintColor = UIColor.white
        setAttributedTitle()
    }
    
    
    private func setAttributedTitle(){
        var title = viewModel.outTitle.value
        if (title.isEmpty) {
            title = "Каталог"
        }
        let navLabel = UILabel()
        let navTitle = NSMutableAttributedString(string: title, attributes:[
            NSAttributedString.Key.foregroundColor: UIColor.white,
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 17.0, weight: UIFont.Weight.light)])
        
        navLabel.attributedText = navTitle
        self.navigationItem.titleView = navLabel
        
        self.navigationItem.titleView?.accessibilityIdentifier = "My"+String(uitCurrMemVCs)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.outCategories.value?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let title = cell.viewWithTag(1000) as! UILabel
        
        let model =  viewModel.outCategories.value?[indexPath.row]
        guard let category = model else {return cell}
        if category.last == false {
            cell.accessoryType = UITableViewCell.AccessoryType.disclosureIndicator
        }
        title.text = category.title
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let model = viewModel.outCategories.value![indexPath.row]
        viewModel.inSelectCategory.onNext(model.baseId + model.id)
    }
    
    
    deinit {
        uitCurrMemVCs -= 1  // uitest
    }
    
    
    private func bindNavigation() {
        viewModel.outCloseVC
            .take(1)
            .subscribe{[weak self] _ in
                self?.navigationController?.popViewController(animated: true)
            }
            .disposed(by: bag)
    }
    
    override func didMove(toParent parent: UIViewController?) {
        if parent == nil {
            viewModel.backEvent.onNext(.back)
        }
    }
}

