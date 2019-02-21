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
    
    
    var bag = DisposeBag()
    
    
    var categoryVM: CategoryVM!
    
    
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
    
    let timeout: Double = 300
    
    override func setUp() {
        CategoryModel.fillModels()
    }
    
    override func tearDown() {
    }
    
    
    func clearTestCase(){
        subFilterVM1 = nil
        subFilterVM2 = nil
        subFilterVM3 = nil
        subFilterVM4 = nil
        subFilterVM5 = nil
    }
    
    func takeFilterFinish(ut: FilterUnitTest, filterVM: FilterVM, msgId: Int, expect: XCTestExpectation){
        let completion: (() -> Void) = {[weak self]  in
            filterVM.filterActionDelegate?.filtersEvent()
                .take(1)
                .subscribe(onNext: {sf in
                    for element in sf {
                        ut.result.res += (element!.title + " ")
                    }
                    expect.fulfill()
                })
                .disposed(by: self!.bag)
        }
        ut.capsule(msgId: msgId, completion: completion)
    }
    
    
    func takeFinish(ut: FilterUnitTest, vm: SubFilterVM, msgId: Int, expect: XCTestExpectation){
        let completion: (() -> Void) = {[weak self]  in
            vm.filterActionDelegate?.subFiltersEvent()
                .take(1)
                .subscribe(onNext: {sf in
                    print("takeFinish")
                    for element in sf {
                        ut.result.res += (element!.title + " \(vm.isCheckmark(subFilterId: element!.id)) ")
                    }
                    expect.fulfill()
                })
                .disposed(by: self!.bag)
        }
        ut.capsule(msgId: msgId, completion: completion)
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
        let myResult = MyResults()
        let ut = FilterUnitTest(catalogVM: catalogVM, result: myResult)
        initTestCase0(catalogVM, filterId1: materialFilterId, filterId2: colorFilterId, filterId3: seasonFilterId, filterId4: deliveryFilterId, filterId5: sizeFilterId)
        
        ut.selectApply(vm: subFilterVM2, selectIds: [pink], msgId: 0, newMsgId: 1)
        
        ut.enterSubFilter(filterId: deliveryFilterId, msgId: 1, newMsgId: 2)

        ut.takeFromVM(operationId:2, vm: subFilterVM4, msgId: 2, newMsgId: 3)
        
        ut.selectApply(vm: subFilterVM4, selectIds: [day1], msgId: 3, newMsgId: 4)
        
        ut.enterSubFilter(filterId: materialFilterId, msgId: 4, newMsgId: 5)
        
        ut.takeFromVM(operationId:3, vm: subFilterVM1, msgId: 5, newMsgId: 6)
        
        ut.selectApply(vm: subFilterVM1, selectIds: [cotton], msgId: 6, newMsgId: 7)
        
        ut.enterSubFilter(filterId: seasonFilterId, msgId: 7, newMsgId: 8)
        
        ut.takeFromVM(operationId:4, vm: subFilterVM3, msgId: 8, newMsgId: 9)
        
        ut.selectApply(vm: subFilterVM3, selectIds: [summer], msgId: 9, newMsgId: 10)
        
        ut.enterSubFilter(filterId: sizeFilterId, msgId: 10, newMsgId: 11)
        
        takeFinish(ut: ut, vm: subFilterVM5, msgId: 11, expect: expect )
        
        
        waitForExpectations(timeout: timeout) {error in
            guard error == nil else {
                XCTFail(error!.localizedDescription)
                return
            }
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
        let ut = FilterUnitTest(catalogVM: catalogVM, result: myResult)
        let expect = expectation(description: #function)
        initTestCase1(catalogVM, filterId1: colorFilterId, filterId2: seasonFilterId)
        
        
        ut.selectApply(vm: subFilterVM1, selectIds: [violet], msgId: 0, newMsgId: 1)
        ut.enterSubFilter(filterId: seasonFilterId, msgId: 1, newMsgId: 2)
        ut.takeFromVM(operationId:1, vm: subFilterVM2, msgId: 2, newMsgId: 3)
        
        
        ut.selectApply(vm: subFilterVM2, selectIds: [demiseason], msgId: 3, newMsgId: 4)
        ut.enterSubFilter(filterId: colorFilterId, msgId: 4, newMsgId: 5)
        ut.takeFromVM(operationId:2, vm: subFilterVM1, msgId: 5, newMsgId: 6)
        
        ut.enterSubFilter(filterId: seasonFilterId, msgId: 6, newMsgId: 7)
        takeFinish(ut: ut, vm: subFilterVM2, msgId: 7, expect: expect )
        
        waitForExpectations(timeout: timeout) { error in
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
        let ut = FilterUnitTest(catalogVM: catalogVM, result: myResult)
        let expect = expectation(description: #function)
        initTestCase1(catalogVM, filterId1: colorFilterId, filterId2: seasonFilterId)
        
        // 1 apply violet
        ut.selectApply(vm: subFilterVM1, selectIds: [violet], msgId: 0, newMsgId: 1)
        
        // 2 select
        ut.selectApply(vm: subFilterVM2, selectIds: [demiseason], msgId: 1, newMsgId: 2)
        
        // 3 take available subfilters from Color Filter
        ut.enterSubFilter(filterId: colorFilterId, msgId: 2, newMsgId: 3)
        takeFinish(ut: ut, vm: subFilterVM1, msgId: 3, expect: expect )
        
        waitForExpectations(timeout: timeout) { error in
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
        let ut = FilterUnitTest(catalogVM: catalogVM, result: myResult)
        let expect = expectation(description: #function)
        initTestCase4(catalogVM, filterId1: colorFilterId, filterId2: materialFilterId)
        
        ut.selectApply(vm: subFilterVM1, selectIds: [blue], msgId: 0, newMsgId: 1)

        ut.takeFromFilter(operationId: 1, msgId: 1, newMsgId: 2)

        ut.enterSubFilter(filterId: colorFilterId, msgId: 2, newMsgId: 3)
        ut.takeFromVM(operationId:2, vm: subFilterVM1, msgId: 3, newMsgId: 4)


        ut.selectApply(vm: subFilterVM1, selectIds: [yellow], msgId: 4, newMsgId: 5)

        ut.takeFromFilter(operationId: 3, msgId: 5, newMsgId: 6)

        ut.enterSubFilter(filterId: materialFilterId, msgId: 6, newMsgId: 7)
        ut.takeFromVM(operationId:4, vm: subFilterVM2, msgId: 7, newMsgId: 8)

        ut.selectApply(vm: subFilterVM2, selectIds: [viscose], msgId: 8, newMsgId: 9)

        ut.enterSubFilter(filterId: colorFilterId, msgId: 9, newMsgId: 10)
        ut.takeFromVM(operationId:5, vm: subFilterVM1, msgId: 10, newMsgId: 11)
        
        takeFinish(ut: ut, vm: subFilterVM2, msgId: 11, expect: expect )
        
        waitForExpectations(timeout: timeout) { error in
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
        let ut = FilterUnitTest(catalogVM: catalogVM, result: myResult)
        let filterVM = FilterVM(categoryId: categoryId, filterActionDelegate: catalogVM)
        let expect = expectation(description: #function)
        initTestCase4(catalogVM, filterId1: colorFilterId, filterId2: materialFilterId)
        
        ut.selectSubFilters(vm: subFilterVM1, selectIds: [blue], select: true, msgId: 0, newMsgId: 1)
        
        ut.applyFromFilter(filterVM: filterVM, msgId: 1, newMsgId: 2)
        
        ut.takeFromFilter(operationId: 1, msgId: 2, newMsgId: 3)
        
        takeFinish(ut: ut, vm: subFilterVM1, msgId: 3, expect: expect )
        
        waitForExpectations(timeout: timeout) { error in
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
        let ut = FilterUnitTest(catalogVM: catalogVM, result: myResult)
        let filterVM = FilterVM(categoryId: categoryId, filterActionDelegate: catalogVM)
        let expect = expectation(description: #function)
        initTestCase4(catalogVM, filterId1: colorFilterId, filterId2: materialFilterId)
        
        ut.selectSubFilters(vm: subFilterVM1, selectIds: [yellow, green], select: true, msgId: 0, newMsgId: 2)
        
        ut.applyFromFilter(filterVM:filterVM, msgId: 2, newMsgId: 3)
        
        ut.takeFromFilter(operationId: 1, msgId: 3, newMsgId: 4)
        
        ut.enterSubFilter(filterId: colorFilterId, msgId: 4, newMsgId: 5)
        
        ut.takeFromVM(operationId:2, vm: subFilterVM1, msgId: 5, newMsgId: 6)
        
        ut.enterSubFilter(filterId: materialFilterId, msgId: 6, newMsgId: 7)
        
        ut.takeFromVM(operationId:3, vm: subFilterVM2, msgId: 7, newMsgId: 8)
        
        ut.selectSubFilters(vm: subFilterVM1, selectIds: [green], select: false, msgId: 8, newMsgId: 9)
        
        ut.applyFromFilter(filterVM:filterVM, msgId: 9, newMsgId: 10)
        
        ut.enterSubFilter(filterId: materialFilterId, msgId: 10, newMsgId: 11)
        
        takeFinish(ut: ut, vm: subFilterVM2, msgId: 11, expect: expect )
        
        waitForExpectations(timeout: timeout) { error in
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
        let ut = FilterUnitTest(catalogVM: catalogVM, result: myResult)
        let filterVM = FilterVM(categoryId: categoryId, filterActionDelegate: catalogVM)
        let expect = expectation(description: #function)
        
        initTestCase7(catalogVM, filterId1: colorFilterId)
        
        ut.selectSubFilters(vm: subFilterVM1, selectIds: [yellow, green], select: true, msgId: 0, newMsgId: 2)
        
        ut.applyFromFilter(filterVM:filterVM, msgId: 2, newMsgId: 3)
        
        ut.takeFromFilter(operationId: 1, msgId: 3, newMsgId: 4)
        
        ut.removeAppliedFilter(filterVM:filterVM, filterId: colorFilterId, msgId: 4, newMsgId: 5)
        
        takeFilterFinish(ut: ut, filterVM:filterVM, msgId: 5, expect: expect )
        
        waitForExpectations(timeout: timeout) { error in
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
        let ut = FilterUnitTest(catalogVM: catalogVM, result: myResult)
        let filterVM = FilterVM(categoryId: categoryId, filterActionDelegate: catalogVM)
        let expect = expectation(description: #function)
        
        initTestCase4(catalogVM, filterId1: colorFilterId, filterId2: materialFilterId)
        
        ut.selectApply(vm: subFilterVM1, selectIds: [yellow, green], msgId: 0, newMsgId: 1)
        
        ut.takeFromFilter(operationId: 1, msgId: 1, newMsgId: 2)
        
        ut.selectApply(vm: subFilterVM2, selectIds: [viscose, cotton], msgId: 2, newMsgId: 3)
        
        ut.takeFromFilter(operationId: 1, msgId: 3, newMsgId: 4)
        
        ut.cleanupFromFilter(filterVM:filterVM, msgId: 4, newMsgId: 5)
        
        takeFilterFinish(ut: ut, filterVM:filterVM, msgId: 5, expect: expect )
        

        waitForExpectations(timeout: timeout) { error in
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
        let ut = FilterUnitTest(catalogVM: catalogVM, result: myResult)
        let filterVM = FilterVM(categoryId: categoryId, filterActionDelegate: catalogVM)
        let expect = expectation(description: #function)
        
        initTestCase7(catalogVM, filterId1: colorFilterId)
        
        ut.selectApply(vm: subFilterVM1, selectIds: [black, yellow, green], msgId: 0, newMsgId: 1)
        
        ut.takeFromFilter(operationId: 1, msgId: 1, newMsgId: 2)
        
        ut.enterSubFilter(filterId: colorFilterId, msgId: 2, newMsgId: 3)
        
        ut.takeFromVM(operationId: 2, vm: subFilterVM1, msgId: 3, newMsgId: 4)
        
        ut.selectSubFilters(vm: subFilterVM1, selectIds: [blue, violet], select: true, msgId: 4, newMsgId: 5)
        
        ut.cleanupFromSubFilter(filterVM:filterVM, filterId: colorFilterId, msgId: 5, newMsgId: 6)
        
        ut.apply(vm: subFilterVM1, msgId: 6, newMsgId: 7)
        
        takeFilterFinish(ut: ut, filterVM:filterVM, msgId: 7, expect: expect )
        
        
        waitForExpectations(timeout: timeout) { error in
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
        let ut = FilterUnitTest(catalogVM: catalogVM, result: myResult)
        let filterVM = FilterVM(categoryId: categoryId, filterActionDelegate: catalogVM)
        let expect = expectation(description: #function)
        
        initTestCase7(catalogVM, filterId1: colorFilterId)
        
        ut.selectApply(vm: subFilterVM1, selectIds: [black, yellow, green], msgId: 0, newMsgId: 1)
        
        ut.takeFromFilter(operationId: 1, msgId: 1, newMsgId: 2)
        
        ut.apply(vm: subFilterVM1, msgId: 2, newMsgId: 3)
        
        takeFilterFinish(ut: ut, filterVM:filterVM, msgId: 3, expect: expect )
        
        
        waitForExpectations(timeout: timeout) { error in
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
        let ut = FilterUnitTest(catalogVM: catalogVM, result: myResult)
        let expect = expectation(description: #function)
        
        initTestCase4(catalogVM, filterId1: colorFilterId, filterId2: materialFilterId)
        
        ut.selectSubFilters(vm: subFilterVM1, selectIds: [green, yellow, brown], select: true, msgId: 0, newMsgId: 1)
        
        ut.selectSubFilters(vm: subFilterVM2, selectIds: [cotton], select: true, msgId: 1, newMsgId: 2)
        
        ut.applyFromFilter(filterVM:filterVM, msgId: 2, newMsgId: 3)
        
        ut.takeFromFilter(operationId: 1, msgId: 3, newMsgId: 4)
        
        ut.enterSubFilter(filterId: colorFilterId, msgId: 4, newMsgId: 5)
        
        ut.takeFromVM(operationId: 2, vm: subFilterVM1, msgId: 5, newMsgId: 6)
        
        ut.enterSubFilter(filterId: materialFilterId, msgId: 6, newMsgId: 7)
        
        takeFinish(ut: ut, vm: subFilterVM2, msgId: 7, expect: expect)
        
        waitForExpectations(timeout: timeout) { error in
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
        let ut = FilterUnitTest(catalogVM: catalogVM, result: myResult)
        let expect = expectation(description: #function)
        
        initTestCase4(catalogVM, filterId1: colorFilterId, filterId2: materialFilterId)
        
        ut.selectSubFilters(vm: subFilterVM1, selectIds: [green, yellow, brown], select: true, msgId: 0, newMsgId: 1)
        
        ut.selectSubFilters(vm: subFilterVM2, selectIds: [angora], select: true, msgId: 1, newMsgId: 2)
        
        ut.applyFromFilter(filterVM:filterVM, msgId: 2, newMsgId: 3)
        
        takeFilterFinish(ut: ut, filterVM:filterVM, msgId: 3, expect: expect )
        
        waitForExpectations(timeout: timeout) { error in
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
        let ut = FilterUnitTest(catalogVM: catalogVM, result: myResult)
        let expect = expectation(description: #function)
        
        initTestCase4(catalogVM, filterId1: colorFilterId, filterId2: materialFilterId)
        
        ut.selectSubFilters(vm: subFilterVM1, selectIds: [green, yellow, brown], select: true, msgId: 0, newMsgId: 1)
        
        ut.selectSubFilters(vm: subFilterVM2, selectIds: [angora], select: true, msgId: 1, newMsgId: 2)
        
        ut.applyFromFilter(filterVM:filterVM, msgId: 2, newMsgId: 3)
        
        ut.cleanupFromFilter(filterVM:filterVM, msgId: 3, newMsgId: 4)
        
        takeFilterFinish(ut: ut, filterVM:filterVM, msgId: 4, expect: expect )
        
        waitForExpectations(timeout: timeout) { error in
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
        let ut = FilterUnitTest(catalogVM: catalogVM, result: myResult)
        let expect = expectation(description: #function)
        
        initTestCase4(catalogVM, filterId1: colorFilterId, filterId2: materialFilterId)
        
        ut.selectSubFilters(vm: subFilterVM1, selectIds: [green, yellow, brown], select: true, msgId: 0, newMsgId: 1)
        
        ut.apply(vm: subFilterVM1, msgId: 1, newMsgId: 2)
        
        ut.enterSubFilter(filterId: materialFilterId, msgId: 2, newMsgId: 3)
        
        ut.takeFromVM(operationId: 1, vm: subFilterVM2, msgId: 3, newMsgId: 4)
        
        ut.selectSubFilters(vm: subFilterVM1, selectIds: [red, orange], select: true, msgId: 4, newMsgId: 5)
        
        ut.apply(vm: subFilterVM1, msgId: 5, newMsgId: 6)
        
        ut.enterSubFilter(filterId: materialFilterId, msgId: 6, newMsgId: 7)
        
        takeFinish(ut: ut, vm: subFilterVM2, msgId: 7, expect: expect)
        
        waitForExpectations(timeout: timeout) { error in
            guard error == nil else {
                XCTFail(error!.localizedDescription)
                return
            }
            XCTAssertEqual("1: вискоза false полиамид false хлопок false эластан false \\\\\\вискоза false полиамид false полиэстер false хлопок false шерсть false эластан false ",  myResult.res )
        }
    }
    
    
    func initTestCase15(_ catalogVM: CatalogVM, filterId1: Int){
        
        catalogVM.utMsgId = 0
        catalogVM.requestFilters(categoryId: categoryId)
        let filterVM = FilterVM(categoryId: categoryId, filterActionDelegate: catalogVM)
        
        subFilterVM1 = SubFilterVM(filterId: filterId1, filterActionDelegate: filterVM.filterActionDelegate)
    }
    
    // select subfilters -> apply from filter, deselect -> apply subfilters, select -> apply subfilters
    func testExample15(){
        
        let catalogVM = CatalogVM(categoryId: categoryId)
        let myResult = MyResults()
        let ut = FilterUnitTest(catalogVM: catalogVM, result: myResult)
        let filterVM = FilterVM(categoryId: categoryId, filterActionDelegate: catalogVM)
        let expect = expectation(description: #function)
        initTestCase15(catalogVM, filterId1: colorFilterId)
        
        
        
        ut.selectSubFilters(vm: subFilterVM1, selectIds: [green, yellow, brown], select: true, msgId: 0, newMsgId: 1)
        
        ut.applyFromFilter(filterVM: filterVM, msgId: 1, newMsgId: 2)
        
        ut.takeFromFilter(operationId: 1, msgId: 2, newMsgId: 3)
        
        ut.enterSubFilter(filterId: colorFilterId, msgId: 3, newMsgId: 4)
        
        ut.takeFromVM(operationId: 2, vm: subFilterVM1, msgId: 4, newMsgId: 5)
        
        ut.selectSubFilters(vm: subFilterVM1, selectIds: [green, yellow, brown], select: false, msgId: 5, newMsgId: 6)
        
        ut.apply(vm: subFilterVM1, msgId: 6, newMsgId: 7)
        
        ut.takeFromFilter(operationId: 3, msgId: 7, newMsgId: 8)
        
        ut.enterSubFilter(filterId: colorFilterId, msgId: 8, newMsgId: 9)
        
        ut.takeFromVM(operationId: 4, vm: subFilterVM1, msgId: 9, newMsgId: 10)
        
        ut.selectSubFilters(vm: subFilterVM1, selectIds: [green, yellow, brown], select: true, msgId: 10, newMsgId: 11)
        
        ut.apply(vm: subFilterVM1, msgId: 11, newMsgId: 12)
        
        takeFilterFinish(ut: ut, filterVM: filterVM, msgId: 12, expect: expect)

        waitForExpectations(timeout: timeout) { error in
            guard error == nil else {
                XCTFail(error!.localizedDescription)
                return
            }
            XCTAssertEqual("1: Бренд Размер Сезон Состав Срок доставки Цвет \\\\\\2: бежевый false белый false голубой false желтый true зеленый true коричневый true красный false оранжевый false розовый false серый false синий false фиолетовый false черный false \\\\\\3: Цена Бренд Размер Сезон Состав Срок доставки Цвет Вид застежки Вырез горловины Декоративные элементы Длина юбки/платья Конструктивные элементы Тип рукава Цена2 \\\\\\4: бежевый false белый false голубой false желтый false зеленый false коричневый false красный false оранжевый false розовый false серый false синий false фиолетовый false черный false \\\\\\Бренд Размер Сезон Состав Срок доставки Цвет ",  myResult.res )
        }
    }
    
}
