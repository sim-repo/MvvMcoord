import Foundation
import RxCocoa
import RxSwift

var uitCurrMemVCs = 0



class FilterUnitTest {
    
    var bag = DisposeBag()
    var catalogVM: CatalogVM
    var result: MyResults
    
    
    init(catalogVM: CatalogVM, result: MyResults){
        self.catalogVM = catalogVM
        self.result = result
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
        let completion: (() -> Void) = { [weak self] in
            self?.catalogVM.utMsgId = newMsgId
            self?.catalogVM.utRefreshSubFilters(filterId: filterId)
        }
        capsule(msgId: msgId, completion: completion)
    }
    
    
    func enterSubFilter(filterId: Int, msgId: Int, newMsgId: Int) {
        let completion: (() -> Void) = {[weak self] in
            self?.catalogVM.utMsgId = newMsgId
            self?.catalogVM.utEnterSubFilter(filterId: filterId)
        }
        capsule(msgId: msgId, completion: completion)
    }
    
    
    private func selectSubFilters(vm: SubFilterVM, selectIds: [Int], select: Bool){
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
        let completion: (() -> Void) = {[weak self] in
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
    
    
    func removeAppliedFilter(filterVM: FilterVM, filterId: Int, msgId: Int, newMsgId: Int){
        let completion: (() -> Void) = {[weak self] in
            self?.catalogVM.utMsgId = newMsgId
            filterVM.inRemoveFilter.onNext(filterId)
        }
        capsule(msgId: msgId, completion: completion)
    }
    
    func cleanupFromFilter(filterVM: FilterVM, msgId: Int, newMsgId: Int){
        let completion: (() -> Void) = {[weak self] in
            self?.catalogVM.utMsgId = newMsgId
            filterVM.filterActionDelegate?.cleanupFromFilterEvent().onNext(Void())
        }
        capsule(msgId: msgId, completion: completion)
    }
    
    func cleanupFromSubFilter(filterVM: FilterVM, filterId: Int, msgId: Int, newMsgId: Int){
        let completion: (() -> Void) = {[weak self] in
            self?.catalogVM.utMsgId = newMsgId
            filterVM.filterActionDelegate?.cleanupFromSubFilterEvent().onNext(filterId)
        }
        capsule(msgId: msgId, completion: completion)
    }
    
    
    
    func applyFromFilter(filterVM: FilterVM, msgId: Int, newMsgId: Int) {
        let completion: (() -> Void) = {[weak self] in
            self?.catalogVM.utMsgId = newMsgId
            filterVM.inApply.onNext(Void())
        }
        capsule(msgId: msgId, completion: completion)
    }
    
    
    func  takeFromFilter(operationId: Int, msgId: Int, newMsgId: Int){
        let completion: (() -> Void) = {[weak self] in
            self?.catalogVM.filtersEvent()
                .take(1)
                .subscribe(onNext: {sf in
                    self?.result.res += ("\(operationId): ")
                    for element in sf {
                        self?.result.res += (element!.title + " ")
                    }
                    self?.result.res += "***"
                    print("take: \(self?.result.res)")
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
                .subscribe(onNext: {sf in
                    
                    self?.result.res += ("\(operationId): ")
                    for element in sf {
                        self?.result.res += (element!.title + " \(vm.isCheckmark(subFilterId: element!.id)) ")
                    }
                    self?.result.res += "***"
                    self?.catalogVM.unitTestSignalOperationComplete.onNext(newMsgId)
                    print("take: \(self?.result.res)")
                })
                .disposed(by: self!.bag)
        }
        capsule(msgId: msgId, completion: completion)
    }
}
