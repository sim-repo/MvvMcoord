import UIKit
import RxSwift

class AppCoord : BaseCoord<CoordRetEnum>{
    private let window: UIWindow
    
    init(window: UIWindow){
        self.window = window
    }
    
    override func start() -> Observable<CoordRetEnum> {
        let rootCoord = RootCoord(window: window, parentBaseId: 00000000)
        return coordinate(coord: rootCoord)
    }
}
