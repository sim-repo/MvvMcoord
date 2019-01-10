import UIKit
import RxSwift


class BaseVM {
    let bag = DisposeBag()
    // MARK: - Inputs from ViewController
    var inBackEvent = PublishSubject<Void>()
    
    // MARK: - Outputs to ViewController or Coord
    var outBackEvent = PublishSubject<Void>()
    
    
    init(){
        inBackEvent
            .subscribe(onCompleted: {
                self.outBackEvent.onCompleted()
            })
            .disposed(by: bag)
    }
    
}
