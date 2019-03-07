import UIKit
import RxSwift


enum CoordRetEnum: String {
    case back, reloadData
}

enum FilterActionEnum {
    case prefetchCatalog, enterFilter, applyFilter, removeFilter, closeFilter, enterSubFilter, applySubFilter, closeSubFilter, noAction
}

enum BackEnum {
    case fromFilter, fromSubFilter
}

class BaseVM {
    let bag = DisposeBag()
    
    // MARK: - Proxies
    var backEvent = PublishSubject<CoordRetEnum>()
}
