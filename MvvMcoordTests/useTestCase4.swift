import XCTest
import RxCocoa
import RxSwift
import RxTest

@testable import MvvMcoord

class useTestCase4: XCTestCase {

    var subFilterVM1: SubFilterVM!
    var subFilterVM2: SubFilterVM!
    var subFilterVM3: SubFilterVM!
    var subFilterVM4: SubFilterVM!
    var subFilterVM5: SubFilterVM!
    
    var categoryVM: CategoryVM!
    var catalogVM: CatalogVM!
    var filterVM: FilterVM!
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
    
    var result = ""
    
    var categoryVM1: CategoryVM!
    var categoryVM2: CategoryVM!
    var categoryVM3: CategoryVM!
    var categoryVM4: CategoryVM!
    var categoryVM5: CategoryVM!
    
    override func setUp() {
        CategoryModel.fillModels()
        CatalogModel.fillModels()
        catalogVM = CatalogVM(categoryId: categoryId)
        catalogVM.requestFilters(categoryId: categoryId)
        
        filterVM = FilterVM(categoryId: categoryId, filterActionDelegate: catalogVM)
    }
    
    override func tearDown() {
        subFilterVM1 = nil
    }
    
    
    func capsule(msgId: Int, completion: @escaping ()->(Void)) {
        catalogVM.unitTestSignalOperationComplete
            .filter({$0 == msgId})
            .take(1)
            .observeOn(MainScheduler.asyncInstance)
            .subscribe(onNext: {_ in
                completion()
            }).disposed(by: bag)
    }
    
    
    
    func refreshSubFilters(filterId: Int, msgId: Int, newMsgId: Int) {
        let completion: (() -> Void) = {[weak self]  in
            print("refresh")
            self?.catalogVM.utMsgId = newMsgId
            self?.catalogVM.utRefreshSubFilters(filterId: filterId)
        }
        capsule(msgId: msgId, completion: completion)
    }
    
    
    func enterSubFilter(filterId: Int, msgId: Int, newMsgId: Int) {
        let completion: (() -> Void) = {[weak self]  in
            print("enter")
            self?.catalogVM.utMsgId = newMsgId
            self?.catalogVM.utEnterSubFilter(filterId: filterId)
        }
        capsule(msgId: msgId, completion: completion)
    }
    
    
    func selectSubFilters(vm: SubFilterVM, selectIds: [Int], select: Bool){
        for subFilterId in selectIds {
            vm.filterActionDelegate?.selectSubFilterEvent().onNext((subFilterId, select))
        }
    }
    
    
    func selectSubFilters(vm: SubFilterVM, selectIds: [Int], select: Bool, newMsgId: Int){
        for subFilterId in selectIds {
            vm.filterActionDelegate?.selectSubFilterEvent().onNext((subFilterId, select))
        }
        catalogVM.unitTestSignalOperationComplete.onNext(newMsgId)
    }
    
    
    func selectSubFilters(vm: SubFilterVM, selectIds: [Int], select: Bool, msgId: Int, newMsgId: Int){
        let completion: (() -> Void) = {[weak self]  in
            self?.catalogVM.utMsgId = msgId
            for subFilterId in selectIds {
                vm.filterActionDelegate?.selectSubFilterEvent().onNext((subFilterId, select))
            }
            self?.catalogVM.unitTestSignalOperationComplete.onNext(newMsgId)
        }
        capsule(msgId: msgId, completion: completion)
    }
    
    
    func applySubFilter(vm: SubFilterVM){
        vm.inApply.onNext(Void())
    }
    
    
    func apply(vm: SubFilterVM, msgId: Int, newMsgId: Int){
        let completion: (() -> Void) = {[weak self]  in
            self?.catalogVM.utMsgId = newMsgId
            self?.applySubFilter(vm: vm)
        }
        capsule(msgId: msgId, completion: completion)
    }
    
    func selectApply(vm: SubFilterVM, selectIds: [Int], msgId: Int){
        catalogVM.utMsgId = msgId
        selectSubFilters(vm: vm, selectIds: selectIds, select: true)
        applySubFilter(vm: vm)
    }
    
    
    func selectApply(vm: SubFilterVM, selectIds: [Int], msgId: Int, newMsgId: Int) {
        let completion: (() -> Void) = {[weak self]  in
            self?.catalogVM.utMsgId = newMsgId
            self?.selectSubFilters(vm: vm, selectIds: selectIds, select: true)
            self?.applySubFilter(vm: vm)
        }
        capsule(msgId: msgId, completion: completion)
    }
    
    
    func removeAppliedFilter(filterId: Int, msgId: Int, newMsgId: Int){
        let completion: (() -> Void) = {[weak self]  in
            self?.catalogVM.utMsgId = newMsgId
            self?.filterVM.inRemoveFilter.onNext(filterId)
        }
        capsule(msgId: msgId, completion: completion)
    }
    
    func cleanupFromFilter(msgId: Int, newMsgId: Int){
        let completion: (() -> Void) = {[weak self]  in
            self?.catalogVM.utMsgId = newMsgId
            self?.filterVM.filterActionDelegate?.cleanupFromFilterEvent().onNext(Void())
        }
        capsule(msgId: msgId, completion: completion)
    }
    
    func cleanupFromSubFilter(filterId: Int, msgId: Int, newMsgId: Int){
        let completion: (() -> Void) = {[weak self]  in
            self?.catalogVM.utMsgId = newMsgId
            self?.filterVM.filterActionDelegate?.cleanupFromSubFilterEvent().onNext(filterId)
        }
        capsule(msgId: msgId, completion: completion)
    }
    
    
    func clearTestCase(){
        subFilterVM1 = nil
        subFilterVM2 = nil
        subFilterVM3 = nil
        subFilterVM4 = nil
        subFilterVM5 = nil
    }
    
    
    
    func applyFromFilter(msgId: Int, newMsgId: Int) {
        let completion: (() -> Void) = {[weak self]  in
            self?.catalogVM.utMsgId = newMsgId
            self?.filterVM.inApply.onNext(Void())
        }
       capsule(msgId: msgId, completion: completion)
    }
    
    
    func takeFromFilter(operationId: Int, msgId: Int, newMsgId: Int){
        let completion: (() -> Void) = {[weak self]  in
            self?.catalogVM.filtersEvent()
                .take(1)
                .subscribe(onNext: {[weak self] sf in
                    self?.result += ("\(operationId): ")
                    for element in sf {
                        self?.result += (element!.title + " ")
                    }
                    self?.result += "\\\\\\"
                    print("take: \(self!.result)")
                    self?.catalogVM.unitTestSignalOperationComplete.onNext(newMsgId)
                })
                .disposed(by: self!.bag)
        }
        capsule(msgId: msgId, completion: completion)
    }
    
    
    func takeFromVM(operationId: Int, vm: SubFilterVM, msgId: Int, newMsgId: Int){
        let completion: (() -> Void) = {[weak self]  in
            vm.filterActionDelegate?.subFiltersEvent()
                .take(1)
                .subscribe(onNext: {[weak self] sf in
                    
                    self?.result += ("\(operationId): ")
                    for element in sf {
                        self?.result += (element!.title + " \(vm.isCheckmark(subFilterId: element!.id)) ")
                    }
                    self?.result += "\\\\\\"
                    self?.catalogVM.unitTestSignalOperationComplete.onNext(newMsgId)
                    print("take: \(self!.result)")
                })
                .disposed(by: self!.bag)
        }
        capsule(msgId: msgId, completion: completion)
    }
    
    
    func takeFilterFinish(msgId: Int, expect: XCTestExpectation){
        let completion: (() -> Void) = {[weak self]  in
            self?.filterVM.filterActionDelegate?.filtersEvent()
                .take(1)
                .subscribe(onNext: {[weak self] sf in
                    for element in sf {
                        self?.result += (element!.title + " ")
                    }
                    expect.fulfill()
                })
                .disposed(by: self!.bag)
        }
        capsule(msgId: msgId, completion: completion)
    }
    
    
    func takeFinish(vm: SubFilterVM, msgId: Int, expect: XCTestExpectation){
        let completion: (() -> Void) = {[weak self]  in
            vm.filterActionDelegate?.subFiltersEvent()
                .take(1)
                .subscribe(onNext: {[weak self] sf in
                    for element in sf {
                        self?.result += (element!.title + " \(vm.isCheckmark(subFilterId: element!.id)) ")
                    }
                    expect.fulfill()
                })
                .disposed(by: self!.bag)
        }
        capsule(msgId: msgId, completion: completion)
    }
    
    
    func initTestCase0(filterId1: Int, filterId2: Int, filterId3: Int, filterId4: Int, filterId5: Int){
        subFilterVM1 = SubFilterVM(filterId: filterId1, filterActionDelegate: filterVM.filterActionDelegate)
        subFilterVM2 = SubFilterVM(filterId: filterId2, filterActionDelegate: filterVM.filterActionDelegate)
        subFilterVM3 = SubFilterVM(filterId: filterId3, filterActionDelegate: filterVM.filterActionDelegate)
        subFilterVM4 = SubFilterVM(filterId: filterId4, filterActionDelegate: filterVM.filterActionDelegate)
        subFilterVM5 = SubFilterVM(filterId: filterId5, filterActionDelegate: filterVM.filterActionDelegate)
        
        result = ""
    }
    
    
    // check accuracy of filter
    func testExample() {
        let expect = expectation(description: #function)
        initTestCase0(filterId1: materialFilterId, filterId2: colorFilterId, filterId3: seasonFilterId, filterId4: deliveryFilterId, filterId5: sizeFilterId)
        
        
        // 1 apply pink
        selectApply(vm: subFilterVM2, selectIds: [pink], msgId: 1)
        
        refreshSubFilters(filterId: deliveryFilterId, msgId: 1, newMsgId: 2)
        
        // 2 take available subfilters from Delivery Filter
        takeFromVM(operationId:2, vm: subFilterVM4, msgId: 2, newMsgId: 3)
        
        
        
        // 3 apply 5days
        selectApply(vm: subFilterVM4, selectIds: [day1], msgId: 3, newMsgId: 4)
        
        refreshSubFilters(filterId: materialFilterId, msgId: 4, newMsgId: 5)
        
        // 4 take available subfilters from Material Filter
        takeFromVM(operationId:3, vm: subFilterVM1, msgId: 5, newMsgId: 6)
        
        
        
        // 5 apply cotton
        selectApply(vm: subFilterVM1, selectIds: [cotton], msgId: 6, newMsgId: 7)
        
        refreshSubFilters(filterId: seasonFilterId, msgId: 7, newMsgId: 8)
        
        // 6 take available subfilters from Season Filter
        takeFromVM(operationId:4, vm: subFilterVM3, msgId: 8, newMsgId: 9)
        
        
        
        // 7 apply winter
        selectApply(vm: subFilterVM3, selectIds: [summer], msgId: 9, newMsgId: 10)
        
        refreshSubFilters(filterId: sizeFilterId, msgId: 10, newMsgId: 11)
        //
        // 8 take available subfilters from Size Filter
        takeFinish(vm: subFilterVM5, msgId: 11, expect: expect )
        
        
        waitForExpectations(timeout: 20.0) { [weak self] error in
            guard error == nil else {
                XCTFail(error!.localizedDescription)
                return
            }
            XCTAssertEqual("2: 1 день false \\\\\\3: хлопок false \\\\\\4: лето false \\\\\\42 false ", self?.result)
        }
        clearTestCase()
    }
    
    func initTestCase1(filterId1: Int, filterId2: Int){
        subFilterVM1 = SubFilterVM(filterId: filterId1, filterActionDelegate: filterVM.filterActionDelegate)
        subFilterVM2 = SubFilterVM(filterId: filterId2, filterActionDelegate: filterVM.filterActionDelegate)
        result = ""
    }
    
    
    // check relative applying
    func testExample2() {
        
        let expect = expectation(description: #function)
        initTestCase1(filterId1: colorFilterId, filterId2: seasonFilterId)
        
        
        selectApply(vm: subFilterVM1, selectIds: [violet], msgId: 1)
        refreshSubFilters(filterId: seasonFilterId, msgId: 1, newMsgId: 2)
        takeFromVM(operationId:1, vm: subFilterVM2, msgId: 2, newMsgId: 3)
        
        
        selectApply(vm: subFilterVM2, selectIds: [demiseason], msgId: 3, newMsgId: 4)
        enterSubFilter(filterId: colorFilterId, msgId: 4, newMsgId: 5)
        takeFromVM(operationId:2, vm: subFilterVM1, msgId: 5, newMsgId: 6)
        
        
        enterSubFilter(filterId: seasonFilterId, msgId: 6, newMsgId: 7)
        takeFinish(vm: subFilterVM2, msgId: 7, expect: expect )
        
        waitForExpectations(timeout: 60.0) { [weak self] error in
            guard error == nil else {
                XCTFail(error!.localizedDescription)
                return
            }
            XCTAssertEqual("1: демисезон false круглогодичный false \\\\\\2: желтый false коричневый false красный false оранжевый false фиолетовый true черный false \\\\\\демисезон true круглогодичный false ", self?.result)
        }
        clearTestCase()
        
    }
    
    
    // check relative applying
    func testExample3() {
        
        let expect = expectation(description: #function)
        initTestCase1(filterId1: colorFilterId, filterId2: seasonFilterId)
        
        // 1 apply violet
        selectApply(vm: subFilterVM1, selectIds: [violet], msgId: 1)
        
        // 2 select
        selectApply(vm: subFilterVM2, selectIds: [demiseason], msgId: 1, newMsgId: 2)
        
        // 3 take available subfilters from Color Filter
        enterSubFilter(filterId: colorFilterId, msgId: 2, newMsgId: 3)
        takeFinish(vm: subFilterVM1, msgId: 3, expect: expect )
        
        waitForExpectations(timeout: 20.0) { [weak self] error in
            guard error == nil else {
                XCTFail(error!.localizedDescription)
                return
            }
            XCTAssertEqual("желтый false коричневый false красный false оранжевый false фиолетовый true черный false ", self?.result)
        }
        clearTestCase()
    }
    
    
    
    func initTestCase4(filterId1: Int, filterId2: Int){
        subFilterVM1 = SubFilterVM(filterId: filterId1, filterActionDelegate: filterVM.filterActionDelegate)
        subFilterVM2 = SubFilterVM(filterId: filterId2, filterActionDelegate: filterVM.filterActionDelegate)
        result = ""
    }
    
    // check entering to subfilter after applying
    func testExample4() {
        
        let expect = expectation(description: #function)
        initTestCase4(filterId1: colorFilterId, filterId2: materialFilterId)
        

        selectApply(vm: subFilterVM1, selectIds: [blue], msgId: 1)
        
        takeFromFilter(operationId: 1, msgId: 1, newMsgId: 2)
        
        enterSubFilter(filterId: colorFilterId, msgId: 2, newMsgId: 3)
        takeFromVM(operationId:2, vm: subFilterVM1, msgId: 3, newMsgId: 4)
        
        
        selectApply(vm: subFilterVM1, selectIds: [yellow], msgId: 4, newMsgId: 5)
        
        takeFromFilter(operationId: 3, msgId: 5, newMsgId: 6)
        
        
        enterSubFilter(filterId: materialFilterId, msgId: 6, newMsgId: 7)
        takeFromVM(operationId:4, vm: subFilterVM2, msgId: 7, newMsgId: 8)
        
        selectApply(vm: subFilterVM2, selectIds: [viscose], msgId: 8, newMsgId: 9)

        enterSubFilter(filterId: colorFilterId, msgId: 9, newMsgId: 10)
        takeFromVM(operationId:5, vm: subFilterVM1, msgId: 10, newMsgId: 11)
        
        takeFinish(vm: subFilterVM2, msgId: 11, expect: expect )
        
        
        waitForExpectations(timeout: 20.0) { [weak self] error in
            guard error == nil else {
                XCTFail(error!.localizedDescription)
                return
            }
            XCTAssertEqual("1: Цвет \\\\\\2: бежевый false белый false голубой true желтый false зеленый false коричневый false красный false оранжевый false розовый false серый false синий false фиолетовый false черный false \\\\\\3: Бренд Размер Сезон Состав Срок доставки Цвет \\\\\\4: вискоза false полиамид false \\\\\\5: желтый true коричневый false \\\\\\желтый true коричневый false ", self?.result)
        }
        clearTestCase()
    }
    
    
    // select null-subf and apply from filter
    func testExample5(){
        
        let expect = expectation(description: #function)
        initTestCase4(filterId1: colorFilterId, filterId2: materialFilterId)
        
        selectSubFilters(vm: subFilterVM1, selectIds: [blue], select: true, newMsgId: 2)
        
        applyFromFilter(msgId: 2, newMsgId: 3)
        
        takeFromFilter(operationId: 1, msgId: 3, newMsgId: 4)
        
        takeFinish(vm: subFilterVM1, msgId: 4, expect: expect )
        
        waitForExpectations(timeout: 20.0) { [weak self] error in
            guard error == nil else {
                XCTFail(error!.localizedDescription)
                return
            }
            XCTAssertEqual("1: \\\\\\", self?.result)
        }
    }
    
    // select from subfilter and apply from filter, deselect from subfilter and apply from filter again
    func testExample6(){
        
        let expect = expectation(description: #function)
        initTestCase4(filterId1: colorFilterId, filterId2: materialFilterId)
        
        selectSubFilters(vm: subFilterVM1, selectIds: [yellow, green], select: true, newMsgId: 2)
        
        applyFromFilter(msgId: 2, newMsgId: 3)
        
        takeFromFilter(operationId: 1, msgId: 3, newMsgId: 4)
        
        enterSubFilter(filterId: colorFilterId, msgId: 4, newMsgId: 5)
        
        takeFromVM(operationId:2, vm: subFilterVM1, msgId: 5, newMsgId: 6)
        
        enterSubFilter(filterId: materialFilterId, msgId: 6, newMsgId: 7)
        
        takeFromVM(operationId:3, vm: subFilterVM2, msgId: 7, newMsgId: 8)
        
        selectSubFilters(vm: subFilterVM1, selectIds: [green], select: false, msgId: 8, newMsgId: 9)
        
        applyFromFilter(msgId: 9, newMsgId: 10)
        
        enterSubFilter(filterId: materialFilterId, msgId: 10, newMsgId: 11)
        
        takeFinish(vm: subFilterVM2, msgId: 11, expect: expect )
        
        waitForExpectations(timeout: 20.0) { [weak self] error in
            guard error == nil else {
                XCTFail(error!.localizedDescription)
                return
            }
            XCTAssertEqual("1: Бренд Размер Сезон Состав Срок доставки Цвет \\\\\\2: бежевый false белый false голубой false желтый true зеленый true коричневый false красный false оранжевый false розовый false серый false синий false фиолетовый false черный false \\\\\\3: вискоза false полиамид false хлопок false \\\\\\вискоза false полиамид false ", self?.result)
        }
    }
    
    func initTestCase7(filterId1: Int){
        subFilterVM1 = SubFilterVM(filterId: filterId1, filterActionDelegate: filterVM.filterActionDelegate)
        result = ""
    }
    
    // remove subf from filter
    func testExample7(){
        let expect = expectation(description: #function)
        
        initTestCase7(filterId1: colorFilterId)
        
        selectSubFilters(vm: subFilterVM1, selectIds: [yellow, green], select: true, newMsgId: 2)
        
        applyFromFilter(msgId: 2, newMsgId: 3)
        
        takeFromFilter(operationId: 1, msgId: 3, newMsgId: 4)
        
        removeAppliedFilter(filterId: colorFilterId, msgId: 4, newMsgId: 5)
        
        takeFilterFinish(msgId: 5, expect: expect )
        
        waitForExpectations(timeout: 20.0) { [weak self] error in
            guard error == nil else {
                XCTFail(error!.localizedDescription)
                return
            }
            XCTAssertEqual("1: Бренд Размер Сезон Состав Срок доставки Цвет \\\\\\Цена Бренд Размер Сезон Состав Срок доставки Цвет Вид застежки Вырез горловины Декоративные элементы Длина юбки/платья Конструктивные элементы Тип рукава ", self?.result)
        }
    }
    
    // cleanup from filter
    func testExample8(){
        let expect = expectation(description: #function)
        
        initTestCase4(filterId1: colorFilterId, filterId2: materialFilterId)
        
        selectApply(vm: subFilterVM1, selectIds: [yellow, green], msgId: 1)
        
        takeFromFilter(operationId: 1, msgId: 1, newMsgId: 2)
        
        selectApply(vm: subFilterVM2, selectIds: [viscose, cotton], msgId: 2, newMsgId: 3)
        
        takeFromFilter(operationId: 1, msgId: 3, newMsgId: 4)
        
        cleanupFromFilter(msgId: 4, newMsgId: 5)
        
        takeFilterFinish(msgId: 5, expect: expect )
        

        waitForExpectations(timeout: 20.0) { [weak self] error in
            guard error == nil else {
                XCTFail(error!.localizedDescription)
                return
            }
            XCTAssertEqual("1: Бренд Размер Сезон Состав Срок доставки Цвет \\\\\\1: Бренд Размер Сезон Состав Срок доставки Цвет \\\\\\Цена Бренд Размер Сезон Состав Срок доставки Цвет Вид застежки Вырез горловины Декоративные элементы Длина юбки/платья Конструктивные элементы Тип рукава ", self?.result)
        }
    }
    
    
    // cleanup from subfilter
    func testExample9(){
        let expect = expectation(description: #function)
        
        initTestCase7(filterId1: colorFilterId)
        
        selectApply(vm: subFilterVM1, selectIds: [black, yellow, green], msgId: 1)
        
        takeFromFilter(operationId: 1, msgId: 1, newMsgId: 2)
        
        enterSubFilter(filterId: colorFilterId, msgId: 2, newMsgId: 3)
        
        takeFromVM(operationId: 2, vm: subFilterVM1, msgId: 3, newMsgId: 4)
        
        selectSubFilters(vm: subFilterVM1, selectIds: [blue, violet], select: true, msgId: 4, newMsgId: 5)
        
        cleanupFromSubFilter(filterId: colorFilterId, msgId: 5, newMsgId: 6)
        
        apply(vm: subFilterVM1, msgId: 6, newMsgId: 7)
        
        takeFilterFinish(msgId: 7, expect: expect )
        
        
        waitForExpectations(timeout: 20.0) { [weak self] error in
            guard error == nil else {
                XCTFail(error!.localizedDescription)
                return
            }
            XCTAssertEqual("1: Бренд Размер Сезон Состав Срок доставки Цвет \\\\\\2: бежевый false белый false голубой false желтый true зеленый true коричневый false красный false оранжевый false розовый false серый false синий false фиолетовый false черный true \\\\\\Цена Бренд Размер Сезон Состав Срок доставки Цвет Вид застежки Вырез горловины Декоративные элементы Длина юбки/платья Конструктивные элементы Тип рукава ", self?.result)
        }
    }
    
    // check repeated applying
    func testExample10(){
        let expect = expectation(description: #function)
        
        initTestCase7(filterId1: colorFilterId)
        
        selectApply(vm: subFilterVM1, selectIds: [black, yellow, green], msgId: 1)
        
        takeFromFilter(operationId: 1, msgId: 1, newMsgId: 2)
        
        apply(vm: subFilterVM1, msgId: 2, newMsgId: 3)
        
        takeFilterFinish(msgId: 3, expect: expect )
        
        
        waitForExpectations(timeout: 20.0) { [weak self] error in
            guard error == nil else {
                XCTFail(error!.localizedDescription)
                return
            }
            XCTAssertEqual("1: Бренд Размер Сезон Состав Срок доставки Цвет \\\\\\Бренд Размер Сезон Состав Срок доставки Цвет ", self?.result)
        }
    }
    
    
    // check relative applying
    func testExample11(){
        let expect = expectation(description: #function)
        
        initTestCase4(filterId1: colorFilterId, filterId2: materialFilterId)
        
        selectSubFilters(vm: subFilterVM1, selectIds: [green, yellow, brown], select: true, newMsgId: 1)
        
        selectSubFilters(vm: subFilterVM2, selectIds: [cotton], select: true, msgId: 1, newMsgId: 2)
        
        applyFromFilter(msgId: 2, newMsgId: 3)
        
        takeFromFilter(operationId: 1, msgId: 3, newMsgId: 4)
        
        enterSubFilter(filterId: colorFilterId, msgId: 4, newMsgId: 5)
        
        takeFromVM(operationId: 2, vm: subFilterVM1, msgId: 5, newMsgId: 6)
        
        enterSubFilter(filterId: materialFilterId, msgId: 6, newMsgId: 7)
        
        takeFinish(vm: subFilterVM2, msgId: 7, expect: expect)
        
        waitForExpectations(timeout: 20.0) { [weak self] error in
            guard error == nil else {
                XCTFail(error!.localizedDescription)
                return
            }
            XCTAssertEqual("1: Бренд Размер Сезон Состав Срок доставки Цвет \\\\\\2: зеленый true розовый false черный false \\\\\\вискоза false полиамид false хлопок true эластан false ", self?.result)
        }
    }
    
    
    // check mutual exclusion
    func testExample12(){
        let expect = expectation(description: #function)
        
        initTestCase4(filterId1: colorFilterId, filterId2: materialFilterId)
        
        selectSubFilters(vm: subFilterVM1, selectIds: [green, yellow, brown], select: true, newMsgId: 1)
        
        selectSubFilters(vm: subFilterVM2, selectIds: [angora], select: true, msgId: 1, newMsgId: 2)
        
        applyFromFilter(msgId: 2, newMsgId: 3)
        
        takeFilterFinish(msgId: 3, expect: expect )
        
        waitForExpectations(timeout: 20.0) { [weak self] error in
            guard error == nil else {
                XCTFail(error!.localizedDescription)
                return
            }
            XCTAssertEqual("", self?.result)
        }
    }
    
    
    // cleanup mutual exclusion
    func testExample13(){
        let expect = expectation(description: #function)
        
        initTestCase4(filterId1: colorFilterId, filterId2: materialFilterId)
        
        selectSubFilters(vm: subFilterVM1, selectIds: [green, yellow, brown], select: true, newMsgId: 1)
        
        selectSubFilters(vm: subFilterVM2, selectIds: [angora], select: true, msgId: 1, newMsgId: 2)
        
        applyFromFilter(msgId: 2, newMsgId: 3)
        
        cleanupFromFilter(msgId: 3, newMsgId: 4)
        
        takeFilterFinish(msgId: 4, expect: expect )
        
        waitForExpectations(timeout: 20.0) { [weak self] error in
            guard error == nil else {
                XCTFail(error!.localizedDescription)
                return
            }
            XCTAssertEqual("Цена Бренд Размер Сезон Состав Срок доставки Цвет Вид застежки Вырез горловины Декоративные элементы Длина юбки/платья Конструктивные элементы Тип рукава ", self?.result)
        }
    }
    
    
    // apply from subf, new select and apply again from subf
    func testExample14(){
        let expect = expectation(description: #function)
        
        initTestCase4(filterId1: colorFilterId, filterId2: materialFilterId)
        
        selectSubFilters(vm: subFilterVM1, selectIds: [green, yellow, brown], select: true, newMsgId: 1)
        
        apply(vm: subFilterVM1, msgId: 1, newMsgId: 2)
        
        enterSubFilter(filterId: materialFilterId, msgId: 2, newMsgId: 3)
        
        takeFromVM(operationId: 1, vm: subFilterVM2, msgId: 3, newMsgId: 4)
        
        selectSubFilters(vm: subFilterVM1, selectIds: [red, orange], select: true, msgId: 4, newMsgId: 5)
        
        apply(vm: subFilterVM1, msgId: 5, newMsgId: 6)
        
        enterSubFilter(filterId: materialFilterId, msgId: 6, newMsgId: 7)
        
        takeFinish(vm: subFilterVM2, msgId: 7, expect: expect)
        
        waitForExpectations(timeout: 20.0) { [weak self] error in
            guard error == nil else {
                XCTFail(error!.localizedDescription)
                return
            }
            XCTAssertEqual("1: вискоза false полиамид false хлопок false эластан false \\\\\\вискоза false полиамид false полиэстер false хлопок false шерсть false эластан false ", self?.result)
        }
    }
    
}
