//
//  MvvMcoordTests.swift
//  MvvMcoordTests
//
//  Created by Igor Ivanov on 01/01/2019.
//  Copyright © 2019 Igor Ivanov. All rights reserved.
//

import XCTest
import RxCocoa
import RxSwift
import RxTest


@testable import MvvMcoord

class MvvMcoordTests: XCTestCase {

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
    let days5 = 59
    let viscose = 48
    
    let winter = 44
    let summer = 46
    
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
            .subscribe(onNext: {[weak self] _ in
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
    
    func initTestCase(filterId1: Int, filterId2: Int){
        subFilterVM1 = SubFilterVM(filterId: filterId1, filterActionDelegate: filterVM.filterActionDelegate)
        subFilterVM2 = SubFilterVM(filterId: filterId2, filterActionDelegate: filterVM.filterActionDelegate)
        
        result = ""
    }
    
    func testUseCase0(){
        
        let expect = expectation(description: #function)
       
            
        initTestCase(filterId1: materialFilterId, filterId2: colorFilterId)
        
        selectApply(vm: subFilterVM2, subFilterId: blue, observerEvent: event1)
        
        //2 take available Filters
        takeFromFilterVM(operationId: 2, observableEvent: event1, observerEvent: event2)
    
        //3 unapply Color Filter
        removeAppliedFilter(observableEvent: event2, filterId: colorFilterId, observerEvent: event3)
        
        // 4 take available Filters
        takeFilterFinish(observableEvent: event3, expect: expect )
        
        waitForExpectations(timeout: 20.0) { [weak self] error in
            guard error == nil else {
                XCTFail(error!.localizedDescription)
                return
            }
            XCTAssertEqual("2: Цвет \\\\\\Цена Бренд Размер Сезон Состав Срок доставки Цвет Вид застежки Вырез горловины Декоративные элементы Длина юбки/платья Конструктивные элементы Тип рукава ", self?.result)
        }
        clearTestCase()
    }
}
