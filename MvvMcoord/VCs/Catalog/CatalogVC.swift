import UIKit
import RxCocoa
import RxSwift

class CatalogVC: UIViewController {
    
    var viewModel: CatalogVM!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var planButton: UIButton!
    @IBOutlet weak var filterButton: UIButton!
    
    
    
    var bag = DisposeBag()
    var collectionDisposable: Disposable?
    
    var cellLayout: CellLayoutEnum = .list
    var cellHeight: CGFloat = 100.0
    var cellWidth: CGFloat = 100.0
    var cellSpace: CGFloat = 0.0
    var lineSpace: CGFloat = 0.0
    var planButtonImage = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setFlowLayout()
        setTitle()
        registerCollectionView()
        bindingLayout()
    }
    
    deinit {
        print("deinit CatalogVC")
    }
    
    private func setFlowLayout(){
        if let collectionViewFlowLayout = collectionView?.collectionViewLayout as? UICollectionViewFlowLayout {
            collectionViewFlowLayout.minimumInteritemSpacing = 0
        }
    }
    
    
    private func setTitle(){
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
    }
    
    private func bindingCell(){
        self.collectionDisposable?.dispose()
        
        switch cellLayout {
        case .list:
            collectionDisposable =  dataSource()
                .bind(to: collectionView.rx.items(cellIdentifier: "CatalogCellList", cellType:  CatalogListCell.self)) {row, model, cell in
                    cell.configCell(model: model)
            }
            
        case .square:
            collectionDisposable =  dataSource()
                .bind(to: collectionView.rx.items(cellIdentifier: "CatalogCellSquare", cellType:  CatalogSquareCell.self)) {row, model, cell in
                    cell.configCell(model: model)
            }
            
        case .squares:
            collectionDisposable =  dataSource()
                .bind(to: collectionView.rx.items(cellIdentifier: "CatalogCellSquares", cellType:  CatalogSquaresCell.self)) {row, model, cell in
                    cell.configCell(model: model)
            }
        }
        
        self.collectionView.reloadData()
    }
    
    private func registerCollectionView(){
        collectionView.rx.setDelegate(self)
            .disposed(by: bag)
    }
    
    
    private func dataSource()->Observable<[CatalogModel]> {
        return viewModel.outCatalog.asObservable()
            .map{catalog in
                return catalog ?? []
        }
    }
    
    private func bindingLayout(){
        planButton.rx.tap
            .bind{[weak self] _ -> Void in
                self?.viewModel.inPressLayout.value = Void()}
            .disposed(by: bag)
        
        
        filterButton.rx.tap
            .bind{[weak self] _ -> Void in
                self?.viewModel.inPressFilter.value = Void()}
            .disposed(by: bag)
        
        
        viewModel.outLayout
            .asObservable()
            .subscribe(onNext: {[weak self] cellLayout in
                guard let layout = cellLayout else { return }
                guard let `self` = self else {return}
                
                self.cellHeight = layout.cellScale.height  *  self.collectionView.frame.height
                self.cellWidth = layout.cellScale.width *  self.collectionView.frame.width - layout.cellSpace
                self.planButton.setImage(UIImage(named: layout.layoutImageName), for: .normal)
                self.cellLayout = layout.cellLayoutType
                self.bindingCell()
                
            })
            .disposed(by: bag)
    }
}


extension CatalogVC: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: cellWidth, height: cellHeight)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        return sectionInset
    }
    
    override func didMove(toParent parent: UIViewController?) {
        if parent == nil {
            viewModel.backEvent.onNext(.back)
        }
    }
    
}

