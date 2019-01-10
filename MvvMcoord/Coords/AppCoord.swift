import UIKit
import RxSwift

class AppCoord : BaseCoord<Void>{
    private let window: UIWindow
    
    init(window: UIWindow){
        self.window = window
    }
    
    override func start() -> Observable<Void> {
        let rootCoord = RootCoord(window: window, parentBaseId: 00000000)
        return coordinate(coord: rootCoord)
    }
}
