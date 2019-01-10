import Foundation
import RxSwift
import RxCocoa

enum CellLayoutEnum {
    case list, square, squares
}

struct CellLayout {
    var cellLayoutType: CellLayoutEnum
    var cellScale: CGSize
    var cellSpace: CGFloat
    var lineSpace: CGFloat
    var layoutImageName: String
}

class CatalogVM : BaseVM {
    
    private var currCellLayout: CellLayoutEnum = .list
    private var categoryId: Int
    
    // MARK: - Inputs from ViewController
    var inPressLayout:Variable<Void> = Variable<Void>(Void())
    var inPressFilter:Variable<Void> = Variable<Void>(Void())
    
    // MARK: - Outputs to ViewController or Coord
    var outCatalog = Variable<[CatalogModel]?>(nil)
    var outTitle = Variable<String>("")
    var outLayout = Variable<CellLayout?>(nil)
    var outShowFilters = PublishSubject<Int>()

    
    init(categoryId: Int = 0){
        
        self.categoryId = categoryId
        super.init()
        
        //network request
        let catalog = CatalogModel.nerworkRequest(baseId: categoryId)
        
        
        catalog
            .bind(to: outCatalog)
            .disposed(by: bag)
        
        CatalogModel.localTitle(categoryId: categoryId)
            .bind(to: outTitle)
            .disposed(by: bag)
        
        inPressLayout
            .asObservable()
            .flatMap{[weak self]  _ -> Observable<CellLayout> in
                return self!.changeLayout()
            }
            .bind(to: outLayout)
            .disposed(by: bag)
        
        inPressFilter
            .asObservable()
            .map{[weak self] _ -> Int in
                return self!.categoryId
            }
            .bind(to: outShowFilters)
            .disposed(by: bag)
        
    }
    
    
    
    // MARK: - Logic
    private func changeLayout()->Observable<CellLayout>{
        
        switch currCellLayout {
        case .list:
            currCellLayout = .square
            return Observable.of(CellLayout(cellLayoutType: .square, cellScale: CGSize(width: 1, height: 0.95), cellSpace: 0, lineSpace: 8, layoutImageName: "square"))
        case .square:
            currCellLayout = .squares
            return Observable.of(CellLayout(cellLayoutType: .squares, cellScale: CGSize(width: 0.5, height: 0.5), cellSpace: 2, lineSpace: 2, layoutImageName: "squares"))
        case .squares:
            currCellLayout = .list
            return Observable.of(CellLayout(cellLayoutType: .list, cellScale: CGSize(width: 0.95, height: 0.25), cellSpace: 0, lineSpace: 8, layoutImageName: "list"))
        }
    }
    
}
