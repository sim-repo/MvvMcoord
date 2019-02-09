import Foundation
import RxSwift
import RxCocoa

enum CellLayoutEnum {
    case list, square, squares
}

struct CellLayout {
    var cellLayoutType: CellLayoutEnum
    var cellScale: CGSize
    var cellSpace: CGFloat
    var lineSpace: CGFloat
    var layoutImageName: String
}


protocol FilterActionDelegate : class {
    func applyFromFilterEvent() -> PublishSubject<Void>
    func applyFromSubFilterEvent() -> PublishSubject<Int>
    func removeFilterEvent() -> PublishSubject<Int>
    func filtersEvent() -> BehaviorSubject<[FilterModel?]>
    func requestFilters(categoryId: Int)
    func subFiltersEvent() -> BehaviorSubject<[SubfilterModel?]>
    func requestSubFilters(filterId: Int)
    func sectionSubFiltersEvent() -> BehaviorSubject<[SectionOfSubFilterModel]>
    func selectSubFilterEvent() -> PublishSubject<(Int, Bool)>
    func appliedTitle(filterId: Int) -> String
    func isSelectedSubFilter(subFilterId: Int) -> Bool
    func getTitle(filterId: Int) -> String
    func getFilterEnum(filterId: Int)->FilterEnum
    func cleanupFromFilterEvent() -> PublishSubject<Void>
    func cleanupFromSubFilterEvent() -> PublishSubject<Int>
    func requestComplete() -> PublishSubject<Int>
    func showApplyingViewEvent() -> BehaviorSubject<Bool>
    func refreshedCellSelectionsEvent()->PublishSubject<Set<Int>>
}


class CatalogVM : BaseVM {
    
    private var currCellLayout: CellLayoutEnum = .list
    private var categoryId: Int
    
    // MARK: - Inputs from ViewController
    var inPressLayout:Variable<Void> = Variable<Void>(Void())
    var inPressFilter = PublishSubject<Void>()
    
    
    // MARK: - Outputs to ViewController or Coord
    var outCatalog = PublishSubject<[CatalogModel?]>()
    var outTitle = Variable<String>("")
    var outLayout = Variable<CellLayout?>(nil)
    var outShowFilters = PublishSubject<Int>()
    var outCloseVC = PublishSubject<Void>()
    
    // MARK: - Filters
    private var filters: [Int:FilterModel] = [:]
    private var subFilters: [Int:SubfilterModel] = [:]
    private var subfiltersByFilter: [Int:[Int]] = [:]
    private var sectionSubFiltersByFilter: [Int:[SectionOfSubFilterModel]] = [:]
    

    // MARK: - Module State:
    private var appliedSubFilters: Set<Int> = Set()
    private var midAppliedSubFilters: Set<Int> = Set()
    private var selectedSubFilters: Set<Int> = Set()
    private var unapplying: Set<Int> = Set()
    
    
    private var currState = UUID()
    private var prevState = UUID()
    
    
    // MARK:
    private var inNextItemsEvent = PublishSubject<[CatalogModel?]>()
    private var offset = 0
    
    
    // MARK: FilterActionDelegate vars
    private var inApplyFromFilterEvent = PublishSubject<Void>()
    private var inApplyFromSubFilterEvent = PublishSubject<Int>()
    private var inRemoveFilterEvent = PublishSubject<Int>()
    private var inSelectSubFilterEvent = PublishSubject<(Int, Bool)>()
    private var outFiltersEvent = BehaviorSubject<[FilterModel?]>(value: [])
    private var outSubFiltersEvent = BehaviorSubject<[SubfilterModel?]>(value: [])
    private var outSectionSubFiltersEvent = BehaviorSubject<[SectionOfSubFilterModel]>(value: [])
    private var outRequestComplete = PublishSubject<Int>()
    private var inCleanUpFromFilterEvent = PublishSubject<Void>()
    private var inCleanUpFromSubFilterEvent = PublishSubject<Int>()
    private var outShowApplyingViewEvent = BehaviorSubject<Bool>(value: false)
    private var outRefreshedCellSelectionsEvent = PublishSubject<Set<Int>>()
    
    public var unitTestSignalOperationComplete = BehaviorSubject<Int>(value: 0)
    public var utMsgId = 0
    
    
    
    init(categoryId: Int = 0){
        
        self.categoryId = categoryId
        super.init()
        
        //network request
        bindData()
        bindUserActivities()
        bindDelegate()
        
        CatalogModel.localTitle(categoryId: categoryId)
            .bind(to: outTitle)
            .disposed(by: bag)
    }
    
   
    public func bindData(){
    
        NetworkMgt.requestCatalogModel(categoryId: categoryId, appliedSubFilters: appliedSubFilters, offset: 0) // true
        
        inNextItemsEvent
        .asObservable()
        .bind(to: outCatalog)
        .disposed(by: bag)
    }
    
    private func bindUserActivities(){
        inPressLayout
            .asObservable()
            .flatMap{[weak self]  _ -> Observable<CellLayout> in
                return self!.changeLayout()
            }
            .bind(to: outLayout)
            .disposed(by: bag)
        
        inPressFilter
            .asObservable()
            .subscribe(onNext: {[weak self] _ in
                if let `self` = self {
                    self.requestFilters(categoryId: self.categoryId)
                    self.outShowFilters.onNext(self.categoryId)
                }
            })
            .disposed(by: bag)
    }
    
    
    private func changeLayout()->Observable<CellLayout>{
        
        switch currCellLayout {
        case .list:
            currCellLayout = .square
            return Observable.of(CellLayout(cellLayoutType: .square, cellScale: CGSize(width: 0.95, height: 0.95), cellSpace: 0, lineSpace: 8, layoutImageName: "square"))
        case .square:
            currCellLayout = .squares
            return Observable.of(CellLayout(cellLayoutType: .squares, cellScale: CGSize(width: 0.5, height: 0.5), cellSpace: 2, lineSpace: 2, layoutImageName: "squares"))
        case .squares:
            currCellLayout = .list
            return Observable.of(CellLayout(cellLayoutType: .list, cellScale: CGSize(width: 0.95, height: 0.25), cellSpace: 0, lineSpace: 8, layoutImageName: "list"))
        }
    }
    
    
    // unit-test function
    public func utRefreshSubFilters(filterId: Int){
       subFiltersFromCache(filterId: filterId)
    }
    
    public func utEnterSubFilter(filterId: Int){
        let fullApplying = self.appliedSubFilters.union(self.midAppliedSubFilters) // added
        NetworkMgt.requestCurrentSubFilterIds(filterId: filterId, appliedSubFilters: fullApplying)
        //NetworkMgt.requestCurrentSubFilterIds(filterId: filterId, appliedSubFilters: self.appliedSubFilters)
    }
    
}


extension CatalogVM : FilterActionDelegate {
    
    func applyFromFilterEvent() -> PublishSubject<Void> {
        return inApplyFromFilterEvent
    }
    
    func applyFromSubFilterEvent() -> PublishSubject<Int> {
        return inApplyFromSubFilterEvent
    }
    
    func removeFilterEvent() -> PublishSubject<Int> {
        return inRemoveFilterEvent
    }
    
    func filtersEvent() -> BehaviorSubject<[FilterModel?]> {
        return outFiltersEvent
    }
    
    func requestFilters(categoryId:Int) {
        if (prevState != currState) {
            NetworkMgt.requestFullFilterEntities(categoryId: categoryId)
            
            prevState = currState
        } else {
            NetworkMgt.requestApplyFromFilter(appliedSubFilters: appliedSubFilters, selectedSubFilters: selectedSubFilters)
        }
        midAppliedSubFilters = appliedSubFilters // added
    }
    
    func subFiltersEvent() -> BehaviorSubject<[SubfilterModel?]> {
        return outSubFiltersEvent
    }
    
    
    func requestSubFilters(filterId: Int) {
        showCleanSubFilterVC(filterId: filterId)
        
       // let fullApplying = self.appliedSubFilters.union(self.midAppliedSubFilters) // added
        NetworkMgt.requestCurrentSubFilterIds(filterId: filterId, appliedSubFilters: self.midAppliedSubFilters) // added
        
       // NetworkMgt.requestCurrentSubFilterIds(filterId: filterId, appliedSubFilters: self.appliedSubFilters)
    }
    
    
    func requestComplete() -> PublishSubject<Int> {
        return outRequestComplete
    }
    
    func sectionSubFiltersEvent() -> BehaviorSubject<[SectionOfSubFilterModel]> {
        return outSectionSubFiltersEvent
    }
    
    func selectSubFilterEvent() -> PublishSubject<(Int, Bool)> {
        return inSelectSubFilterEvent
    }
    
    func cleanupFromFilterEvent() -> PublishSubject<Void> {
        return inCleanUpFromFilterEvent
    }
    
    func cleanupFromSubFilterEvent() -> PublishSubject<Int> {
        return inCleanUpFromSubFilterEvent
    }
    
    func showApplyingViewEvent() -> BehaviorSubject<Bool> {
        return outShowApplyingViewEvent
    }
    
    func refreshedCellSelectionsEvent() -> PublishSubject<Set<Int>> {
        return outRefreshedCellSelectionsEvent
    }
    
    func appliedTitle(filterId: Int) -> String {
        var res = ""
        
        
       // let fullApplied = appliedSubFilters.union(midAppliedSubFilters) // added
        let fullApplied = midAppliedSubFilters // added
        let arr = fullApplied
            .compactMap({subFilters[$0]})
            .filter({$0.filterId == filterId && $0.enabled == true})
        
        
//        let arr = appliedSubFilters
//            .compactMap({subFilters[$0]})
//            .filter({$0.filterId == filterId && $0.enabled == true})
        
        
        
        arr.forEach({ subf in
            res.append(subf.title + ",")
        })
        if res.count > 0 {
            res.removeLast()
        }
        return res
    }
    
    func isSelectedSubFilter(subFilterId: Int) -> Bool {
        var res = false
        res = selectedSubFilters.contains(subFilterId)
        return res
    }
    
    func getTitle(filterId: Int) -> String {
        guard
            let filter = filters[filterId]
            else { return ""}
        
        return filter.title
    }
    
    func getFilterEnum(filterId: Int)->FilterEnum {
        guard
            let filter = filters[filterId]
            else { return .select}
        
        return filter.filterEnum
    }
    

    private func bindDelegate(){
        
        // user activites:
        inApplyFromFilterEvent
            .subscribe(onNext: {[weak self] _ in
                if let `self` = self {
                    self.showCleanFilterVC()
                   
                  //  let applied = self.appliedSubFilters.subtracting(self.unapplying)
                    
                    let midApplying = self.midAppliedSubFilters.subtracting(self.unapplying) // added
                    
                    //let fullApplying = applied.union(applying) // added
                    
                    self.unapplying.removeAll()
                   // self.midAppliedSubFilters.removeAll() // added
                    
                    NetworkMgt.requestApplyFromFilter(appliedSubFilters: midApplying, selectedSubFilters: self.selectedSubFilters) // added
                    
                    //NetworkMgt.requestApplyFromFilter(appliedSubFilters: applied, selectedSubFilters: self.selectedSubFilters)
                }
            })
            .disposed(by: bag)
        
        inApplyFromSubFilterEvent
            .subscribe(onNext: {[weak self] filterId in
                if let `self` = self {
                    
                    
                    //let fullApplying = self.appliedSubFilters.union(self.midAppliedSubFilters) // added
                    let midApplying = self.midAppliedSubFilters // added
                    self.unapplying.removeAll()
                    self.showCleanFilterVC()
                    NetworkMgt.requestApplyFromSubFilter(filterId: filterId, appliedSubFilters: midApplying, selectedSubFilters: self.selectedSubFilters)
                    
                   // NetworkMgt.requestApplyFromSubFilter(filterId: filterId, appliedSubFilters: self.appliedSubFilters, selectedSubFilters: self.selectedSubFilters)
                }
            })
            .disposed(by: bag)
        
        inRemoveFilterEvent
            .subscribe(onNext: {[weak self] filterId in
                if let `self` = self {
                    
                    let midApplying = self.midAppliedSubFilters // added
                    //let fullApplying = self.appliedSubFilters.union(self.midAppliedSubFilters) // added
                    
                    self.unapplying.removeAll()
                    NetworkMgt.requestRemoveFilter(filterId: filterId, appliedSubFilters: midApplying, selectedSubFilters: self.selectedSubFilters) // added
                   // NetworkMgt.requestRemoveFilter(filterId: filterId, appliedSubFilters: self.appliedSubFilters, selectedSubFilters: self.selectedSubFilters)
                }
            })
            .disposed(by: bag)
        
        inSelectSubFilterEvent
            .subscribe(onNext: {[weak self] (subFilterId, selected) in
                self?.selectSubFilter(subFilterId: subFilterId, selected: selected)
            })
            .disposed(by: bag)
        

        inCleanUpFromFilterEvent
            .subscribe(onNext: {[weak self] _ in
                if let `self` = self {
                    self.cleanupAllFilters()
                    NetworkMgt.requestApplyFromFilter(appliedSubFilters: Set(), selectedSubFilters: Set()) // added
                    self.unitTestSignalOperationComplete.onNext(self.utMsgId)
                }
            })
            .disposed(by: bag)
        
        
        inCleanUpFromSubFilterEvent
            .subscribe(onNext: {[weak self] filterId in
                guard let `self` = self else { return }
                guard let ids = self.subfiltersByFilter[filterId] else { return }
                
                let res = Set(ids).intersection(self.selectedSubFilters)
                
                self.outRefreshedCellSelectionsEvent.onNext(res)
                
                for id in ids {
                    self.selectSubFilter(subFilterId: id, selected: false)
                }
                self.unitTestSignalOperationComplete.onNext(self.utMsgId)
            })
            .disposed(by: bag)
        
        
        NetworkMgt.outFullFilterEntities
            .skip(1)
            .subscribe(onNext: { [weak self] res in
                guard let `self` = self else {return}
                let filters = res.0
                let subFilters = res.1
                self.filters.removeAll()
                self.filters = Dictionary(uniqueKeysWithValues: filters.compactMap({$0}).map{ ($0.id, $0) })
                self.subfiltersByFilter.removeAll()
                subFilters.forEach{ subf in
                    if self.subfiltersByFilter[subf.filterId] == nil {
                        self.subfiltersByFilter[subf.filterId] = []
                    }
                    self.subfiltersByFilter[subf.filterId]?.append(subf.id)
                    self.subFilters[subf.id] = subf
                }
                self.fillSectionSubFilters()
                
                self.outFiltersEvent.onNext(self.getEnabledFilters())
            })
            .disposed(by: bag)
        
        
        NetworkMgt.outCurrentSubFilterIds
            .subscribe(onNext: {[weak self] res in
                guard let `self` = self else { return }
                let filterIds = res.1
                self.enableSubFilters(ids: filterIds)
                self.midAppliedSubFilters = res.2 //added
                //self.appliedSubFilters = res.2
                self.subFiltersFromCache(filterId: res.0)
            })
            .disposed(by: bag)

        
        NetworkMgt.outApplyItemsResponse
            .subscribe(onNext: {[weak self] _filters in
                guard let `self` = self else {return}
                self.enableFilters(ids: _filters.0)
                self.enableSubFilters(ids: _filters.1)
                
                self.appliedSubFilters = _filters.2
                self.selectedSubFilters = _filters.3
                self.outFiltersEvent.onNext(self.getEnabledFilters())
             
                NetworkMgt.requestCatalogModel(categoryId: self.categoryId, appliedSubFilters: self.appliedSubFilters, offset: 0)
                
                self.unitTestSignalOperationComplete.onNext(self.utMsgId)
            })
            .disposed(by: bag)
        
        
        NetworkMgt.outApplyFiltersResponse
            .subscribe(onNext: {[weak self] _filters in
                guard let `self` = self else {return}
                self.enableFilters(ids: _filters.0)
                self.enableSubFilters(ids: _filters.1)
                self.midAppliedSubFilters = _filters.2 // added
                //self.appliedSubFilters = _filters.2
                self.selectedSubFilters = _filters.3
                self.outFiltersEvent.onNext(self.getEnabledFilters())
                
                self.unitTestSignalOperationComplete.onNext(self.utMsgId)
            })
            .disposed(by: bag)
        
        
        NetworkMgt.outCatalogModel
            .subscribe(onNext: {[weak self] res in
                guard let `self` = self else { return }
                self.inNextItemsEvent.onNext(res)
            })
            .disposed(by: bag)
    }
}


extension CatalogVM {
    
    private func subFiltersFromCache(filterId: Int){
        
        guard let filter = filters[filterId] else {return}
        
        switch filter.filterEnum {
        case .select:
            var res = [SubfilterModel?]()
            if let ids = self.subfiltersByFilter[filterId] {
                res = self.getEnabledSubFilters(ids: ids)
            }
            self.outSubFiltersEvent.onNext(res)
        case .section:
            if let sections = sectionSubFiltersByFilter[filterId] {
                self.outSectionSubFiltersEvent.onNext(sections)
            }
        default:
            print("todo")
        }
        unitTestSignalOperationComplete.onNext(utMsgId)
    }
    
    
    private func showApplyingView(isSelectNow: Bool){
        if isSelectNow {
            outShowApplyingViewEvent.onNext(true)
            return
        }
        
        if self.appliedSubFilters.isEmpty == false ||
            self.midAppliedSubFilters.isEmpty == false ||
            self.selectedSubFilters.isEmpty == false ||
            self.unapplying.isEmpty == false {
            
            outShowApplyingViewEvent.onNext(true)
            return
        }
        
        outShowApplyingViewEvent.onNext(false)
    }
    
    private func showCleanFilterVC(){
       self.outFiltersEvent.onNext([])
    }
    
    
    private func showCleanSubFilterVC(filterId : Int){
        self.outSubFiltersEvent.onNext([])
        self.outSectionSubFiltersEvent.onNext([])
        // signal-ready to show vc
        self.outRequestComplete.onNext(filterId)
    }
    

    private func fillSectionSubFilters(){
        sectionSubFiltersByFilter.removeAll()
        
        var tmp = [String:[SubfilterModel]]()
        var tmp2 = [SectionOfSubFilterModel]()
        
        for filter in filters {
            if filter.value.filterEnum != .section {
                continue
            }
            tmp.removeAll()
            tmp2.removeAll()
            if let ids = subfiltersByFilter[filter.key] {
                for id in ids {
                    if let subf = subFilters[id] {
                        if tmp[subf.sectionHeader] == nil {
                            tmp[subf.sectionHeader]  = []
                        }
                        tmp[subf.sectionHeader]?.append(subf)
                    }
                }
                for t in tmp {
                    tmp2.append(SectionOfSubFilterModel(header: t.key, items: t.value))
                }
                sectionSubFiltersByFilter[filter.key] = tmp2
            }
        }
    }
    
    private func selectSubFilter(subFilterId: Int, selected: Bool) {

        if appliedSubFilters.contains(subFilterId) ||
            midAppliedSubFilters.contains(subFilterId) {
    
            guard selected == false else {return}
            unapplying.insert(subFilterId)
        }
        
        
        if selected {
            selectedSubFilters.insert(subFilterId)
        } else {
            selectedSubFilters.remove(subFilterId)
        }
        self.showApplyingView(isSelectNow: selected)
    }
    
    private func getEnabledSubFilters(ids: [Int]) -> [SubfilterModel?] {
        let res = ids
            .compactMap({subFilters[$0]})
            .filter({$0.enabled == true})
        return res
    }
    
    private func enableSubFilters(ids: [Int?]) {
        
        for subf in subFilters {
            subf.value.enabled = false
        }
        
        for id in ids {
            if let i = id,
            let subf = subFilters[i] {
                subf.enabled = true
            }
        }
    }
    
    private func getEnabledFilters()->[FilterModel?] {
        return filters
            .compactMap({$0.value})
            .filter({$0.enabled == true})
            .sorted(by: {$0.id < $1.id })
    }
    
    private func enableFilters(ids: [Int?]) {
        
        for subf in filters {
            subf.value.enabled = false
        }
        
        for id in ids {
            if let i = id,
                let subf = filters[i] {
                subf.enabled = true
            }
        }
    }
    
    
    public func cleanupUnapplied(){
        unapplying = []
        midAppliedSubFilters = []
        selectedSubFilters = []
    }
    
    private func cleanupAllFilters(){
        for filter in filters {
            filter.value.enabled = true
        }
        for subf in subFilters {
            subf.value.enabled = true
        }
        unapplying = []
        midAppliedSubFilters = []
        appliedSubFilters = []
        selectedSubFilters = []
    }
}
