import UIKit
import RxSwift


enum CoordRetEnum: String {
    case back, reloadData
}

class BaseVM {
    let bag = DisposeBag()
    
    // MARK: - Proxies
    var backEvent = PublishSubject<CoordRetEnum>()
}
