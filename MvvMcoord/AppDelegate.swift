import UIKit
import RxSwift


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    private var appCoordinator: AppCoord!
    private let disposeBag = DisposeBag()
    var navigationController: UINavigationController?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        
        CategoryModel.fillModels()
        CatalogModel.fillModels()
        FilterModel.fillModels()
        SubfilterModel.fillModels()
        
        window = UIWindow()
        if let window = window {
            let mainVC = ViewController()
            navigationController = UINavigationController(rootViewController: mainVC)
            window.rootViewController = navigationController
        }
        
        appCoordinator = AppCoord(window: window!)
        appCoordinator.start()
            .subscribe()
            .disposed(by: disposeBag)
        
        return true
    }

}

