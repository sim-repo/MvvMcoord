import Foundation
import RxSwift

var models: [Int:[CategoryModel]] = [:]
var models2: [Int:CategoryModel] = [:]


class CategoryModel{
    var baseId = 0
    var id = 0
    var title: String
    var last = false

    
    init(baseId: Int, id: Int, title: String, last: Bool = false){
        self.baseId = baseId
        self.id = id
        self.title = title
        self.last = last
    }
    
    
    static func fillModels(){
        let woman = CategoryModel(baseId: 00000000, id:1000000, title: "Женщинам")
        let man = CategoryModel(baseId: 00000000, id:2000000, title: "Мужчинам")
        let child = CategoryModel(baseId: 00000000, id:3000000, title: "Детям")
        
        let w11 = CategoryModel(baseId: 01000000, id:10000, title: "Одежда")
        let w12 = CategoryModel(baseId: 01000000, id:20000, title: "Обувь")
        let w13 = CategoryModel(baseId: 01000000, id:30000, title: "Белье")
        let w14 = CategoryModel(baseId: 01000000, id:40000, title: "Пляжная Мода")
        let w15 = CategoryModel(baseId: 01000000, id:50000, title: "Большие Размеры")
        let w16 = CategoryModel(baseId: 01000000, id:60000, title: "Будущие Мамы")
        let w17 = CategoryModel(baseId: 01000000, id:70000, title: "Офис")
        let w18 = CategoryModel(baseId: 01000000, id:80000, title: "Свадьба")
        let w19 = CategoryModel(baseId: 01000000, id:90000, title: "Спецодежда")
        
        let w111 = CategoryModel(baseId: 01010000, id:100, title: "Платья")
        let w112 = CategoryModel(baseId: 01010000, id:200, title: "Футболки и Топы")
        let w113 = CategoryModel(baseId: 01010000, id:300, title: "Брюки и Шорты")
        let w114 = CategoryModel(baseId: 01010000, id:400, title: "Блузки и Рубашки")
        let w115 = CategoryModel(baseId: 01010000, id:500, title: "Джемперы и Кардиганы")
        let w116 = CategoryModel(baseId: 01010000, id:600, title: "Водолазки")
        let w117 = CategoryModel(baseId: 01010000, id:700, title: "Лонгсливы")
        let w118 = CategoryModel(baseId: 01010000, id:800, title: "Юбки")
  
    
        let w121 = CategoryModel(baseId: 01020000, id:100, title: "Кеды и кроссовки")
        let w122 = CategoryModel(baseId: 01020000, id:200, title: "Сандалии")
        let w123 = CategoryModel(baseId: 01020000, id:300, title: "Шлепанцы")
        let w124 = CategoryModel(baseId: 01020000, id:400, title: "Мокасины")
        let w125 = CategoryModel(baseId: 01020000, id:500, title: "Балетки")
        let w126 = CategoryModel(baseId: 01020000, id:600, title: "Сапоги")
        let w127 = CategoryModel(baseId: 01020000, id:700, title: "Туфли")
        let w128 = CategoryModel(baseId: 01020000, id:800, title: "Ботинки")
        
    
        
        let w131 = CategoryModel(baseId: 01030000, id:100, title: "Колготки")
        let w132 = CategoryModel(baseId: 01030000, id:200, title: "Майки")
        let w133 = CategoryModel(baseId: 01030000, id:300, title: "Бандажи")
        
        
        let w141 = CategoryModel(baseId: 01040000, id:100, title: "Аксессуары")
        let w142 = CategoryModel(baseId: 01040000, id:200, title: "Купальники")
        let w143 = CategoryModel(baseId: 01040000, id:300, title: "Одежда")
        
        let w151 = CategoryModel(baseId: 01050000, id:100, title: "Верхняя Одежда")
        let w152 = CategoryModel(baseId: 01050000, id:200, title: "Джинсы и Брюки")
        let w153 = CategoryModel(baseId: 01050000, id:300, title: "Костюмы")
        
        
        let w161 = CategoryModel(baseId: 01060000, id:100, title: "Туники")
        let w162 = CategoryModel(baseId: 01060000, id:200, title: "Одежда для Дома")
        let w163 = CategoryModel(baseId: 01060000, id:300, title: "Пальтя и сарафаны")
        
        
        let w1111 = CategoryModel(baseId: 01010100, id:1, title: "Повседневные Платья", last: true)
        let w1112 = CategoryModel(baseId: 01010100, id:2, title: "Вечерние Платья", last: true)
        let w1113 = CategoryModel(baseId: 01010100, id:3, title: "Вязанные Платья", last: true)
        let w1114 = CategoryModel(baseId: 01010100, id:4, title: "Джинсовые Платья", last: true)
        let w1115 = CategoryModel(baseId: 01010100, id:5, title: "Платья-пиджаки", last: true)
        let w1116 = CategoryModel(baseId: 01010100, id:6, title: "Платья-мини", last: true)
        let w1117 = CategoryModel(baseId: 01010100, id:7, title: "Платья-миди", last: true)
        let w1118 = CategoryModel(baseId: 01010100, id:8, title: "Платья-макси", last: true)
        let w1119 = CategoryModel(baseId: 01010100, id:9, title: "Платья-рубашки", last: true)
       
        
        let w1121 = CategoryModel(baseId: 01010200, id:1, title: "Футболки", last: true)
        let w1122 = CategoryModel(baseId: 01010200, id:2, title: "Футболки-Поло", last: true)
        let w1123 = CategoryModel(baseId: 01010200, id:3, title: "Топы", last: true)
        let w1124 = CategoryModel(baseId: 01010200, id:4, title: "Топы-Бра", last: true)
        let w1125 = CategoryModel(baseId: 01010200, id:5, title: "На тонких бретелях", last: true)
        let w1126 = CategoryModel(baseId: 01010200, id:6, title: "На широких бретелях", last: true)
        
        let w1131 = CategoryModel(baseId: 01010300, id:1, title: "Бермуды", last: true)
        let w1132 = CategoryModel(baseId: 01010400, id:2, title: "Бриджи", last: true)
        let w1133 = CategoryModel(baseId: 01010500, id:3, title: "Топы", last: true)
        let w1134 = CategoryModel(baseId: 01010600, id:4, title: "Брюки", last: true)
        let w1135 = CategoryModel(baseId: 01010700, id:5, title: "Капри", last: true)
        let w1136 = CategoryModel(baseId: 01010800, id:6, title: "Кюлоты", last: true)
        let w1137 = CategoryModel(baseId: 01010900, id:7, title: "Леггинсы", last: true)
        
        
        let w1141 = CategoryModel(baseId: 01010400, id:1, title: "Блузки", last: true)
        let w1142 = CategoryModel(baseId: 01010400, id:2, title: "Блузки-боди", last: true)
        let w1143 = CategoryModel(baseId: 01010400, id:3, title: "Рубашки", last: true)

        
        let w1151 = CategoryModel(baseId: 01010500, id:1, title: "Джемперы", last: true)
        let w1152 = CategoryModel(baseId: 01010500, id:2, title: "Кардиганы", last: true)
        let w1153 = CategoryModel(baseId: 01010500, id:3, title: "Кофточки", last: true)
        let w1154 = CategoryModel(baseId: 01010500, id:4, title: "Кофты", last: true)
        let w1155 = CategoryModel(baseId: 01010500, id:5, title: "Пуловеры", last: true)
        let w1156 = CategoryModel(baseId: 01010500, id:6, title: "Свитеры", last: true)
        let w1157 = CategoryModel(baseId: 01010500, id:7, title: "Твинсеты", last: true)
        
        
        let tmpModels1 = [woman, man, child]
        models[00000000] = tmpModels1
        
        
        let tmpModels2 = [w11, w12, w13, w14,  w15, w16, w17, w18, w19]
        models[woman.baseId + woman.id] = tmpModels2
        
        models2[woman.baseId + woman.id] = woman
        models2[man.baseId + man.id] = man
        models2[child.baseId + child.id] = child
        

        let tmpModels3 = [w111,w112,w113,w114,w115,w116,w117,w118]
        models[w11.baseId + w11.id] = tmpModels3
        models2[w11.baseId + w11.id] = w11
        
        let tmpModels4 = [w121,w122,w123,w124,w125,w126,w127,w128]
        models[w12.baseId + w12.id] = tmpModels4
        models2[w12.baseId + w12.id] = w12
        
        let tmpModels5 = [w131,w132,w133]
        models[w13.baseId + w13.id] = tmpModels5
        models2[w13.baseId + w13.id] = w13
        
        let tmpModels6 = [w141,w142,w143]
        models[w14.baseId + w14.id] = tmpModels6
        models2[w14.baseId + w14.id] = w14
        
        let tmpModels7 = [w151,w152,w153]
        models[w15.baseId + w15.id] = tmpModels7
        models2[w15.baseId + w15.id] = w15
        
        let tmpModels8 = [w161,w162,w163]
        models[w16.baseId + w16.id] = tmpModels8
        models2[w16.baseId + w16.id] = w16
        
        let tmpModels9 = [w1111,w1112,w1113,w1114,w1115,w1116,w1117,w1118,w1119]
        models[w111.baseId + w111.id] = tmpModels9
        models2[w111.baseId + w111.id] = w111
        models2[w1111.baseId + w1111.id] = w1111
        models2[w1112.baseId + w1112.id] = w1112
        models2[w1113.baseId + w1113.id] = w1113
        models2[w1114.baseId + w1114.id] = w1114
        models2[w1115.baseId + w1115.id] = w1115
        models2[w1116.baseId + w1116.id] = w1116
        models2[w1117.baseId + w1117.id] = w1117
        models2[w1118.baseId + w1118.id] = w1118
        models2[w1119.baseId + w1119.id] = w1119
        
        
        
        
        let tmpModels10 = [w1121,w1122,w1123,w1124,w1125, w1126]
        models[w112.baseId + w112.id] = tmpModels10
        models2[w112.baseId + w112.id] = w112
        
        let tmpModels11 = [w1131,w1132,w1133,w1134,w1135, w1136, w1137]
        models[w113.baseId + w113.id] = tmpModels11
        models2[w113.baseId + w113.id] = w113
        
        let tmpModels12 = [w1141,w1142,w1143]
        models[w114.baseId + w114.id] = tmpModels12
        models2[w114.baseId + w114.id] = w114
        
        let tmpModels13 = [w1151,w1152,w1153,w1154,w1155,w1156,w1157]
        models[w115.baseId + w115.id] = tmpModels13
        models2[w115.baseId + w115.id] = w115
    }
    
    
    static func getModelsA(baseId: Int)->Observable<[CategoryModel]?> {
        return Observable.just(models[baseId])

    }
    
    static func getTitle(baseId: Int)->Observable<String> {

        guard
        let parent = models2[baseId]
        else { return .empty()}
        
        return Observable.just(parent.title)
    }
    
    static func checkIsLast(baseId: Int)->Observable<Bool> {
        
        guard
            let parent = models2[baseId]
            else { return .empty()}
        
        return Observable.just(parent.last)
    }
}
