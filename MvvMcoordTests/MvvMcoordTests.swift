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
    
    
    func takeFromVM(observableEvent: Variable<Int>, vm: SubFilterVM, observerEvent: Variable<Int>){
        observableEvent
            .asObservable()
            .subscribe(onNext: {[weak self] _ in
                vm.bindData()
                vm.outModels
                    .asObservable()
                    .take(1)
                    .subscribe(onNext: {[weak self] sf in
                        for element in sf {
                            self?.result += (element!.title + " ")
                            print(element?.title)
                        }
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
                            self?.result += (element!.title + " ")
                            print(element?.title)
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
        takeFromVM(observableEvent: event1, vm: subFilterVM2, observerEvent: event2)
        
        // 3 select&apply yellow, gray, black
        selectApply(observableEvent: event2, vm: subFilterVM2, selectIds: [yellow, gray, black], observerEvent: event3)
        
        // 4 materials must be equal polyamide
        refreshDataSource(observableEvent: event3, vm: subFilterVM1, observerEvent: event4)
        
        // 5 unapply Color Filter
        removeAppliedFilter(observableEvent: event5, filterId: colorFilterId, observerEvent: event6)
        
        // 6 materials must be all
        refreshDataSource(observableEvent: event7, vm: subFilterVM1, observerEvent: event8)
        
        // 7 take available subfilters from Material Filter
        takeFinish(observableEvent: event8, vm: subFilterVM1, expect: expect )

        
        waitForExpectations(timeout: 20.0) { [weak self] error in
            guard error == nil else {
                XCTFail(error!.localizedDescription)
                return
            }
            XCTAssertEqual("желтый серый черный ангора вискоза полиамид полиуретан полиэстер хлопок шелк шерсть эластан ", self?.result)
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
        
        // 1 click polyamide
        selectApply(vm: subFilterVM1, subFilterId: polyamide, observerEvent: event1)
        
        // 2 take available subfilters from Color Filter
        takeFromVM(observableEvent: event1, vm: subFilterVM2, observerEvent: event2)
        
        // 3 select&apply black
        selectApply(observableEvent: event2, vm: subFilterVM2, selectIds: [black], observerEvent: event3)
        
        // 4 season must be equal summer
        refreshDataSource(observableEvent: event3, vm: subFilterVM3, observerEvent: event4)
        
        // 5 take available subfilters from Season Filter
        takeFromVM(observableEvent: event4, vm: subFilterVM3, observerEvent: event6)
        
        
        // 5 unapply Season Filter
        removeAppliedFilter(observableEvent: event6, filterId: seasonFilterId, observerEvent: event7)
        
        // 6 color must be all
        refreshDataSource(observableEvent: event7, vm: subFilterVM2, observerEvent: event8)
        
        // 7 take available subfilters from Material Filter
        takeFinish(observableEvent: event8, vm: subFilterVM2, expect: expect )
        
        
        waitForExpectations(timeout: 20.0) { [weak self] error in
            guard error == nil else {
                XCTFail(error!.localizedDescription)
                return
            }
            XCTAssertEqual("желтый серый черный лето желтый серый черный ", self?.result)
        }
        
        clearTestCase()
    }
    
    
    
    
    
    //        waitForExpectations(timeout: 10.0) { error in
    //            guard error == nil else {
    //                XCTFail(error!.localizedDescription)
    //                return
    //            }
    //            XCTAssertEqual("желтыйсерыйчерный", result)
    //        }

//
//
//    func test2(){
//
//        let expect = expectation(description: #function)
//        var result = ""
//
//
//        selectColor(subFilterId: 63)
//        selectColor(subFilterId: 69)
//        selectColor(subFilterId: 72)
//        applyColor()
//
//        материалSubFilterVM.outModels
//            .asObservable()
//            .subscribe(onNext: {sf in
//                for element in sf {
//                    result += element?.title ?? ""
//                }
//                expect.fulfill()
//            })
//            .disposed(by: bag)
//
//        waitForExpectations(timeout: 10.0) { error in
//            guard error == nil else {
//                XCTFail(error!.localizedDescription)
//                return
//            }
//            XCTAssertEqual("желтыйсерыйчерный", result)
//        }
//
//    }
    
    
    
    //
    //        FilterModel.localRequest(categoryId: 01010101)
    //        .asObservable()
    //            .subscribe(onNext: {filter in
    //                for element in filter {
    //                    result += element?.title ?? ""
    //
    //                }
    //                expect.fulfill()
    //            })
    //            .disposed(by: bag)
}
