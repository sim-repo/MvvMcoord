import UIKit
import RxSwift


class BaseCoord<ResultType> {
    
    private let id = UUID()
    var viewModel: BaseVM!
    let disposeBag = DisposeBag()
    private var childCoords = [UUID:Any]()
    
    
    private func store<T>(coord: BaseCoord<T>){
        childCoords[coord.id] = coord
    }
    //3 add func to release child-coord
    private func free<T>(coord: BaseCoord<T>){
       
        childCoords[coord.id] = nil
    }
    //4 add func call store funcб and run start-method
    func coordinate<T>(coord: BaseCoord<T>) -> Observable<T> {
        store(coord: coord)
        return coord.start()
            .do(
                onNext:{[weak self] _ in
                    self?.free(coord: coord)
                },
                onCompleted: {
                    self.free(coord: coord)
            }
        )
    }
    
    //5 func start
    func start()->Observable<ResultType> {
        fatalError("start method should be implemented")
    }
}



