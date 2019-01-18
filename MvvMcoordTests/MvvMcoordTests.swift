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
    var dataVM1: Variable<[SubfilterModel?]>!
    var dataVM2: Variable<[SubfilterModel?]>!
    var dataVM3: Variable<[SubfilterModel?]>!
    
    let event1 = Variable<Int>(1)
    let event2 = Variable<Int>(1)
    let event3 = Variable<Int>(1)
    let event4 = Variable<Int>(1)
    let event5 = Variable<Int>(1)
    let event6 = Variable<Int>(1)
    let event7 = Variable<Int>(1)
    let event8 = Variable<Int>(1)
    let event9 = Variable<Int>(1)
    let event10 = Variable<Int>(1)
    let event11 = Variable<Int>(1)
    let event12 = Variable<Int>(1)
    let event13 = Variable<Int>(1)
    let event14 = Variable<Int>(1)
    let event15 = Variable<Int>(1)
    let event16 = Variable<Int>(1)
    let event17 = Variable<Int>(1)
    let event18 = Variable<Int>(1)
    let event19 = Variable<Int>(1)
    let event20 = Variable<Int>(1)
    let event21 = Variable<Int>(1)
    let event22 = Variable<Int>(1)
    
    var filterVM: FilterVM!
    var bag = DisposeBag()
    
    let categoryId = 1
    let materialFilterId = 4
    let colorFilterId = 6
    let seasonFilterId = 3
    
    let polyamide = 49 // полиамид
    let yellow = 63 // желтый
    let gray = 69 // серый
    let black = 72 // черный
    
    let summer = 46
    
    var result = ""
    
    override func setUp() {
        CategoryModel.fillModels()
        CatalogModel.fillModels()
        FilterModel.fillModels()
        SubfilterModel.fillModels()
        
        filterVM = FilterVM(categoryId: categoryId)
    }

    override func tearDown() {
        subFilterVM1 = nil
    }
    
    func selectSubFilter(vm: SubFilterVM, subFilterId: Int){
        subFilterVM2.inSelectModel.onNext(subFilterId)
        
    }

    func applySubFilter(vm: SubFilterVM){
        vm.inApply.onNext(.reloadData)
    }
    

    func selectApply(vm: SubFilterVM, subFilterId: Int, observerEvent: Variable<Int>){
        vm.inSelectModel.onNext(subFilterId)
        vm.inApply.onNext(.reloadData)
        observerEvent.value = 1
    }
    
    
    func selectApply(observableEvent: Variable<Int>, vm: SubFilterVM, selectIds: [Int], observerEvent: Variable<Int>) {
        
        observableEvent
            .asObservable()
            .subscribe(onNext: {[weak self] _ in
                for subFilterId in selectIds {
                    self?.selectSubFilter(vm: vm, subFilterId: subFilterId)
                }
                self?.applySubFilter(vm: vm)
                observerEvent.value = 1
            })
            .disposed(by: bag)
    }
    
    func refreshDataSource(observableEvent: Variable<Int>, vm: SubFilterVM, observerEvent: Variable<Int>) {
        observableEvent
        .asObservable()
        .subscribe(onNext: {_ in
            vm.bindData()
            observerEvent.value = 1
        })
        .disposed(by: bag)
    }
    
    
    func removeAppliedFilter(observableEvent: Variable<Int>, filterId: Int, observerEvent: Variable<Int>){
        observableEvent
            .asObservable()
            .subscribe(onNext: {[weak self] _ in
                self!.filterVM.inRemoveFilter.onNext(filterId)
                observerEvent.value = 1
            })
            .disposed(by: bag)
    }
    

    func initTestCase(filterId1: Int, filterId2: Int){
        subFilterVM1 = SubFilterVM(filterId: filterId1)
        subFilterVM2 = SubFilterVM(filterId: filterId2)
        result = ""
    }
    
    func clearTestCase(){
        subFilterVM1 = nil
        subFilterVM2 = nil
        subFilterVM3 = nil
    }
    
    
    func takeFromVM(operationId: Int, observableEvent: Variable<Int>, vm: SubFilterVM, observerEvent: Variable<Int>){
        observableEvent
            .asObservable()
            .subscribe(onNext: {[weak self] _ in
                vm.bindData()
                vm.outModels
                    .asObservable()
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
    
    
    func takeFinish(observableEvent: Variable<Int>, vm: SubFilterVM, expect: XCTestExpectation){
        observableEvent
            .asObservable()
            .subscribe(onNext: {[weak self] _ in
                vm.bindData()
                vm.outModels
                    .asObservable()
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
    
    

    func testUseCase1() {
        
        let expect = expectation(description: #function)
        
        initTestCase(filterId1: materialFilterId, filterId2: colorFilterId)
        
        // 1 click polyamide
        selectApply(vm: subFilterVM1, subFilterId: polyamide, observerEvent: event1)
       
        // 2 take available subfilters from Color Filter
        takeFromVM(operationId:2, observableEvent: event1, vm: subFilterVM2, observerEvent: event2)
        
        // 3 select&apply yellow, gray, black
        selectApply(observableEvent: event2, vm: subFilterVM2, selectIds: [yellow, gray, black], observerEvent: event3)
        
        // 4 check subfilter checkmarks from Color Filter
        takeFromVM(operationId:4, observableEvent: event3, vm: subFilterVM2, observerEvent: event4)
        
        // 5 applied materials must be equal polyamide
        refreshDataSource(observableEvent: event4, vm: subFilterVM1, observerEvent: event5)
        
        // 6 take available subfilters from Material Filter
        takeFromVM(operationId:6, observableEvent: event5, vm: subFilterVM1, observerEvent: event6)
        
        // 7 unapply Color Filter
        removeAppliedFilter(observableEvent: event6, filterId: colorFilterId, observerEvent: event7)
        
        // 6 materials must be all
        refreshDataSource(observableEvent: event7, vm: subFilterVM1, observerEvent: event8)
        
        // 7 take available subfilters from Material Filter
        takeFinish(observableEvent: event9, vm: subFilterVM1, expect: expect )

        
        waitForExpectations(timeout: 20.0) { [weak self] error in
            guard error == nil else {
                XCTFail(error!.localizedDescription)
                return
            }
            XCTAssertEqual("2: желтый false серый false черный false \\\\\\4: желтый true серый true черный true \\\\\\6: ангора false вискоза false полиамид true полиуретан false полиэстер false хлопок false эластан false \\\\\\ангора false вискоза false полиамид true полиуретан false полиэстер false хлопок false шелк false шерсть false эластан false ", self?.result)
        }
        
        clearTestCase()
    }
    
    func initTestCase2(filterId1: Int, filterId2: Int, filterId3: Int){
        subFilterVM1 = SubFilterVM(filterId: filterId1)
        subFilterVM2 = SubFilterVM(filterId: filterId2)
        subFilterVM3 = SubFilterVM(filterId: filterId3)
        result = ""
    }
    
    func testUseCase2() {
        
        let expect = expectation(description: #function)
        
        initTestCase2(filterId1: materialFilterId, filterId2: colorFilterId, filterId3: seasonFilterId)
        
        // 1 apply polyamide
        selectApply(vm: subFilterVM1, subFilterId: polyamide, observerEvent: event1)
        
        // 2 take available subfilters from Color Filter
        takeFromVM(operationId:2, observableEvent: event1, vm: subFilterVM2, observerEvent: event2)
        
        // 3 apply black
        selectApply(observableEvent: event2, vm: subFilterVM2, selectIds: [black], observerEvent: event3)
        
        // 4 materials must be all
        refreshDataSource(observableEvent: event3, vm: subFilterVM1, observerEvent: event4)
        
        // 5 take available subfilters from Material Filter
        takeFromVM(operationId:5, observableEvent: event4, vm: subFilterVM1, observerEvent: event5)
        
        
        // 6 take available subfilters from Color Filter
        takeFromVM(operationId:6, observableEvent: event6, vm: subFilterVM2, observerEvent: event7)
        
        // 7 season must be equal summer
        refreshDataSource(observableEvent: event7, vm: subFilterVM3, observerEvent: event8)
        
        // 8 take available subfilters from Season Filter
        takeFromVM(operationId:8, observableEvent: event8, vm: subFilterVM3, observerEvent: event9)
        
        // 9 apply summer
        selectApply(observableEvent: event9, vm: subFilterVM3, selectIds: [summer], observerEvent: event10)
        
        // 10 materials must be polyamide, elastane, polyurethane
        refreshDataSource(observableEvent: event10, vm: subFilterVM1, observerEvent: event11)
        
        // 11 take available subfilters from Material Filter
        takeFromVM(operationId:11, observableEvent: event11, vm: subFilterVM1, observerEvent: event12)
        
        // 12 color must be black
        refreshDataSource(observableEvent: event12, vm: subFilterVM2, observerEvent: event13)
        
        // 13 take available subfilters from Color Filter
        takeFromVM(operationId:13, observableEvent: event13, vm: subFilterVM2, observerEvent: event14)
        
        // 14 unapply Season Filter
        removeAppliedFilter(observableEvent: event15, filterId: seasonFilterId, observerEvent: event16)
        
        // 15 color must be yellow, gray, black
        refreshDataSource(observableEvent: event16, vm: subFilterVM2, observerEvent: event17)
        
        // 16 take available subfilters from Color Filter
        takeFromVM(operationId:16, observableEvent: event17, vm: subFilterVM2, observerEvent: event18)
        
        
        // 17 material must be polyamide, elastane, polyurethane, angora, polyester, cotton
        refreshDataSource(observableEvent: event18, vm: subFilterVM2, observerEvent: event19)
        
        
        // 7 take available subfilters from Color Filter
        takeFinish(observableEvent: event19, vm: subFilterVM1, expect: expect )
        
        
        waitForExpectations(timeout: 20.0) { [weak self] error in
            guard error == nil else {
                XCTFail(error!.localizedDescription)
                return
            }
            XCTAssertEqual("2: желтый false серый false черный false \\\\\\5: ангора false полиамид true полиуретан false полиэстер false хлопок false эластан false \\\\\\6: желтый false серый false черный true \\\\\\8: лето false \\\\\\11: полиамид true полиуретан false эластан false \\\\\\13: черный true \\\\\\16: желтый false серый false черный true \\\\\\ангора false полиамид true полиуретан false полиэстер false хлопок false эластан false ", self?.result)
        }
        
        clearTestCase()
    }
}
//желтый false серый false черный false :::ангора false полиамид true полиуретан false полиэстер false хлопок false эластан false :::желтый false серый false черный true :::лето false :::полиамид true полиуретан false эластан false :::черный true :::желтый false серый false черный true :::желтый false серый false черный true :::желтый false серый false черный true :::ангора false полиамид true полиуретан false полиэстер false хлопок false эластан false
