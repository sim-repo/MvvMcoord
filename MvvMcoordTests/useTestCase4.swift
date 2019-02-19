import XCTest
import RxCocoa
import RxSwift
import RxTest

@testable import MvvMcoord

class MyResults {
    public var res: String = ""
}

class useTestCase4: XCTestCase {

    var subFilterVM1: SubFilterVM!
    var subFilterVM2: SubFilterVM!
    var subFilterVM3: SubFilterVM!
    var subFilterVM4: SubFilterVM!
    var subFilterVM5: SubFilterVM!
    
    var categoryVM: CategoryVM!
    //var catalogVM: CatalogVM!
    //var filterVM: FilterVM!
    var bag = DisposeBag()
    
    let categoryId = 01010101
    let materialFilterId = 4
    let colorFilterId = 6
    let seasonFilterId = 3
    let deliveryFilterId = 5
    let sizeFilterId = 2
    
    let polyamide = 49
    let yellow = 63
    let gray = 69
    let black = 72
    let blue = 62
    let green = 64
    let pink = 68
    let violet = 71
    let brown = 65
    let angora = 47
    let red = 66
    let orange = 67
    
    let days5 = 59
    let day1 = 56
    let viscose = 48
    let cotton = 52
    
    let winter = 44
    let summer = 46
    
    let demiseason = 43
    

    
    var categoryVM1: CategoryVM!
    var categoryVM2: CategoryVM!
    var categoryVM3: CategoryVM!
    var categoryVM4: CategoryVM!
    var categoryVM5: CategoryVM!
    
    
    let timeout: Double = 200
    
    override func setUp() {
        CategoryModel.fillModels()
        
        
//        catalogVM = CatalogVM(categoryId: categoryId)
//        catalogVM.utMsgId = 0
//        catalogVM.requestFilters(categoryId: categoryId)
//
//        filterVM = FilterVM(categoryId: categoryId, filterActionDelegate: catalogVM)
    }
    
    override func tearDown() {
        subFilterVM1 = nil
    }
    
    
    func capsule(_ catalogVM: CatalogVM, msgId: Int, completion: @escaping ()->(Void)) {
        catalogVM.unitTestSignalOperationComplete
            .filter({$0 == msgId})
            .take(1)
            .observeOn(MainScheduler.asyncInstance)
            .subscribe(onNext: {_ in
                completion()
            }).disposed(by: bag)
    }
    
    
    
    func refreshSubFilters(_ catalogVM: CatalogVM, filterId: Int, msgId: Int, newMsgId: Int) {
        let completion: (() -> Void) = {
            catalogVM.utMsgId = newMsgId
            catalogVM.utRefreshSubFilters(filterId: filterId)
        }
        capsule(catalogVM, msgId: msgId, completion: completion)
    }
    
    
    func enterSubFilter(_ catalogVM: CatalogVM, filterId: Int, msgId: Int, newMsgId: Int) {
        let completion: (() -> Void) = {
            catalogVM.utMsgId = newMsgId
            catalogVM.utEnterSubFilter(filterId: filterId)
        }
        capsule(catalogVM, msgId: msgId, completion: completion)
    }
    
    
    func selectSubFilters(vm: SubFilterVM, selectIds: [Int], select: Bool){
        for subFilterId in selectIds {
            vm.filterActionDelegate?.selectSubFilterEvent().onNext((subFilterId, select))
        }
    }
    
    
    func selectSubFilters(_ catalogVM: CatalogVM, vm: SubFilterVM, selectIds: [Int], select: Bool, newMsgId: Int){
        for subFilterId in selectIds {
            vm.filterActionDelegate?.selectSubFilterEvent().onNext((subFilterId, select))
        }
        catalogVM.unitTestSignalOperationComplete.onNext(newMsgId)
    }
    
    
    func selectSubFilters(_ catalogVM: CatalogVM, vm: SubFilterVM, selectIds: [Int], select: Bool, msgId: Int, newMsgId: Int){
        let completion: (() -> Void) = {
            catalogVM.utMsgId = msgId
            for subFilterId in selectIds {
                vm.filterActionDelegate?.selectSubFilterEvent().onNext((subFilterId, select))
            }
            catalogVM.unitTestSignalOperationComplete.onNext(newMsgId)
        }
        capsule(catalogVM, msgId: msgId, completion: completion)
    }
    
    
    func applySubFilter(vm: SubFilterVM){
        vm.inApply.onNext(Void())
    }
    
    
    func apply(_ catalogVM: CatalogVM, vm: SubFilterVM, msgId: Int, newMsgId: Int){
        let completion: (() -> Void) = {[weak self]  in
            catalogVM.utMsgId = newMsgId
            self?.applySubFilter(vm: vm)
        }
        capsule(catalogVM, msgId: msgId, completion: completion)
    }
    
    func selectApply(_ catalogVM: CatalogVM, vm: SubFilterVM, selectIds: [Int], msgId: Int){
        catalogVM.utMsgId = msgId
        selectSubFilters(vm: vm, selectIds: selectIds, select: true)
        applySubFilter(vm: vm)
    }
    
    
    func selectApply(_ catalogVM: CatalogVM, vm: SubFilterVM, selectIds: [Int], msgId: Int, newMsgId: Int) {
        let completion: (() -> Void) = {[weak self]  in
            catalogVM.utMsgId = newMsgId
            self?.selectSubFilters(vm: vm, selectIds: selectIds, select: true)
            self?.applySubFilter(vm: vm)
        }
        capsule(catalogVM, msgId: msgId, completion: completion)
    }
    
    
    func removeAppliedFilter(_ catalogVM: CatalogVM, filterVM: FilterVM, filterId: Int, msgId: Int, newMsgId: Int){
        let completion: (() -> Void) = {
            catalogVM.utMsgId = newMsgId
            filterVM.inRemoveFilter.onNext(filterId)
        }
        capsule(catalogVM, msgId: msgId, completion: completion)
    }
    
    func cleanupFromFilter(_ catalogVM: CatalogVM, filterVM: FilterVM, msgId: Int, newMsgId: Int){
        let completion: (() -> Void) = {
            catalogVM.utMsgId = newMsgId
            filterVM.filterActionDelegate?.cleanupFromFilterEvent().onNext(Void())
        }
        capsule(catalogVM, msgId: msgId, completion: completion)
    }
    
    func cleanupFromSubFilter(_ catalogVM: CatalogVM, filterVM: FilterVM, filterId: Int, msgId: Int, newMsgId: Int){
        let completion: (() -> Void) = {
            catalogVM.utMsgId = newMsgId
            filterVM.filterActionDelegate?.cleanupFromSubFilterEvent().onNext(filterId)
        }
        capsule(catalogVM, msgId: msgId, completion: completion)
    }
    
    
    func clearTestCase(){
        subFilterVM1 = nil
        subFilterVM2 = nil
        subFilterVM3 = nil
        subFilterVM4 = nil
        subFilterVM5 = nil
    }
    
    
    
    func applyFromFilter(_ catalogVM: CatalogVM, filterVM: FilterVM, msgId: Int, newMsgId: Int) {
        let completion: (() -> Void) = {
            catalogVM.utMsgId = newMsgId
            filterVM.inApply.onNext(Void())
        }
       capsule(catalogVM, msgId: msgId, completion: completion)
    }
    
    
    func  takeFromFilter(_ catalogVM: CatalogVM, result: MyResults, operationId: Int, msgId: Int, newMsgId: Int){
        let completion: (() -> Void) = {[weak self] in
            catalogVM.filtersEvent()
                .take(1)
                .subscribe(onNext: {sf in
                    result.res += ("\(operationId): ")
                    for element in sf {
                        result.res += (element!.title + " ")
                    }
                    result.res += "\\\\\\"
                    print("take: \(result.res)")
                    catalogVM.unitTestSignalOperationComplete.onNext(newMsgId)
                })
                .disposed(by: self!.bag)
        }
        capsule(catalogVM, msgId: msgId, completion: completion)
    }
    
    
    func takeFromVM(_ catalogVM: CatalogVM, result: MyResults, operationId: Int, vm: SubFilterVM, msgId: Int, newMsgId: Int){
        let completion: (() -> Void) = {[weak self]  in
            vm.filterActionDelegate?.subFiltersEvent()
                .take(1)
                .subscribe(onNext: {sf in
                    
                    result.res += ("\(operationId): ")
                    for element in sf {
                        result.res += (element!.title + " \(vm.isCheckmark(subFilterId: element!.id)) ")
                    }
                    result.res += "\\\\\\"
                    catalogVM.unitTestSignalOperationComplete.onNext(newMsgId)
                    print("take: \(result.res)")
                })
                .disposed(by: self!.bag)
        }
        capsule(catalogVM, msgId: msgId, completion: completion)
    }
    
    
    func takeFilterFinish(_ catalogVM: CatalogVM, result: MyResults, filterVM: FilterVM, msgId: Int, expect: XCTestExpectation){
        let completion: (() -> Void) = {[weak self]  in
            filterVM.filterActionDelegate?.filtersEvent()
                .take(1)
                .subscribe(onNext: {sf in
                    for element in sf {
                        result.res += (element!.title + " ")
                    }
                    expect.fulfill()
                })
                .disposed(by: self!.bag)
        }
        capsule(catalogVM, msgId: msgId, completion: completion)
    }
    
    
    func takeFinish(_ catalogVM: CatalogVM, result: MyResults, vm: SubFilterVM, msgId: Int, expect: XCTestExpectation){
        let completion: (() -> Void) = {[weak self]  in
            vm.filterActionDelegate?.subFiltersEvent()
                .take(1)
                .subscribe(onNext: {sf in
                    print("takeFinish")
                    for element in sf {
                        result.res += (element!.title + " \(vm.isCheckmark(subFilterId: element!.id)) ")
                    }
                    expect.fulfill()
                })
                .disposed(by: self!.bag)
        }
        capsule(catalogVM, msgId: msgId, completion: completion)
    }
    
    
    
    
    func initTestCase0(_ catalogVM: CatalogVM, filterId1: Int, filterId2: Int, filterId3: Int, filterId4: Int, filterId5: Int){
        
        catalogVM.utMsgId = 0
        catalogVM.requestFilters(categoryId: categoryId)
        
        let filterVM = FilterVM(categoryId: categoryId, filterActionDelegate: catalogVM)
        
        subFilterVM1 = SubFilterVM(filterId: filterId1, filterActionDelegate: filterVM.filterActionDelegate)
        subFilterVM2 = SubFilterVM(filterId: filterId2, filterActionDelegate: filterVM.filterActionDelegate)
        subFilterVM3 = SubFilterVM(filterId: filterId3, filterActionDelegate: filterVM.filterActionDelegate)
        subFilterVM4 = SubFilterVM(filterId: filterId4, filterActionDelegate: filterVM.filterActionDelegate)
        subFilterVM5 = SubFilterVM(filterId: filterId5, filterActionDelegate: filterVM.filterActionDelegate)
    }
    
    
    // check accuracy of filter
    func testExample() {
        let expect = expectation(description: #function)
        let catalogVM = CatalogVM(categoryId: categoryId)
        let filterVM = FilterVM(categoryId: categoryId, filterActionDelegate: catalogVM)
        let myResult = MyResults()
        initTestCase0(catalogVM, filterId1: materialFilterId, filterId2: colorFilterId, filterId3: seasonFilterId, filterId4: deliveryFilterId, filterId5: sizeFilterId)
        
        
        // 1 apply pink
        selectApply(catalogVM, vm: subFilterVM2, selectIds: [pink], msgId: 0, newMsgId: 1)
        
        enterSubFilter(catalogVM, filterId: deliveryFilterId, msgId: 1, newMsgId: 2)
        
        // 2 take available subfilters from Delivery Filter
        takeFromVM(catalogVM, result: myResult, operationId:2, vm: subFilterVM4, msgId: 2, newMsgId: 3)
        
        
        
        // 3 apply 5days
        selectApply(catalogVM, vm: subFilterVM4, selectIds: [day1], msgId: 3, newMsgId: 4)
        
        enterSubFilter(catalogVM, filterId: materialFilterId, msgId: 4, newMsgId: 5)
        
        // 4 take available subfilters from Material Filter
        takeFromVM(catalogVM, result: myResult, operationId:3, vm: subFilterVM1, msgId: 5, newMsgId: 6)
        
        
        
        // 5 apply cotton
        selectApply(catalogVM, vm: subFilterVM1, selectIds: [cotton], msgId: 6, newMsgId: 7)
        
        enterSubFilter(catalogVM, filterId: seasonFilterId, msgId: 7, newMsgId: 8)
        
        // 6 take available subfilters from Season Filter
        takeFromVM(catalogVM, result: myResult, operationId:4, vm: subFilterVM3, msgId: 8, newMsgId: 9)
        
        
        
        // 7 apply winter
        selectApply(catalogVM, vm: subFilterVM3, selectIds: [summer], msgId: 9, newMsgId: 10)
        
        enterSubFilter(catalogVM, filterId: sizeFilterId, msgId: 10, newMsgId: 11)
        
        // 8 take available subfilters from Size Filter
        takeFinish(catalogVM, result: myResult, vm: subFilterVM5, msgId: 11, expect: expect )
        
        
        waitForExpectations(timeout: timeout) { [weak self] error in
            guard error == nil else {
                XCTFail(error!.localizedDescription)
                return
            }
            // день false 3 дня false 4 дня false 5 дней false \\\\\\3: хлопок false \\\\\\4: лето false \\\\\\42 false "
            XCTAssertEqual("2: 1 день false \\\\\\3: хлопок false \\\\\\4: лето false \\\\\\42 false ", myResult.res)
        }
        clearTestCase()
    }
    
    func initTestCase1(_ catalogVM: CatalogVM, filterId1: Int, filterId2: Int){
        
        catalogVM.utMsgId = 0
        catalogVM.requestFilters(categoryId: categoryId)
        let filterVM = FilterVM(categoryId: categoryId, filterActionDelegate: catalogVM)
        
        subFilterVM1 = SubFilterVM(filterId: filterId1, filterActionDelegate: filterVM.filterActionDelegate)
        subFilterVM2 = SubFilterVM(filterId: filterId2, filterActionDelegate: filterVM.filterActionDelegate)
    }
    
    
    // check relative applying
    func testExample2() {
        
        let catalogVM = CatalogVM(categoryId: categoryId)
        let myResult = MyResults()
        let expect = expectation(description: #function)
        initTestCase1(catalogVM, filterId1: colorFilterId, filterId2: seasonFilterId)
        
        
        selectApply(catalogVM, vm: subFilterVM1, selectIds: [violet], msgId: 0, newMsgId: 1)
        enterSubFilter(catalogVM, filterId: seasonFilterId, msgId: 1, newMsgId: 2)
        takeFromVM(catalogVM, result: myResult, operationId:1, vm: subFilterVM2, msgId: 2, newMsgId: 3)
        
        
        selectApply(catalogVM, vm: subFilterVM2, selectIds: [demiseason], msgId: 3, newMsgId: 4)
        enterSubFilter(catalogVM, filterId: colorFilterId, msgId: 4, newMsgId: 5)
        takeFromVM(catalogVM, result: myResult, operationId:2, vm: subFilterVM1, msgId: 5, newMsgId: 6)
        
        
        enterSubFilter(catalogVM, filterId: seasonFilterId, msgId: 6, newMsgId: 7)
        takeFinish(catalogVM, result: myResult, vm: subFilterVM2, msgId: 7, expect: expect )
        
        waitForExpectations(timeout: timeout) { [weak self] error in
            guard error == nil else {
                XCTFail(error!.localizedDescription)
                return
            }
            XCTAssertEqual("1: демисезон false круглогодичный false \\\\\\2: желтый false коричневый false красный false оранжевый false фиолетовый true черный false \\\\\\демисезон true круглогодичный false ",  myResult.res)
        }
        clearTestCase()
        
    }
    
    
    // check relative applying
    func testExample3() {
        
        let catalogVM = CatalogVM(categoryId: categoryId)
        let myResult = MyResults()
        let expect = expectation(description: #function)
        initTestCase1(catalogVM, filterId1: colorFilterId, filterId2: seasonFilterId)
        
        // 1 apply violet
        selectApply(catalogVM, vm: subFilterVM1, selectIds: [violet], msgId: 0, newMsgId: 1)
        
        // 2 select
        selectApply(catalogVM, vm: subFilterVM2, selectIds: [demiseason], msgId: 1, newMsgId: 2)
        
        // 3 take available subfilters from Color Filter
        enterSubFilter(catalogVM, filterId: colorFilterId, msgId: 2, newMsgId: 3)
        takeFinish(catalogVM, result: myResult, vm: subFilterVM1, msgId: 3, expect: expect )
        
        waitForExpectations(timeout: timeout) { [weak self] error in
            guard error == nil else {
                XCTFail(error!.localizedDescription)
                return
            }
            XCTAssertEqual("желтый false коричневый false красный false оранжевый false фиолетовый true черный false ",  myResult.res)
        }
        clearTestCase()
    }
    
    
    
    func initTestCase4(_ catalogVM: CatalogVM, filterId1: Int, filterId2: Int){
        
        catalogVM.utMsgId = 0
        catalogVM.requestFilters(categoryId: categoryId)
        let filterVM = FilterVM(categoryId: categoryId, filterActionDelegate: catalogVM)
        
        subFilterVM1 = SubFilterVM(filterId: filterId1, filterActionDelegate: filterVM.filterActionDelegate)
        subFilterVM2 = SubFilterVM(filterId: filterId2, filterActionDelegate: filterVM.filterActionDelegate)
    }
    
    // check entering to subfilter after applying
    func testExample4() {
        
        let catalogVM = CatalogVM(categoryId: categoryId)
        let myResult = MyResults()
        let expect = expectation(description: #function)
        initTestCase4(catalogVM, filterId1: colorFilterId, filterId2: materialFilterId)
        
        selectApply(catalogVM, vm: subFilterVM1, selectIds: [blue], msgId: 0, newMsgId: 1)

        takeFromFilter(catalogVM, result: myResult, operationId: 1, msgId: 1, newMsgId: 2)

        enterSubFilter(catalogVM, filterId: colorFilterId, msgId: 2, newMsgId: 3)
        takeFromVM(catalogVM, result: myResult, operationId:2, vm: subFilterVM1, msgId: 3, newMsgId: 4)


        selectApply(catalogVM, vm: subFilterVM1, selectIds: [yellow], msgId: 4, newMsgId: 5)

        takeFromFilter(catalogVM, result: myResult, operationId: 3, msgId: 5, newMsgId: 6)


        enterSubFilter(catalogVM, filterId: materialFilterId, msgId: 6, newMsgId: 7)
        takeFromVM(catalogVM, result: myResult, operationId:4, vm: subFilterVM2, msgId: 7, newMsgId: 8)

        selectApply(catalogVM, vm: subFilterVM2, selectIds: [viscose], msgId: 8, newMsgId: 9)

        enterSubFilter(catalogVM, filterId: colorFilterId, msgId: 9, newMsgId: 10)
        takeFromVM(catalogVM, result: myResult, operationId:5, vm: subFilterVM1, msgId: 10, newMsgId: 11)
        
        takeFinish(catalogVM, result: myResult, vm: subFilterVM2, msgId: 11, expect: expect )
        
        
        waitForExpectations(timeout: timeout) { [weak self] error in
            guard error == nil else {
                XCTFail(error!.localizedDescription)
                return
            }
            XCTAssertEqual("1: Цвет \\\\\\2: бежевый false белый false голубой true желтый false зеленый false коричневый false красный false оранжевый false розовый false серый false синий false фиолетовый false черный false \\\\\\3: Бренд Размер Сезон Состав Срок доставки Цвет \\\\\\4: вискоза false полиамид false \\\\\\5: желтый true коричневый false \\\\\\желтый true коричневый false ",  myResult.res)
        }
        clearTestCase()
    }
    
    
    // select null-subf and apply from filter
    func testExample5(){
        
        let catalogVM = CatalogVM(categoryId: categoryId)
        let myResult = MyResults()
        let filterVM = FilterVM(categoryId: categoryId, filterActionDelegate: catalogVM)
        let expect = expectation(description: #function)
        initTestCase4(catalogVM, filterId1: colorFilterId, filterId2: materialFilterId)
        
        selectSubFilters(catalogVM, vm: subFilterVM1, selectIds: [blue], select: true, msgId: 0, newMsgId: 1)
        
        applyFromFilter(catalogVM, filterVM:filterVM, msgId: 1, newMsgId: 2)
        
        takeFromFilter(catalogVM, result: myResult, operationId: 1, msgId: 2, newMsgId: 3)
        
        takeFinish(catalogVM, result: myResult, vm: subFilterVM1, msgId: 3, expect: expect )
        
        waitForExpectations(timeout: timeout) { [weak self] error in
            guard error == nil else {
                XCTFail(error!.localizedDescription)
                return
            }
            XCTAssertEqual("1: \\\\\\",  myResult.res)
        }
    }
    
    // select from subfilter and apply from filter, deselect from subfilter and apply from filter again
    func testExample6(){
        
        let catalogVM = CatalogVM(categoryId: categoryId)
        let myResult = MyResults()
        let filterVM = FilterVM(categoryId: categoryId, filterActionDelegate: catalogVM)
        let expect = expectation(description: #function)
        initTestCase4(catalogVM, filterId1: colorFilterId, filterId2: materialFilterId)
        
        selectSubFilters(catalogVM, vm: subFilterVM1, selectIds: [yellow, green], select: true, msgId: 0, newMsgId: 2)
        
        applyFromFilter(catalogVM, filterVM:filterVM, msgId: 2, newMsgId: 3)
        
        takeFromFilter(catalogVM, result: myResult, operationId: 1, msgId: 3, newMsgId: 4)
        
        enterSubFilter(catalogVM, filterId: colorFilterId, msgId: 4, newMsgId: 5)
        
        takeFromVM(catalogVM, result: myResult, operationId:2, vm: subFilterVM1, msgId: 5, newMsgId: 6)
        
        enterSubFilter(catalogVM, filterId: materialFilterId, msgId: 6, newMsgId: 7)
        
        takeFromVM(catalogVM, result: myResult, operationId:3, vm: subFilterVM2, msgId: 7, newMsgId: 8)
        
        selectSubFilters(catalogVM, vm: subFilterVM1, selectIds: [green], select: false, msgId: 8, newMsgId: 9)
        
        applyFromFilter(catalogVM, filterVM:filterVM, msgId: 9, newMsgId: 10)
        
        enterSubFilter(catalogVM, filterId: materialFilterId, msgId: 10, newMsgId: 11)
        
        takeFinish(catalogVM, result: myResult, vm: subFilterVM2, msgId: 11, expect: expect )
        
        waitForExpectations(timeout: timeout) { [weak self] error in
            guard error == nil else {
                XCTFail(error!.localizedDescription)
                return
            }
            XCTAssertEqual("1: Бренд Размер Сезон Состав Срок доставки Цвет \\\\\\2: бежевый false белый false голубой false желтый true зеленый true коричневый false красный false оранжевый false розовый false серый false синий false фиолетовый false черный false \\\\\\3: вискоза false полиамид false хлопок false \\\\\\вискоза false полиамид false ",  myResult.res)

        }
    }
    
    func initTestCase7(_ catalogVM: CatalogVM, filterId1: Int){
        
        catalogVM.utMsgId = 0
        catalogVM.requestFilters(categoryId: categoryId)
        let filterVM = FilterVM(categoryId: categoryId, filterActionDelegate: catalogVM)
        
        
        subFilterVM1 = SubFilterVM(filterId: filterId1, filterActionDelegate: filterVM.filterActionDelegate)
    }
    
    // remove subf from filter
    func testExample7(){
        
        let catalogVM = CatalogVM(categoryId: categoryId)
        let myResult = MyResults()
        let filterVM = FilterVM(categoryId: categoryId, filterActionDelegate: catalogVM)
        let expect = expectation(description: #function)
        
        initTestCase7(catalogVM, filterId1: colorFilterId)
        
        selectSubFilters(catalogVM, vm: subFilterVM1, selectIds: [yellow, green], select: true, msgId: 0, newMsgId: 2)
        
        applyFromFilter(catalogVM, filterVM:filterVM, msgId: 2, newMsgId: 3)
        
        takeFromFilter(catalogVM, result: myResult, operationId: 1, msgId: 3, newMsgId: 4)
        
        removeAppliedFilter(catalogVM, filterVM:filterVM, filterId: colorFilterId, msgId: 4, newMsgId: 5)
        
        takeFilterFinish(catalogVM, result: myResult, filterVM:filterVM, msgId: 5, expect: expect )
        
        waitForExpectations(timeout: timeout) { [weak self] error in
            guard error == nil else {
                XCTFail(error!.localizedDescription)
                return
            }
            XCTAssertEqual("1: Бренд Размер Сезон Состав Срок доставки Цвет \\\\\\Цена Бренд Размер Сезон Состав Срок доставки Цвет Вид застежки Вырез горловины Декоративные элементы Длина юбки/платья Конструктивные элементы Тип рукава Цена2 ",  myResult.res)
        }
    }
    
    // cleanup from filter
    func testExample8(){
        
        let catalogVM = CatalogVM(categoryId: categoryId)
        let myResult = MyResults()
        let filterVM = FilterVM(categoryId: categoryId, filterActionDelegate: catalogVM)
        let expect = expectation(description: #function)
        
        initTestCase4(catalogVM, filterId1: colorFilterId, filterId2: materialFilterId)
        
        selectApply(catalogVM, vm: subFilterVM1, selectIds: [yellow, green], msgId: 0, newMsgId: 1)
        
        takeFromFilter(catalogVM, result: myResult, operationId: 1, msgId: 1, newMsgId: 2)
        
        selectApply(catalogVM, vm: subFilterVM2, selectIds: [viscose, cotton], msgId: 2, newMsgId: 3)
        
        takeFromFilter(catalogVM, result: myResult, operationId: 1, msgId: 3, newMsgId: 4)
        
        cleanupFromFilter(catalogVM, filterVM:filterVM, msgId: 4, newMsgId: 5)
        
        takeFilterFinish(catalogVM, result: myResult, filterVM:filterVM, msgId: 5, expect: expect )
        

        waitForExpectations(timeout: timeout) { [weak self] error in
            guard error == nil else {
                XCTFail(error!.localizedDescription)
                return
            }
            XCTAssertEqual("1: Бренд Размер Сезон Состав Срок доставки Цвет \\\\\\1: Бренд Размер Сезон Состав Срок доставки Цвет \\\\\\Цена Бренд Размер Сезон Состав Срок доставки Цвет Вид застежки Вырез горловины Декоративные элементы Длина юбки/платья Конструктивные элементы Тип рукава Цена2 ", myResult.res)
        }
    }
    
    
    // cleanup from subfilter
    func testExample9(){
        
        let catalogVM = CatalogVM(categoryId: categoryId)
        let myResult = MyResults()
        let filterVM = FilterVM(categoryId: categoryId, filterActionDelegate: catalogVM)
        let expect = expectation(description: #function)
        
        initTestCase7(catalogVM, filterId1: colorFilterId)
        
        selectApply(catalogVM, vm: subFilterVM1, selectIds: [black, yellow, green], msgId: 0, newMsgId: 1)
        
        takeFromFilter(catalogVM, result: myResult, operationId: 1, msgId: 1, newMsgId: 2)
        
        enterSubFilter(catalogVM, filterId: colorFilterId, msgId: 2, newMsgId: 3)
        
        takeFromVM(catalogVM, result: myResult, operationId: 2, vm: subFilterVM1, msgId: 3, newMsgId: 4)
        
        selectSubFilters(catalogVM, vm: subFilterVM1, selectIds: [blue, violet], select: true, msgId: 4, newMsgId: 5)
        
        cleanupFromSubFilter(catalogVM, filterVM:filterVM, filterId: colorFilterId, msgId: 5, newMsgId: 6)
        
        apply(catalogVM, vm: subFilterVM1, msgId: 6, newMsgId: 7)
        
        takeFilterFinish(catalogVM, result: myResult, filterVM:filterVM, msgId: 7, expect: expect )
        
        
        waitForExpectations(timeout: timeout) { [weak self] error in
            guard error == nil else {
                XCTFail(error!.localizedDescription)
                return
            }
            XCTAssertEqual("1: Бренд Размер Сезон Состав Срок доставки Цвет \\\\\\2: бежевый false белый false голубой false желтый true зеленый true коричневый false красный false оранжевый false розовый false серый false синий false фиолетовый false черный true \\\\\\Цена Бренд Размер Сезон Состав Срок доставки Цвет Вид застежки Вырез горловины Декоративные элементы Длина юбки/платья Конструктивные элементы Тип рукава Цена2 ",  myResult.res)
        }
    }
    
    // check repeated applying
    func testExample10(){
        
        let catalogVM = CatalogVM(categoryId: categoryId)
        let myResult = MyResults()
        let filterVM = FilterVM(categoryId: categoryId, filterActionDelegate: catalogVM)
        let expect = expectation(description: #function)
        
        initTestCase7(catalogVM, filterId1: colorFilterId)
        
        selectApply(catalogVM, vm: subFilterVM1, selectIds: [black, yellow, green], msgId: 0, newMsgId: 1)
        
        takeFromFilter(catalogVM, result: myResult, operationId: 1, msgId: 1, newMsgId: 2)
        
        apply(catalogVM, vm: subFilterVM1, msgId: 2, newMsgId: 3)
        
        takeFilterFinish(catalogVM, result: myResult, filterVM:filterVM, msgId: 3, expect: expect )
        
        
        waitForExpectations(timeout: timeout) { [weak self] error in
            guard error == nil else {
                XCTFail(error!.localizedDescription)
                return
            }
            XCTAssertEqual("1: Бренд Размер Сезон Состав Срок доставки Цвет \\\\\\Бренд Размер Сезон Состав Срок доставки Цвет ",  myResult.res)
        }
    }
    
    
    // check relative applying
    func testExample11(){
        
        let catalogVM = CatalogVM(categoryId: categoryId)
        let myResult = MyResults()
        let filterVM = FilterVM(categoryId: categoryId, filterActionDelegate: catalogVM)
        let expect = expectation(description: #function)
        
        initTestCase4(catalogVM, filterId1: colorFilterId, filterId2: materialFilterId)
        
        selectSubFilters(catalogVM, vm: subFilterVM1, selectIds: [green, yellow, brown], select: true, msgId: 0, newMsgId: 1)
        
        selectSubFilters(catalogVM, vm: subFilterVM2, selectIds: [cotton], select: true, msgId: 1, newMsgId: 2)
        
        applyFromFilter(catalogVM, filterVM:filterVM, msgId: 2, newMsgId: 3)
        
        takeFromFilter(catalogVM, result: myResult, operationId: 1, msgId: 3, newMsgId: 4)
        
        
        
        
        enterSubFilter(catalogVM, filterId: colorFilterId, msgId: 4, newMsgId: 5)
        
        takeFromVM(catalogVM, result: myResult, operationId: 2, vm: subFilterVM1, msgId: 5, newMsgId: 6)
        
        enterSubFilter(catalogVM, filterId: materialFilterId, msgId: 6, newMsgId: 7)
        
        takeFinish(catalogVM, result: myResult, vm: subFilterVM2, msgId: 7, expect: expect)
        
        waitForExpectations(timeout: timeout) { [weak self] error in
            guard error == nil else {
                XCTFail(error!.localizedDescription)
                return
            }
            XCTAssertEqual("1: Бренд Размер Сезон Состав Срок доставки Цвет \\\\\\2: зеленый true розовый false черный false \\\\\\вискоза false полиамид false хлопок true эластан false ",  myResult.res)
        }
    }
    

    
    // check mutual exclusion
    func testExample12(){
        
        let catalogVM = CatalogVM(categoryId: categoryId)
        let myResult = MyResults()
        let filterVM = FilterVM(categoryId: categoryId, filterActionDelegate: catalogVM)
        let expect = expectation(description: #function)
        
        initTestCase4(catalogVM, filterId1: colorFilterId, filterId2: materialFilterId)
        
        selectSubFilters(catalogVM, vm: subFilterVM1, selectIds: [green, yellow, brown], select: true, msgId: 0, newMsgId: 1)
        
        selectSubFilters(catalogVM, vm: subFilterVM2, selectIds: [angora], select: true, msgId: 1, newMsgId: 2)
        
        applyFromFilter(catalogVM, filterVM:filterVM, msgId: 2, newMsgId: 3)
        
        takeFilterFinish(catalogVM, result: myResult, filterVM:filterVM, msgId: 3, expect: expect )
        
        waitForExpectations(timeout: timeout) { [weak self] error in
            guard error == nil else {
                XCTFail(error!.localizedDescription)
                return
            }
            XCTAssertEqual("",  myResult.res)
        }
    }
    
    
    // cleanup mutual exclusion
    func testExample13(){
        
        let catalogVM = CatalogVM(categoryId: categoryId)
        let myResult = MyResults()
        let filterVM = FilterVM(categoryId: categoryId, filterActionDelegate: catalogVM)
        let expect = expectation(description: #function)
        
        initTestCase4(catalogVM, filterId1: colorFilterId, filterId2: materialFilterId)
        
        selectSubFilters(catalogVM, vm: subFilterVM1, selectIds: [green, yellow, brown], select: true, msgId: 0, newMsgId: 1)
        
        selectSubFilters(catalogVM, vm: subFilterVM2, selectIds: [angora], select: true, msgId: 1, newMsgId: 2)
        
        applyFromFilter(catalogVM, filterVM:filterVM, msgId: 2, newMsgId: 3)
        
        cleanupFromFilter(catalogVM, filterVM:filterVM, msgId: 3, newMsgId: 4)
        
        takeFilterFinish(catalogVM, result: myResult, filterVM:filterVM, msgId: 4, expect: expect )
        
        waitForExpectations(timeout: timeout) { [weak self] error in
            guard error == nil else {
                XCTFail(error!.localizedDescription)
                return
            }
            XCTAssertEqual("Цена Бренд Размер Сезон Состав Срок доставки Цвет Вид застежки Вырез горловины Декоративные элементы Длина юбки/платья Конструктивные элементы Тип рукава Цена2 ",  myResult.res)
        }
    }
    
    
    // apply from subf, new select and apply again from subf
    func testExample14(){
        
        let catalogVM = CatalogVM(categoryId: categoryId)
        let myResult = MyResults()
        let filterVM = FilterVM(categoryId: categoryId, filterActionDelegate: catalogVM)
        let expect = expectation(description: #function)
        
        initTestCase4(catalogVM, filterId1: colorFilterId, filterId2: materialFilterId)
        
        selectSubFilters(catalogVM, vm: subFilterVM1, selectIds: [green, yellow, brown], select: true, msgId: 0, newMsgId: 1)
        
        apply(catalogVM, vm: subFilterVM1, msgId: 1, newMsgId: 2)
        
        enterSubFilter(catalogVM, filterId: materialFilterId, msgId: 2, newMsgId: 3)
        
        takeFromVM(catalogVM, result: myResult, operationId: 1, vm: subFilterVM2, msgId: 3, newMsgId: 4)
        
        selectSubFilters(catalogVM, vm: subFilterVM1, selectIds: [red, orange], select: true, msgId: 4, newMsgId: 5)
        
        apply(catalogVM, vm: subFilterVM1, msgId: 5, newMsgId: 6)
        
        enterSubFilter(catalogVM, filterId: materialFilterId, msgId: 6, newMsgId: 7)
        
        takeFinish(catalogVM, result: myResult, vm: subFilterVM2, msgId: 7, expect: expect)
        
        waitForExpectations(timeout: timeout) { [weak self] error in
            guard error == nil else {
                XCTFail(error!.localizedDescription)
                return
            }
            XCTAssertEqual("1: вискоза false полиамид false хлопок false эластан false \\\\\\вискоза false полиамид false полиэстер false хлопок false шерсть false эластан false ",  myResult.res )
        }
    }
    
}
