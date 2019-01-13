import UIKit
import RxSwift




class BaseVM {
    let bag = DisposeBag()
    
    // MARK: - Proxies
    var backEvent = PublishSubject<Void>()
}
