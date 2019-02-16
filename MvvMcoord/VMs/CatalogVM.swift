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
    func wait() -> BehaviorSubject<(FilterActionEnum, Bool)>
}


class CatalogVM : BaseVM {
    
    private var currCellLayout: CellLayoutEnum = .squares
    private var categoryId: Int
    
    
    
    // MARK: - Inputs from ViewController
    var inPressLayout:Variable<Void> = Variable<Void>(Void())
    var inPressFilter = PublishSubject<Void>()
    
    
    // MARK: - Outputs to ViewController or Coord
    //var outCatalog = PublishSubject<[CatalogModel?]>()
    var outTitle = Variable<String>("")
    var outLayout = Variable<CellLayout?>(nil)
    var outShowFilters = PublishSubject<Int>()
    var outCloseVC = PublishSubject<Void>()
    var outReloadVC = PublishSubject<Void>()
    var outFetchComplete = PublishSubject<[IndexPath]?>()
    
    private let activityIndicatorView = UIActivityIndicatorView(style: .whiteLarge)
    
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
    private var fullItemIds: [Int] = []
    
    
    
    private var inPrefetchEvent = PublishSubject<[CatalogModel?]>()
    private var fetchLimit = 0
    public var currentPage = 1
    public var total = 0
    private var isFetchInProgress = false
    public var catalog: [CatalogModel?] = []
    private var itemIds: [Int] = []
    public var totalPages = 0
    
    
    
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
    private var outWaitEvent = BehaviorSubject<(FilterActionEnum, Bool)>(value: (.applyFilter, false))
    
    public var unitTestSignalOperationComplete = BehaviorSubject<Int>(value: 0)
    public var utMsgId = 0
    
    
    
    init(categoryId: Int = 0){
        
        self.categoryId = categoryId
        super.init()
        

        emitTotalEvent()
        handleTotalEvent()
        
        handlePrefetchEvent()
        
        bindUserActivities()
        bindDelegate()
        
        CatalogModel.localTitle(categoryId: categoryId)
            .bind(to: outTitle)
            .disposed(by: bag)
    }
    
    
    private func setupFetch(itemsIds: [Int], fetchLimit: Int = 0){
        
        self.itemIds = itemsIds
        self.total = itemIds.count
        if fetchLimit != 0 {
            self.fetchLimit = fetchLimit
        }
        self.currentPage = 1
        if fetchLimit != 0 {
            self.totalPages = self.total/fetchLimit
        }
        catalog = []
    }
    
    public func emitTotalEvent(){
        NetworkMgt.requestCatalogTotal(categoryId: categoryId, appliedSubFilters: appliedSubFilters)
    }
   
    private func handleTotalEvent(){
        NetworkMgt
            .outCatalogTotal
            .skip(1)
            .subscribe(onNext: { [weak self] res in
                self?.fullItemIds = res.0
                self?.setupFetch(itemsIds: res.0, fetchLimit: res.1)
                self?.outReloadVC.onNext(Void())
                self?.emitPrefetchEvent()
            })
            .disposed(by: bag)
    }
    
    
    public func currItemsCount() -> Int {
        return catalog.count
    }
    
    public func emitPrefetchEvent(){
        guard isFetchInProgress == false else {return}
        
        isFetchInProgress = true
        let maxi = itemIds.count-1 < 0 ? 0 : itemIds.count-1
        let from =  (currentPage-1) * fetchLimit
        let to = min(currentPage * fetchLimit - 1, maxi)
        
        if itemIds.count >= from {
            let nextItemIds = itemIds[from...to]
            NetworkMgt.requestCatalogModel(categoryId: categoryId, itemIds: Array(nextItemIds))
        }
    }
    
    public func handlePrefetchEvent(){
        
        inPrefetchEvent
        .subscribe(onNext: {[weak self] res in
            print("handlePrefetchEvent")
            switch self?.currentPage {
                case 1: self?.catalog = res
                default: self?.catalog.append(contentsOf: res)
            }
            let indexPathsToReload = self?.calcIndexPathsToReload(from: res)
            self?.outFetchComplete.onNext(indexPathsToReload)
            self?.currentPage += 1
            self?.isFetchInProgress = false
        })
        .disposed(by: bag)
    }
    
    public func catalog(at index: Int) -> CatalogModel? {
        return catalog[index]
    }
    
    
    private func calcIndexPathsToReload(from newCatalog: [CatalogModel?]) -> [IndexPath] {
        let startIndex = catalog.count - newCatalog.count
        let endIndex = startIndex + newCatalog.count
        return (startIndex..<endIndex).map { IndexPath(row: $0, section: 0) }
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
            return Observable.of(CellLayout(cellLayoutType: .list, cellScale: CGSize(width: 0.90, height: 0.25), cellSpace: 0, lineSpace: 8, layoutImageName: "list"))
        }
    }
    
    
    // unit-test function
    public func utRefreshSubFilters(filterId: Int){
       subFiltersFromCache(filterId: filterId)
    }
    
    public func utEnterSubFilter(filterId: Int){
        NetworkMgt.requestEnterSubFilter(filterId: filterId, appliedSubFilters: self.midAppliedSubFilters)
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
            wait().onNext((.enterFilter, true))
            NetworkMgt.requestFullFilterEntities(categoryId: categoryId)
            prevState = currState
        } else {
            
        //    NetworkMgt.requestApplyFromFilter(appliedSubFilters: appliedSubFilters, selectedSubFilters: selectedSubFilters)
        }
        midAppliedSubFilters = appliedSubFilters // crytical! зависит работа applySubfilter
        selectedSubFilters = appliedSubFilters // crytical! зависит работа applySubfilter
    }
    
    func subFiltersEvent() -> BehaviorSubject<[SubfilterModel?]> {
        return outSubFiltersEvent
    }
    
    
    func requestSubFilters(filterId: Int) {
        wait().onNext((.enterSubFilter, true))
        showCleanSubFilterVC(filterId: filterId)
        NetworkMgt.requestEnterSubFilter(filterId: filterId, appliedSubFilters: self.midAppliedSubFilters)
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
    
    func wait() -> BehaviorSubject<(FilterActionEnum, Bool)> {
        return outWaitEvent
    }
    
    
    
    func appliedTitle(filterId: Int) -> String {
        var res = ""
        let arr = midAppliedSubFilters
            .compactMap({subFilters[$0]})
            .filter({$0.filterId == filterId && $0.enabled == true})
        
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
        res = selectedSubFilters.contains(subFilterId) || appliedSubFilters.contains(subFilterId)
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
                
                    
                    let midApplying = self.midAppliedSubFilters.subtracting(self.unapplying)
                    
                    if midApplying.count == 0 {
                        self.cleanupAllFilters()
                        self.itemIds = self.fullItemIds
                        self.setupFetch(itemsIds: self.fullItemIds)
                        self.outReloadVC.onNext(Void())
                        self.emitPrefetchEvent()
                        return
                    }
                    self.showCleanFilterVC()
                    self.unapplying.removeAll()
                    self.wait().onNext((.applyFilter, true))
                    NetworkMgt.requestApplyFromFilter(categoryId: self.categoryId, appliedSubFilters: midApplying, selectedSubFilters: self.selectedSubFilters)
                }
            })
            .disposed(by: bag)
        
        inApplyFromSubFilterEvent
            .subscribe(onNext: {[weak self] filterId in
                if let `self` = self {
                    let midApplying = self.midAppliedSubFilters
                    self.wait().onNext((.applySubFilter, true))
                    self.unapplying.removeAll()
                    self.showCleanFilterVC()
                    NetworkMgt.requestApplyFromSubFilter(filterId: filterId, appliedSubFilters: midApplying, selectedSubFilters: self.selectedSubFilters)
                }
            })
            .disposed(by: bag)
        
        inRemoveFilterEvent
            .subscribe(onNext: {[weak self] filterId in
                if let `self` = self {
                    self.wait().onNext((.removeFilter, true))
                    let midApplying = self.midAppliedSubFilters
                    self.unapplying.removeAll()
                    NetworkMgt.requestRemoveFilter(filterId: filterId, appliedSubFilters: midApplying, selectedSubFilters: self.selectedSubFilters)
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
                    self.itemIds = self.fullItemIds
                   // NetworkMgt.requestApplyFromFilter(categoryId: self.categoryId, appliedSubFilters: Set(), selectedSubFilters: Set())
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
        
        
        NetworkMgt.outFilterEntitiesResponse
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
                self.wait().onNext((.enterFilter, false))
            })
            .disposed(by: bag)
        
        
        NetworkMgt.outEnterSubFilterResponse
            .subscribe(onNext: {[weak self] res in
                guard let `self` = self else { return }
                let filterIds = res.1
                let countBySubfilterId = res.3
                self.enableSubFilters(ids: filterIds, countBySubfilterId: countBySubfilterId)
                self.midAppliedSubFilters = res.2
                self.subFiltersFromCache(filterId: res.0)
                self.wait().onNext((.enterSubFilter, false))
            })
            .disposed(by: bag)

        
        NetworkMgt.outApplyItemsResponse
            .subscribe(onNext: {[weak self] _filters in
                print("NetworkMgt.outApplyItemsResponse")
                guard let `self` = self else {return}
                self.enableFilters(ids: _filters.0)
                self.enableSubFilters(ids: _filters.1)
                
                self.appliedSubFilters = _filters.2
                self.selectedSubFilters = _filters.3
                self.outFiltersEvent.onNext(self.getEnabledFilters())
                self.setupFetch(itemsIds: _filters.4)
                self.outReloadVC.onNext(Void())
                self.emitPrefetchEvent()
                self.wait().onNext((.applyFilter, false))
                
                self.unitTestSignalOperationComplete.onNext(self.utMsgId)
            })
            .disposed(by: bag)
        
        
        NetworkMgt.outApplyFiltersResponse
            .subscribe(onNext: {[weak self] _filters in
                guard let `self` = self else {return}
                self.enableFilters(ids: _filters.0)
                self.enableSubFilters(ids: _filters.1)
                self.midAppliedSubFilters = _filters.2
                self.selectedSubFilters = _filters.3
                self.outFiltersEvent.onNext(self.getEnabledFilters())
                self.wait().onNext((.applySubFilter, false))
                
                self.unitTestSignalOperationComplete.onNext(self.utMsgId)
            })
            .disposed(by: bag)
        
        
        NetworkMgt.outCatalogModel
            .subscribe(onNext: {[weak self] res in
                guard let `self` = self else { return }
                self.inPrefetchEvent.onNext(res)
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
    
    private func enableSubFilters(ids: [Int?], countBySubfilterId: [Int: Int] = [:]) {
        
        for subf in subFilters {
            subf.value.enabled = false
        }
        
        for id in ids {
            if let i = id,
            let subf = subFilters[i] {
                if let cnt = countBySubfilterId[i] {
                    subf.countItems = cnt
                }
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
