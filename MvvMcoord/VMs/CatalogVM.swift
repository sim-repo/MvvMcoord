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


class CatalogVM : BaseVM {
    
    // MARK: --------------properties --------------
    private var currCellLayout: CellLayoutEnum = .squares
    internal var categoryId: Int
    

    // Inputs from ViewController
    var inPressLayout:Variable<Void> = Variable<Void>(Void())
    var inPressFilter = PublishSubject<Void>()
    
    
    // Outputs to ViewController or Coord
    var outTitle = Variable<String>("")
    var outLayout = Variable<CellLayout?>(nil)
    var outShowFilters = PublishSubject<Int>()
    var outCloseVC = PublishSubject<Void>()
    var outReloadVC = PublishSubject<Void>()
    var outFetchComplete = PublishSubject<[IndexPath]?>()
    
    
    // Filters
    internal var filters: [Int:FilterModel] = [:]
    internal var subFilters: [Int:SubfilterModel] = [:]
    internal var subfiltersByFilter: [Int:[Int]] = [:]
    private var sectionSubFiltersByFilter: [Int:[SectionOfSubFilterModel]] = [:]
    

    // Module State:
    internal var appliedSubFilters: Set<Int> = Set()
    internal var midAppliedSubFilters: Set<Int> = Set()
    internal var selectedSubFilters: Set<Int> = Set()
    internal var unapplying: Set<Int> = Set()
    
    
    internal var currState = UUID()
    internal var prevState = UUID()
    
    // optimization: avoid network request
    private var fullCatalogItemIds: [Int] = []
    
    private var catalog: [CatalogModel?] = []
    private var itemIds: [Int] = []
    
    internal var rangePrice = RangePrice.shared
    
    internal var inPrefetchEvent = PublishSubject<[CatalogModel?]>()
    private var isPrefetchInProgress = false
    private var fetchLimit: Int
    public var currentPage: Int
    public var totalPages: Int
    public var totalItems: Int
    
    // MARK: --------------unit test properties--------------
    public var unitTestSignalOperationComplete = BehaviorSubject<Int>(value: -1)
    public var utMsgId = 0
    
    // MARK: --------------FilterActionDelegate properties--------------
    internal var inApplyFromFilterEvent = PublishSubject<Void>()
    internal var inApplyFromSubFilterEvent = PublishSubject<Int>()
    internal var inApplyByPricesEvent = PublishSubject<Void>()
    internal var inRemoveFilterEvent = PublishSubject<Int>()
    internal var inSelectSubFilterEvent = PublishSubject<(Int, Bool)>()
    internal var inCleanUpFromFilterEvent = PublishSubject<Void>()
    internal var inCleanUpFromSubFilterEvent = PublishSubject<Int>()
    
    internal var outFiltersEvent = BehaviorSubject<[FilterModel?]>(value: [])
    internal var outSubFiltersEvent = BehaviorSubject<[SubfilterModel?]>(value: [])
    internal var outSectionSubFiltersEvent = BehaviorSubject<[SectionOfSubFilterModel]>(value: [])
    internal var outRequestComplete = PublishSubject<Int>()
    internal var outShowApplyViewEvent = BehaviorSubject<Bool>(value: false)
    internal var outShowPriceApplyViewEvent = BehaviorSubject<Bool>(value: false)
    internal var outRefreshedCellSelectionsEvent = PublishSubject<Set<Int>>()
    internal var outWaitEvent = BehaviorSubject<(FilterActionEnum, Bool)>(value: (.applyFilter, false))
    
    
    
    internal init(categoryId: Int, fetchLimit: Int, currentPage: Int, totalPages: Int, totalItems: Int){
        self.categoryId = categoryId
        self.fetchLimit = fetchLimit
        self.currentPage = currentPage
        self.totalPages = totalPages
        self.totalItems = totalItems
        super.init()
    
        emitStartEvent()
        handleStartEvent()
        handlePrefetchEvent()
        bindUserActivities()
        
        
        CatalogModel.localTitle(categoryId: categoryId)
            .bind(to: outTitle)
            .disposed(by: bag)
    }
    
    
    // MARK: -------------- Prefetching --------------
    internal func setupFetch(itemsIds: [Int], fetchLimit: Int = 0){
        
        self.itemIds = itemsIds
        self.totalItems = itemIds.count
        if fetchLimit != 0 {
            self.fetchLimit = fetchLimit
        }
        self.currentPage = 1
        if fetchLimit != 0 {
            self.totalPages = self.totalItems/fetchLimit
        }
        catalog = []
    }

    
    private func emitStartEvent(){
        NetworkMgt.requestCatalogStart(categoryId: categoryId, appliedSubFilters: appliedSubFilters)
    }
   
   
    
    private func handleStartEvent(){
        NetworkMgt
            .outCatalogTotal
            .skip(1)
            .subscribe(onNext: { [weak self] res in
                self?.fullCatalogItemIds = res.0
                self?.setupFetch(itemsIds: res.0, fetchLimit: res.1)
                self?.rangePrice.setupRangePrice(minPrice: res.2, maxPrice: res.3)
                self?.outReloadVC.onNext(Void())
                self?.emitPrefetchEvent()
            })
            .disposed(by: bag)
    }
    
    
    public func emitPrefetchEvent(){
        guard isPrefetchInProgress == false else {return}
        guard itemIds.count > 0 else {return}
        
        isPrefetchInProgress = true
        let maxi = itemIds.count-1 < 0 ? 0 : itemIds.count-1
        let maxi2 = currentPage * fetchLimit - 1 < 0 ? 0 : currentPage * fetchLimit - 1
        let from =  (currentPage-1) * fetchLimit
        let to = min(maxi2, maxi)
        
        if itemIds.count >= from {
            let nextItemIds = itemIds[from...to]
            NetworkMgt.requestCatalogModel(itemIds: Array(nextItemIds))
        }
    }
    
    private func handlePrefetchEvent(){
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
            self?.isPrefetchInProgress = false
        })
        .disposed(by: bag)
    }
    
    private func calcIndexPathsToReload(from newCatalog: [CatalogModel?]) -> [IndexPath] {
        let startIndex = catalog.count - newCatalog.count
        let endIndex = startIndex + newCatalog.count
        return (startIndex..<endIndex).map { IndexPath(row: $0, section: 0) }
    }
    
    public func currItemsCount() -> Int {
        return catalog.count
    }
    
    public func catalog(at index: Int) -> CatalogModel? {
        return catalog[index]
    }
    
    
    
    // MARK: -------------- User Actions in Catalog VC --------------
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
    
    
    // MARK: -------------- unit-test functions --------------
    public func utRefreshSubFilters(filterId: Int){
        subFiltersFromCache(filterId: filterId)
    }
    
    public func utEnterSubFilter(filterId: Int){
        requestSubFilters(filterId: filterId)
    }

    
    internal func subFiltersFromCache(filterId: Int){
        
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
    
    internal func resetFilters(){
        cleanupAllFilters()
        itemIds = fullCatalogItemIds
        setupFetch(itemsIds: fullCatalogItemIds)
        outReloadVC.onNext(Void())
        emitPrefetchEvent()
        outFiltersEvent.onNext(self.getEnabledFilters())
        unitTestSignalOperationComplete.onNext(utMsgId)
    }
    
    private func showApplyingView(isSelectNow: Bool){
        if isSelectNow {
            outShowApplyViewEvent.onNext(true)
            return
        }
        
        if self.appliedSubFilters.isEmpty == false ||
            self.midAppliedSubFilters.isEmpty == false ||
            self.selectedSubFilters.isEmpty == false ||
            self.unapplying.isEmpty == false {
            
            outShowApplyViewEvent.onNext(true)
            return
        }
        
        outShowApplyViewEvent.onNext(false)
    }
    
    
    private func showPriceApplyView(){
        outShowPriceApplyViewEvent.onNext(true)
    }
    
    
    internal func showCleanFilterVC(){
       self.outFiltersEvent.onNext([])
    }
    
    
    internal func showCleanSubFilterVC(filterId : Int){
        self.outSubFiltersEvent.onNext([])
        self.outSectionSubFiltersEvent.onNext([])
        // signal-ready to show vc
        self.outRequestComplete.onNext(filterId)
    }
    

    internal func fillSectionSubFilters(){
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
    
    
    internal func selectSubFilter(subFilterId: Int, selected: Bool) {

        if appliedSubFilters.contains(subFilterId) ||
            midAppliedSubFilters.contains(subFilterId) {
    
            if selected == false {
                unapplying.insert(subFilterId)
            }
        }
        
        if selected {
            selectedSubFilters.insert(subFilterId)
        } else {
            selectedSubFilters.remove(subFilterId)
        }
        self.showApplyingView(isSelectNow: selected)
    }
    
    
    internal func getEnabledSubFilters(ids: [Int]) -> [SubfilterModel?] {
        let res = ids
            .compactMap({subFilters[$0]})
            .filter({$0.enabled == true})
        return res
    }
    
    
    internal func enableSubFilters(ids: [Int?], countBySubfilterId: [Int: Int] = [:]) {
        
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
    
    
    internal func getEnabledFilters()->[FilterModel?] {
        return filters
            .compactMap({$0.value})
            .filter({$0.enabled == true})
            .sorted(by: {$0.id < $1.id })
    }
    
    internal func enableFilters(ids: [Int?]) {
        
        for subf in filters.filter({$0.value.filterEnum != FilterEnum.range}) {
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
