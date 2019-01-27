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
    
    let event1 = Variable<Int>(0)
    let event2 = Variable<Int>(0)
    let event3 = Variable<Int>(0)
    let event4 = Variable<Int>(0)
    let event5 = Variable<Int>(0)
    let event6 = Variable<Int>(0)
    let event7 = Variable<Int>(0)
    let event8 = Variable<Int>(0)
    let event9 = Variable<Int>(0)
    let event10 = Variable<Int>(0)
    let event11 = Variable<Int>(0)
    let event12 = Variable<Int>(0)
    let event13 = Variable<Int>(0)
    let event14 = Variable<Int>(0)
    let event15 = Variable<Int>(0)
    let event16 = Variable<Int>(0)
    let event17 = Variable<Int>(0)
    let event18 = Variable<Int>(0)
    let event19 = Variable<Int>(0)
    let event20 = Variable<Int>(0)
    let event21 = Variable<Int>(0)
    let event22 = Variable<Int>(0)
    
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
    let pink = 68
    let violet = 71
    let days5 = 59
    let viscose = 48
    
    let winter = 44
    let summer = 46
    
    let demiseason = 43
    
    var result = ""
    
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
    
    
    func refreshSubFilters(observableEvent: Variable<Int>, filterId: Int, observerEvent: Variable<Int>) {
        observableEvent
            .asObservable()
            .filter({$0 != 0})
            .take(1)
            .subscribe(onNext: {[weak self] _ in
                self?.filterVM.filterActionDelegate?.didNetworkRequestCompleteEvent()
                    .take(1)
                    .subscribe(onNext: {[weak self] _ in
                
                        self?.catalogVM.utRefreshSubFilters(filterId: filterId)
                        observerEvent.value = 1
                })
                .disposed(by: self!.bag)
            })
            .disposed(by: bag)
    }
    
    func selectSubFilter(vm: SubFilterVM, subFilterId: Int, select: Bool){
        vm.filterActionDelegate?.selectSubFilterEvent().onNext((subFilterId, select))
    }
    
    
    func applySubFilter(vm: SubFilterVM){
        vm.inApply.onCompleted()
    }
    
    
    func selectApply(vm: SubFilterVM, subFilterId: Int, observerEvent: Variable<Int>){
        vm.filterActionDelegate?.selectSubFilterEvent().onNext((subFilterId, true))
        vm.inApply.onCompleted()
        observerEvent.value = 1
    }
    
    
    func selectApply(observableEvent: Variable<Int>, vm: SubFilterVM, selectIds: [Int], observerEvent: Variable<Int>) {
        
        observableEvent
            .asObservable()
            .filter({$0 != 0})
            .take(1)
            .subscribe(onNext: {[weak self] _ in
                for subFilterId in selectIds {
                    self?.selectSubFilter(vm: vm, subFilterId: subFilterId, select: true)
                }
                self?.applySubFilter(vm: vm)
                observerEvent.value = 1
            })
            .disposed(by: bag)
    }
    
    
    func removeAppliedFilter(observableEvent: Variable<Int>, filterId: Int, observerEvent: Variable<Int>){
        observableEvent
            .asObservable()
            .filter({$0 != 0})
            .take(1)
            .subscribe(onNext: {[weak self] _ in
                self!.filterVM.inRemoveFilter.onNext(filterId)
                observerEvent.value = 1
            })
            .disposed(by: bag)
    }
    
    
    func clearTestCase(){
        subFilterVM1 = nil
        subFilterVM2 = nil
        subFilterVM3 = nil
        subFilterVM4 = nil
        subFilterVM5 = nil
    }
    
    
    func takeFromFilterVM(operationId: Int, observableEvent: Variable<Int>, observerEvent: Variable<Int>){
        observableEvent
            .asObservable()
            .filter({$0 != 0})
            .take(1)
            .subscribe(onNext: {[weak self] _ in
                self?.filterVM.filterActionDelegate?.didNetworkRequestCompleteEvent()
                    .take(1)
                    .subscribe(onNext: {[weak self] _ in
                        self?.filterVM.filterActionDelegate?.filtersEvent()
                            .take(1)
                            .subscribe(onNext: {[weak self] sf in
                                self?.result += ("\(operationId): ")
                                for element in sf {
                                    self?.result += (element!.title + " ")
                                }
                                self?.result += "\\\\\\"
                                print(self?.result)
                                observerEvent.value = 1
                            })
                            .disposed(by: self!.bag)
                    })
                    .disposed(by: self!.bag)
            }).disposed(by: bag)
    }
    
    
    func takeFromVM(operationId: Int, observableEvent: Variable<Int>, vm: SubFilterVM, observerEvent: Variable<Int>){
        observableEvent
            .asObservable()
            .filter({$0 != 0})
            .take(1)
            .subscribe(onNext: {[weak self] _ in
                self?.filterVM.filterActionDelegate?.didNetworkRequestCompleteEvent()
                    .take(1)
                    .subscribe(onNext: {[weak self] res in
                            vm.filterActionDelegate?.subFiltersEvent()
                                .take(1)
                                .subscribe(onNext: {[weak self] sf in
                                    self?.result += ("\(operationId): ")
                                    for element in sf {
                                        self?.result += (element!.title + " \(vm.isCheckmark(subFilterId: element!.id)) ")
                                    }
                                    self?.result += "\\\\\\"
                                    observerEvent.value = 1
                                })
                                .disposed(by: self!.bag)
                }).disposed(by: self!.bag)
            }).disposed(by: bag)
    }
    
    func takeFilterFinish(observableEvent: Variable<Int>, expect: XCTestExpectation){
        observableEvent
            .asObservable()
            .filter({$0 != 0})
            .take(1)
            .subscribe(onNext: {[weak self] _ in
                self?.filterVM.filterActionDelegate?.didNetworkRequestCompleteEvent()
                    .take(1)
                    .subscribe(onNext: {[weak self] res in
                        self?.filterVM.filterActionDelegate?.filtersEvent()
                            .take(1)
                            .subscribe(onNext: {[weak self] sf in
                                for element in sf {
                                    self?.result += (element!.title + " ")
                                }
                                expect.fulfill()
                            })
                            .disposed(by: self!.bag)
                    }).disposed(by: self!.bag)
            }).disposed(by: bag)
    }
    
    func takeFinish(observableEvent: Variable<Int>, vm: SubFilterVM, expect: XCTestExpectation){
        observableEvent
            .asObservable()
            .filter({$0 != 0})
            .take(1)
            .subscribe(onNext: {[weak self] res in
                vm.filterActionDelegate?.subFiltersEvent()
                    .take(1)
                    .subscribe(onNext: {[weak self] sf in
                        for element in sf {
                            self?.result += (element!.title + " \(vm.isCheckmark(subFilterId: element!.id)) ")
                        }
                        expect.fulfill()
                    })
                    .disposed(by: self!.bag)
            }).disposed(by: bag)
    }
    
    
    func initTestCase0(filterId1: Int, filterId2: Int, filterId3: Int, filterId4: Int, filterId5: Int){
        subFilterVM1 = SubFilterVM(filterId: filterId1, filterActionDelegate: filterVM.filterActionDelegate)
        subFilterVM2 = SubFilterVM(filterId: filterId2, filterActionDelegate: filterVM.filterActionDelegate)
        subFilterVM3 = SubFilterVM(filterId: filterId3, filterActionDelegate: filterVM.filterActionDelegate)
        subFilterVM4 = SubFilterVM(filterId: filterId4, filterActionDelegate: filterVM.filterActionDelegate)
        subFilterVM5 = SubFilterVM(filterId: filterId5, filterActionDelegate: filterVM.filterActionDelegate)
        
        result = ""
    }

    func testExample() {
        let expect = expectation(description: #function)
        initTestCase0(filterId1: materialFilterId, filterId2: colorFilterId, filterId3: seasonFilterId, filterId4: deliveryFilterId, filterId5: sizeFilterId)
        
        
        // 1 apply pink
        selectApply(vm: subFilterVM2, subFilterId: pink, observerEvent: event1)
        
        refreshSubFilters(observableEvent: event1, filterId: deliveryFilterId, observerEvent: event2)
        
        // 2 take available subfilters from Delivery Filter
        takeFromVM(operationId:2, observableEvent: event2, vm: subFilterVM4, observerEvent: event3)
        
        // 3 apply 5days
        selectApply(observableEvent: event3, vm: subFilterVM4, selectIds: [days5], observerEvent: event4)
        
        // 4 take available subfilters from Material Filter
        takeFromVM(operationId:3, observableEvent: event4, vm: subFilterVM1, observerEvent: event5)
        
        // 5 apply viscose
        selectApply(observableEvent: event5, vm: subFilterVM1, selectIds: [viscose], observerEvent: event6)
        
        // 6 take available subfilters from Season Filter
        takeFromVM(operationId:4, observableEvent: event6, vm: subFilterVM3, observerEvent: event7)
        
        // 7 apply winter
        selectApply(observableEvent: event7, vm: subFilterVM4, selectIds: [winter], observerEvent: event8)
        
        // 8 take available subfilters from Size Filter
        takeFinish(observableEvent: event8, vm: subFilterVM5, expect: expect )
        
        waitForExpectations(timeout: 20.0) { [weak self] error in
            guard error == nil else {
                XCTFail(error!.localizedDescription)
                return
            }
            XCTAssertEqual("2: 5 дней false \\\\\\3: вискоза false шерсть false \\\\\\4: зима false \\\\\\34 false 36 false 45 false ", self?.result)
        }
        clearTestCase()
    }
    
    func initTestCase1(filterId1: Int, filterId2: Int){
        subFilterVM1 = SubFilterVM(filterId: filterId1, filterActionDelegate: filterVM.filterActionDelegate)
        subFilterVM2 = SubFilterVM(filterId: filterId2, filterActionDelegate: filterVM.filterActionDelegate)
        result = ""
    }
    
    func testExample2() {
        
        let expect = expectation(description: #function)
        initTestCase1(filterId1: colorFilterId, filterId2: seasonFilterId)
        
        // 1 apply violet
        selectApply(vm: subFilterVM1, subFilterId: violet, observerEvent: event1)
        

        // 2 take available subfilters from Season Filter
        takeFromVM(operationId:1, observableEvent: event3, vm: subFilterVM2, observerEvent: event4)
        
        // 3 season demi-season
        selectApply(observableEvent: event4, vm: subFilterVM2, selectIds: [demiseason], observerEvent: event5)
        
        // 4 take available subfilters from Color Filter
        takeFromVM(operationId:2, observableEvent: event5, vm: subFilterVM1, observerEvent: event6)
        
        // 5 take available subfilters from Season Filter
        takeFinish(observableEvent: event6, vm: subFilterVM2, expect: expect )
        
        
        waitForExpectations(timeout: 20.0) { [weak self] error in
            guard error == nil else {
                XCTFail(error!.localizedDescription)
                return
            }
            XCTAssertEqual("1: демисезон false круглогодичный false \\\\\\2: желтый false коричневый false красный false оранжевый false серый false фиолетовый true черный false \\\\\\демисезон true круглогодичный false ", self?.result)
        }
        clearTestCase()
    }

    
    func testExample3() {
        let expect = expectation(description: #function)
        initTestCase1(filterId1: colorFilterId, filterId2: seasonFilterId)
        
        // 1 apply violet
        selectApply(vm: subFilterVM1, subFilterId: violet, observerEvent: event1)
        
        // 2 select
       // select(observableEvent: event1, vm: subFilterVM2, selectIds: [demiseason], observerEvent: event2)
        
        // 3 take available subfilters from Color Filter
        takeFinish(observableEvent: event2, vm: subFilterVM1, expect: expect )
        
        waitForExpectations(timeout: 20.0) { [weak self] error in
            guard error == nil else {
                XCTFail(error!.localizedDescription)
                return
            }
            XCTAssertEqual("бежевый false белый false голубой false желтый false зеленый false коричневый false красный false оранжевый false розовый false серый false синий false фиолетовый true черный false ", self?.result)
        }
        clearTestCase()
        
    }

    
    func testExample4() {
        
        let expect = expectation(description: #function)
        initTestCase1(filterId1: colorFilterId, filterId2: materialFilterId)
        
        // 1 apply blue
        selectApply(vm: subFilterVM1, subFilterId: blue, observerEvent: event1)
        
        // 2 take from Filter
        takeFromFilterVM(operationId: 1, observableEvent: event1, observerEvent: event2)
        
        // 3 apply yellow
        selectApply(observableEvent: event2, vm: subFilterVM1, selectIds: [yellow], observerEvent: event3)
        
        // 4 take from Filter
        takeFromFilterVM(operationId: 2, observableEvent: event3, observerEvent: event4)
        
        // 5 take available subfilters from Material Filter
        takeFromVM(operationId:3, observableEvent: event4, vm: subFilterVM2, observerEvent: event5)
        
        // 6 apply viscose
        selectApply(observableEvent: event5, vm: subFilterVM2, selectIds: [viscose], observerEvent: event6)
        
        // 7 take available subfilters from Color Filter
        takeFromVM(operationId:4, observableEvent: event6, vm: subFilterVM1, observerEvent: event7)
        
        takeFinish(observableEvent: event7, vm: subFilterVM2, expect: expect )
        
        waitForExpectations(timeout: 20.0) { [weak self] error in
            guard error == nil else {
                XCTFail(error!.localizedDescription)
                return
            }
            XCTAssertEqual("1: Цвет \\\\\\2: Бренд Размер Сезон Состав Срок доставки Цвет \\\\\\3: вискоза false полиамид false \\\\\\4: желтый true розовый false фиолетовый false \\\\\\вискоза true полиамид false ", self?.result)
        }
        clearTestCase()
        
    }
    
    
    
    
    
    func testExample5() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

}
