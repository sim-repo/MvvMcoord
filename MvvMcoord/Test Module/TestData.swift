import Foundation



class TestData {

    static func loadFilters() -> [FilterModel] {
        var tmp: [FilterModel] = []
        
        let f00 = FilterModel(id:0, title: "Цена", categoryId: 01010101, filterEnum: .range)
        let f10 = FilterModel(id:1, title: "Бренд", categoryId: 01010101, filterEnum: .section)
        let f11 = FilterModel(id:2, title: "Размер", categoryId: 01010101)
        let f12 = FilterModel(id:3, title: "Сезон", categoryId: 01010101)
        let f13 = FilterModel(id:4, title: "Состав", categoryId: 01010101)
        let f14 = FilterModel(id:5, title: "Срок доставки", categoryId: 01010101)
        let f15 = FilterModel(id:6, title: "Цвет", categoryId: 01010101)
        let f16 = FilterModel(id:7, title: "Вид застежки", categoryId: 01010101)
        let f17 = FilterModel(id:8, title: "Вырез горловины", categoryId: 01010101)
        let f18 = FilterModel(id:9, title: "Декоративные элементы", categoryId: 01010101)
        let f19 = FilterModel(id:10, title: "Длина юбки/платья", categoryId: 01010101)
        let f20 = FilterModel(id:11, title: "Конструктивные элементы", categoryId: 01010101)
        let f21 = FilterModel(id:12, title: "Тип рукава", categoryId: 01010101)
        let f22 = FilterModel(id:13, title: "Цена2", categoryId: 01010101, filterEnum: .range)
        tmp.append(contentsOf: [f00, f10,f11,f12,f13,f14,f15,f16,f17,f18,f19,f20,f21])
        return tmp
    }
    
    
    static func loadSubFilters(filterId: Int = 0) -> [SubfilterModel] {
        var tmp: [SubfilterModel] = []
        
        // Brands
        
        let f10 = SubfilterModel(id:1, filterId: 1, title: "Abby", sectionHeader: "A")
        let f11 = SubfilterModel(id:2, filterId: 1, title: "ABODIE", sectionHeader: "A")
        let f12 = SubfilterModel(id:3, filterId: 1, title: "Acasta", sectionHeader: "A")
        let f13 = SubfilterModel(id:4, filterId: 1, title: "Adelante", sectionHeader: "A")
        let f14 = SubfilterModel(id:5, filterId: 1, title: "Adele", sectionHeader: "A")
        let f15 = SubfilterModel(id:6, filterId: 1, title: "Adelin Fostayn", sectionHeader: "A")
        let f16 = SubfilterModel(id:7, filterId: 1, title: "Adidas", sectionHeader: "A")
        let f17 = SubfilterModel(id:8, filterId: 1, title: "ADZHERO", sectionHeader: "A")
        let f18 = SubfilterModel(id:9, filterId: 1, title: "Aelite", sectionHeader: "A")
        let f19 = SubfilterModel(id:10, filterId: 1, title: "AFFARI", sectionHeader: "A")
        let f20 = SubfilterModel(id:11, filterId: 1, title: "B&Co", sectionHeader: "B")
        let f21 = SubfilterModel(id:12, filterId: 1, title: "B&H", sectionHeader: "B")
        let f22 = SubfilterModel(id:13, filterId: 1, title: "Babylon", sectionHeader: "B")
        let f23 = SubfilterModel(id:14, filterId: 1, title: "Balasko", sectionHeader: "B")
        let f24 = SubfilterModel(id:15, filterId: 1, title: "Baon", sectionHeader: "B")
        let f25 = SubfilterModel(id:16, filterId: 1, title: "Barboleta", sectionHeader: "B")
        let f26 = SubfilterModel(id:17, filterId: 1, title: "Barcelonica", sectionHeader: "B")
        let f27 = SubfilterModel(id:18, filterId: 1, title: "Barkhat", sectionHeader: "B")
        let f28 = SubfilterModel(id:19, filterId: 1, title: "Basia", sectionHeader: "B")
        let f29 = SubfilterModel(id:20, filterId: 1, title: "C.H.I.C", sectionHeader: "C")
        let f30 = SubfilterModel(id:21, filterId: 1, title: "Calista", sectionHeader: "C")
        let f31 = SubfilterModel(id:22, filterId: 1, title: "Calvin Klein", sectionHeader: "C")
        
        let f32 = SubfilterModel(id:23, filterId: 1, title: "Camelia", sectionHeader: "C")
        let f33 = SubfilterModel(id:24, filterId: 1, title: "Camelot", sectionHeader: "C")
        let f34 = SubfilterModel(id:25, filterId: 1, title: "Can Nong", sectionHeader: "C")
        let f35 = SubfilterModel(id:26, filterId: 1, title: "Caprice", sectionHeader: "C")
        let f36 = SubfilterModel(id:27, filterId: 1, title: "Camart", sectionHeader: "C")
        if filterId == 1 || filterId == 0{
            tmp.append(contentsOf: [f10,f11,f12,f13,f14,f15,f16,f17,f18,f19,f20,f21,f22, f23, f24, f25, f26, f27, f28, f29, f30 ,f31, f32, f33, f34, f35, f36])
        }
        
        // Size
        
        let size34 = SubfilterModel(id:28, filterId: 2, title: "34")
        let size36 = SubfilterModel(id:29, filterId: 2, title: "36")
        let size37 = SubfilterModel(id:30, filterId: 2, title: "37")
        let size38 = SubfilterModel(id:31, filterId: 2, title: "38")
        let size39 = SubfilterModel(id:32, filterId: 2, title: "39")
        let size40 = SubfilterModel(id:33, filterId: 2, title: "40")
        let size41 = SubfilterModel(id:34, filterId: 2, title: "41")
        let size42 = SubfilterModel(id:35, filterId: 2, title: "42")
        let size43 = SubfilterModel(id:37, filterId: 2, title: "43")
        let size44 = SubfilterModel(id:38, filterId: 2, title: "44")
        let size45 = SubfilterModel(id:39, filterId: 2, title: "45")
        let size46 = SubfilterModel(id:40, filterId: 2, title: "46")
        let size47 = SubfilterModel(id:41, filterId: 2, title: "47")
        let size48 = SubfilterModel(id:42, filterId: 2, title: "48")
        if filterId == 2  || filterId == 0{
            tmp.append(contentsOf: [size34, size36, size37, size38, size39, size40, size41, size42, size43, size44, size45, size46, size47, size48])
        }
        
        // Season
        
        let демисезон = SubfilterModel(id:43, filterId: 3, title: "демисезон")
        let зима = SubfilterModel(id:44, filterId: 3, title: "зима")
        let круглогодичный = SubfilterModel(id:45, filterId: 3, title: "круглогодичный")
        let лето = SubfilterModel(id:46, filterId: 3, title: "лето")
        if filterId == 3  || filterId == 0{
            tmp.append(contentsOf: [демисезон, зима, круглогодичный, лето])
        }
        
        
        // Materials
        
        let ангора = SubfilterModel(id:47, filterId: 4, title: "ангора")
        let вискоза = SubfilterModel(id:48, filterId: 4, title: "вискоза")
        let полиамид = SubfilterModel(id:49, filterId: 4, title: "полиамид")
        let полиуретан = SubfilterModel(id:50, filterId: 4, title: "полиуретан")
        let полиэстер = SubfilterModel(id:51, filterId: 4, title: "полиэстер")
        let хлопок = SubfilterModel(id:52, filterId: 4, title: "хлопок")
        let шелк = SubfilterModel(id:53, filterId: 4, title: "шелк")
        let шерсть = SubfilterModel(id:54, filterId: 4, title: "шерсть")
        let эластан = SubfilterModel(id:55, filterId: 4, title: "эластан")
        if filterId == 4  || filterId == 0{
            tmp.append(contentsOf: [ангора, вискоза, полиамид, полиуретан, полиэстер, хлопок, шелк, шерсть, эластан])
        }
        
        
        // Delivery
        
        let день1 = SubfilterModel(id:56, filterId: 5, title: "1 день")
        let дня3 = SubfilterModel(id:57, filterId: 5, title: "3 дня")
        let дня4 = SubfilterModel(id:58, filterId: 5, title: "4 дня")
        let дней5 = SubfilterModel(id:59, filterId: 5, title: "5 дней")
        if filterId == 5  || filterId == 0{
            tmp.append(contentsOf: [день1, дня3, дня4, дней5])
        }
        
        
        
        // Color
        
        let бежевый = SubfilterModel(id:60, filterId: 6, title: "бежевый")
        let белый = SubfilterModel(id:61, filterId: 6, title: "белый")
        let голубой = SubfilterModel(id:62, filterId: 6, title: "голубой")
        let желтый = SubfilterModel(id:63, filterId: 6, title: "желтый")
        let зеленый = SubfilterModel(id:64, filterId: 6, title: "зеленый")
        let коричневый = SubfilterModel(id:65, filterId: 6, title: "коричневый")
        let красный = SubfilterModel(id:66, filterId: 6, title: "красный")
        let оранжевый = SubfilterModel(id:67, filterId: 6, title: "оранжевый")
        let розовый = SubfilterModel(id:68, filterId: 6, title: "розовый")
        let серый = SubfilterModel(id:69, filterId: 6, title: "серый")
        let синий = SubfilterModel(id:70, filterId: 6, title: "синий")
        let фиолетовый = SubfilterModel(id:71, filterId: 6, title: "фиолетовый")
        let черный = SubfilterModel(id:72, filterId: 6, title: "черный")
        
        if filterId == 6  || filterId == 0{
            tmp.append(contentsOf: [бежевый, белый, голубой, желтый, зеленый, коричневый, красный, оранжевый, розовый, серый, синий, фиолетовый, черный ])
        }
        
        if BackendLogic.shared.getSubfByItem().isEmpty {
            
            
            BackendLogic.shared.addSubfByFilter(id: 2, arr: [28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41])
            BackendLogic.shared.addSubfByFilter(id: 3, arr: [43, 44, 45, 46])
            BackendLogic.shared.addSubfByFilter(id: 4, arr: [47, 48, 49, 50, 51, 52, 53, 54, 55])
            BackendLogic.shared.addSubfByFilter(id: 5, arr: [56, 57, 58, 59])
            BackendLogic.shared.addSubfByFilter(id: 6, arr: [28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41])

            
            
            
            
            
            
            
            BackendLogic.shared.subfByItem(item: 3,  subfilters: [f11.id, size38.id, круглогодичный.id, полиамид.id,    дня4.id,    желтый.id])
            BackendLogic.shared.subfByItem(item: 7,  subfilters: [f13.id, size42.id, круглогодичный.id, полиэстер.id,   дня4.id,    оранжевый.id])
            BackendLogic.shared.subfByItem(item: 11, subfilters: [f14.id, size46.id, круглогодичный.id, полиуретан.id,  дня4.id,    фиолетовый.id])
            BackendLogic.shared.subfByItem(item: 17, subfilters: [f17.id, size34.id, круглогодичный.id, эластан.id,     день1.id,   коричневый.id])
            BackendLogic.shared.subfByItem(item: 21, subfilters: [f20.id, size34.id, демисезон.id,      вискоза.id,     день1.id,   желтый.id])
            BackendLogic.shared.subfByItem(item: 2,  subfilters: [f11.id, size36.id, демисезон.id,      вискоза.id,     дня3.id,    желтый.id])
            BackendLogic.shared.subfByItem(item: 5,  subfilters: [f12.id, size40.id, демисезон.id,      вискоза.id,     день1.id,   коричневый.id])
            BackendLogic.shared.subfByItem(item: 9,  subfilters: [f14.id, size44.id, демисезон.id,      вискоза.id,     день1.id,   коричневый.id])
            BackendLogic.shared.subfByItem(item: 14, subfilters: [f16.id, size36.id, демисезон.id,      шерсть.id,      дня3.id,    черный.id])
            BackendLogic.shared.subfByItem(item: 15, subfilters: [f17.id, size36.id, демисезон.id,      шерсть.id,      дня3.id,    красный.id])
            BackendLogic.shared.subfByItem(item: 23, subfilters: [f22.id, size34.id, демисезон.id,      шерсть.id,      дня4.id,    фиолетовый.id])
            BackendLogic.shared.subfByItem(item: 19, subfilters: [f18.id, size34.id, демисезон.id,      шерсть.id,      дня4.id,    оранжевый.id])
            BackendLogic.shared.subfByItem(item: 25, subfilters: [f23.id, size34.id, зима.id,           ангора.id,      день1.id,   синий.id])
            BackendLogic.shared.subfByItem(item: 29, subfilters: [f25.id, size34.id, зима.id,           ангора.id,      день1.id,   синий.id])
            BackendLogic.shared.subfByItem(item: 33, subfilters: [f28.id, size34.id, зима.id,           ангора.id,      день1.id,   синий.id])
            BackendLogic.shared.subfByItem(item: 37, subfilters: [f30.id, size34.id, зима.id,           ангора.id,      день1.id,   синий.id])
            BackendLogic.shared.subfByItem(item: 1,  subfilters: [f10.id, size34.id, зима.id,           ангора.id,      день1.id,   синий.id])
            BackendLogic.shared.subfByItem(item: 10, subfilters: [f14.id, size36.id, зима.id,           ангора.id,      дня4.id,    синий.id])
            BackendLogic.shared.subfByItem(item: 28, subfilters: [f24.id, size34.id, зима.id,           ангора.id,      дня4.id,    синий.id])
            BackendLogic.shared.subfByItem(item: 6,  subfilters: [f12.id, size36.id, зима.id,           шерсть.id,      дня4.id,    синий.id])
            BackendLogic.shared.subfByItem(item: 24, subfilters: [f22.id, size36.id, зима.id,           шерсть.id,      дня4.id,    синий.id])
            BackendLogic.shared.subfByItem(item: 13, subfilters: [f15.id, size34.id, зима.id,           шерсть.id,      дня4.id,    белый.id])
            BackendLogic.shared.subfByItem(item: 32, subfilters: [f27.id, size34.id, зима.id,           шерсть.id,      дня4.id,    белый.id])
            BackendLogic.shared.subfByItem(item: 16, subfilters: [f17.id, size34.id, зима.id,           шерсть.id,      дня4.id,    белый.id])
            BackendLogic.shared.subfByItem(item: 20, subfilters: [f19.id, size34.id, зима.id,           шерсть.id,      дня4.id,    белый.id])
            BackendLogic.shared.subfByItem(item: 27, subfilters: [f24.id, size34.id, зима.id,           эластан.id,     дня4.id,    белый.id])
            BackendLogic.shared.subfByItem(item: 36, subfilters: [f30.id, size34.id, зима.id,           эластан.id,     дня4.id,    белый.id])
            BackendLogic.shared.subfByItem(item: 4,  subfilters: [f12.id, size39.id, лето.id,           хлопок.id,      день1.id,   зеленый.id])
            BackendLogic.shared.subfByItem(item: 8,  subfilters: [f14.id, size42.id, лето.id,           хлопок.id,      день1.id,   розовый.id])
            BackendLogic.shared.subfByItem(item: 12, subfilters: [f15.id, size36.id, лето.id,           хлопок.id,      день1.id,   черный.id])
            BackendLogic.shared.subfByItem(item: 18, subfilters: [f18.id, size36.id, лето.id,           хлопок.id,      день1.id,   черный.id])
            BackendLogic.shared.subfByItem(item: 22, subfilters: [f21.id, size36.id, лето.id,           шелк.id,        день1.id,   черный.id])
            BackendLogic.shared.subfByItem(item: 26, subfilters: [f23.id, size34.id, лето.id,           шелк.id,        дня3.id,    белый.id])
            BackendLogic.shared.subfByItem(item: 30, subfilters: [f26.id, size45.id, лето.id,           шелк.id,        дня3.id,    бежевый.id])
            BackendLogic.shared.subfByItem(item: 31, subfilters: [f27.id, size34.id, лето.id,           эластан.id,     дня3.id,    белый.id])
            BackendLogic.shared.subfByItem(item: 34, subfilters: [f29.id, size34.id, лето.id,           эластан.id,     дня3.id,    белый.id])
            BackendLogic.shared.subfByItem(item: 35, subfilters: [f29.id, size34.id, лето.id,           эластан.id,     дня3.id,    белый.id])
            
            // демисезон -> вискоза, шерсть
            // зима -> ангора, шерсть, эластан
            // лето -> хлопок, шелк, вискоза
            // круглогодичный -> полиамид, полиэстер, полиуретан, эластан
        }
        
        return tmp
    }
    
    static func loadCatalogs(categoryId: Int) -> [Int:[CatalogModel]]{
        var tmp: [Int:[CatalogModel]] = [:]
        
        if categoryId == 01010101 {
            let w1 = [
                CatalogModel(id: 1, categoryId: 01010101, name: "ЗимАнгора1син", thumbnail: "pic", stars: 3, newPrice: 4500, oldPrice: 6500, votes: 145, discount: 30),
                CatalogModel(id: 2, categoryId: 01010101, name: "ДемВиск3Жел", thumbnail: "pic2", stars: 1, newPrice: 4700, oldPrice: 5200, votes: 245, discount: 30),
                CatalogModel(id: 3, categoryId: 01010101, name: "КругПолиам4Жел", thumbnail: "pic5", stars: 4, newPrice: 2200, oldPrice: 3000, votes: 545, discount: 50),
                CatalogModel(id: 4, categoryId: 01010101, name: "Лхлопок1зел", thumbnail: "pic6", stars: 5, newPrice: 5500, oldPrice: 7500, votes: 45, discount: 50),
                CatalogModel(id: 5, categoryId: 01010101, name: "ДемВиск1кор", thumbnail: "pic7", stars: 1, newPrice: 4555, oldPrice: 6400, votes: 45, discount: 50),
                CatalogModel(id: 6, categoryId: 01010101, name: "ЗимШерсть4син", thumbnail: "pic", stars: 2, newPrice: 4555, oldPrice: 6350, votes: 45, discount: 40),
                CatalogModel(id: 7, categoryId: 01010101, name: "КругПолиэс4оран", thumbnail: "pic2", stars: 2, newPrice: 5800, oldPrice: 8400, votes: 1, discount: 40),
                CatalogModel(id: 8, categoryId: 01010101, name: "ЛетХлопок1роз", thumbnail: "pic5", stars: 3, newPrice: 8540, oldPrice: 10500, votes: 433, discount: 40),
                CatalogModel(id: 9, categoryId: 01010101, name: "ДемВиск1кор", thumbnail: "pic6", stars: 4, newPrice: 9000, oldPrice: 11200, votes: 1003, discount: 30),
                CatalogModel(id: 10, categoryId: 01010101, name: "ЗимАнгора4син", thumbnail: "pic7", stars: 4, newPrice: 3000, oldPrice: 4700, votes: 445, discount: 30),
                CatalogModel(id: 11, categoryId: 01010101, name: "КругПолиурэт4фио", thumbnail: "pic", stars: 4, newPrice: 4555, oldPrice: 6500, votes: 33, discount: 20),
                CatalogModel(id: 12, categoryId: 01010101, name: "ЛетХлопок1чер", thumbnail: "pic2", stars: 5, newPrice: 4555, oldPrice: 6500, votes: 54, discount: 20),
                CatalogModel(id: 13, categoryId: 01010101, name: "ЗимШерсть4бел", thumbnail: "pic5", stars: 5, newPrice: 4555, oldPrice: 6500, votes: 45, discount: 30),
                CatalogModel(id: 14, categoryId: 01010101, name: "ДемШерсть3чер", thumbnail: "pic6", stars: 4, newPrice: 4555, oldPrice: 6500, votes: 45, discount: 40),
                CatalogModel(id: 15, categoryId: 01010101, name: "ДемШерсть3крас", thumbnail: "pic7", stars: 1, newPrice: 4555, oldPrice: 6500, votes: 45, discount: 25),
                CatalogModel(id: 16, categoryId: 01010101, name: "ЗимШерсть4бел", thumbnail: "pic", stars: 2, newPrice: 4555, oldPrice: 6500, votes: 45, discount: 35),
                CatalogModel(id: 17, categoryId: 01010101, name: "КругЭласт1кор", thumbnail: "pic2", stars: 2, newPrice: 4555, oldPrice: 6500, votes: 45, discount: 50),
                CatalogModel(id: 18, categoryId: 01010101, name: "ЛетХлопок1чер", thumbnail: "pic5", stars: 2, newPrice: 4555, oldPrice: 6500, votes: 45, discount: 50),
                CatalogModel(id: 19, categoryId: 01010101, name: "ДемШерсть4оран", thumbnail: "pic6", stars: 1, newPrice: 4555, oldPrice: 6500, votes: 45, discount: 50),
                CatalogModel(id: 20, categoryId: 01010101, name: "ЗимШерсть4бел", thumbnail: "pic7", stars: 3, newPrice: 4555, oldPrice: 6500, votes: 45, discount: 40),
                CatalogModel(id: 21, categoryId: 01010101, name: "ДемВиск1Жел", thumbnail: "pic10", stars: 3, newPrice: 4555, oldPrice: 6500, votes: 45, discount: 30),
                CatalogModel(id: 22, categoryId: 01010101, name: "ЛетШелк1чер", thumbnail: "pic10", stars: 3, newPrice: 4555, oldPrice: 6500, votes: 45, discount: 50),
                CatalogModel(id: 23, categoryId: 01010101, name: "ДемШерсть4фио", thumbnail: "pic12", stars: 3, newPrice: 4555, oldPrice: 6500, votes: 45, discount: 50),
                CatalogModel(id: 24, categoryId: 01010101, name: "ЗимШерсть4син", thumbnail: "pic14", stars: 3, newPrice: 4555, oldPrice: 6500, votes: 45, discount: 50),
                CatalogModel(id: 25, categoryId: 01010101, name: "ЗимАнгора1син", thumbnail: "pic16", stars: 3, newPrice: 4555, oldPrice: 6500, votes: 45, discount: 50),
                CatalogModel(id: 26, categoryId: 01010101, name: "ЛетШелк3бел", thumbnail: "pic18", stars: 3, newPrice: 4555, oldPrice: 6500, votes: 45, discount: 50),
                CatalogModel(id: 27, categoryId: 01010101, name: "ЗимЭластан4бел", thumbnail: "pic10", stars: 3, newPrice: 4555, oldPrice: 6500, votes: 45, discount: 50),
                CatalogModel(id: 28, categoryId: 01010101, name: "ЗимАнгора4син", thumbnail: "pic12", stars: 3, newPrice: 4555, oldPrice: 6500, votes: 45, discount: 50),
                CatalogModel(id: 29, categoryId: 01010101, name: "ЗимАнгора1син", thumbnail: "pic14", stars: 3, newPrice: 4555, oldPrice: 6500, votes: 45, discount: 50),
                CatalogModel(id: 30, categoryId: 01010101, name: "ЛетШелк3беж", thumbnail: "pic18", stars: 3, newPrice: 4555, oldPrice: 6500, votes: 45, discount: 50),
                CatalogModel(id: 31, categoryId: 01010101, name: "ЛетЭдаст3бел", thumbnail: "pic", stars: 3, newPrice: 4555, oldPrice: 6500, votes: 45, discount: 50),
                CatalogModel(id: 32, categoryId: 01010101, name: "ЗимШерсть4бел", thumbnail: "pic", stars: 3, newPrice: 4555, oldPrice: 6500, votes: 45, discount: 50),
                CatalogModel(id: 33, categoryId: 01010101, name: "ЗимАнгора1син", thumbnail: "pic", stars: 3, newPrice: 4555, oldPrice: 6500, votes: 45, discount: 50),
                CatalogModel(id: 34, categoryId: 01010101, name: "ЛетЭласт3бел", thumbnail: "pic", stars: 3, newPrice: 4555, oldPrice: 6500, votes: 45, discount: 50),
                CatalogModel(id: 35, categoryId: 01010101, name: "ЛетЭласт3бел", thumbnail: "pic", stars: 3, newPrice: 4555, oldPrice: 6500, votes: 45, discount: 50),
                CatalogModel(id: 36, categoryId: 01010101, name: "ЗимЭласт4бел", thumbnail: "pic", stars: 3, newPrice: 4555, oldPrice: 6500, votes: 45, discount: 50),
                CatalogModel(id: 37, categoryId: 01010101, name: "ЗимАнгора1син", thumbnail: "pic", stars: 3, newPrice: 4555, oldPrice: 6500, votes: 45, discount: 50)
                ]
            tmp[01010101] = w1
        }
        
//
//
//        if categoryId == 01010102 {
//            let w2 = [
//                CatalogModel(id: 22, categoryId: 01010102, name: "B&H", thumbnail: "pic10", stars: 3, newPrice: 4555, oldPrice: 6500, votes: 45, discount: 50),
//                CatalogModel(id: 23, categoryId: 01010102, name: "Babylon", thumbnail: "pic12", stars: 3, newPrice: 4555, oldPrice: 6500, votes: 45, discount: 50),
//                CatalogModel(id: 24, categoryId: 01010102, name: "Babylon", thumbnail: "pic14", stars: 3, newPrice: 4555, oldPrice: 6500, votes: 45, discount: 50),
//                CatalogModel(id: 25, categoryId: 01010102, name: "Balasko", thumbnail: "pic16", stars: 3, newPrice: 4555, oldPrice: 6500, votes: 45, discount: 50),
//                CatalogModel(id: 26, categoryId: 01010102, name: "Balasko", thumbnail: "pic18", stars: 3, newPrice: 4555, oldPrice: 6500, votes: 45, discount: 50),
//                CatalogModel(id: 27, categoryId: 01010102, name: "Baon", thumbnail: "pic10", stars: 3, newPrice: 4555, oldPrice: 6500, votes: 45, discount: 50),
//                CatalogModel(id: 28, categoryId: 01010102, name: "Baon", thumbnail: "pic12", stars: 3, newPrice: 4555, oldPrice: 6500, votes: 45, discount: 50),
//                CatalogModel(id: 29, categoryId: 01010102, name: "Barboleta", thumbnail: "pic14", stars: 3, newPrice: 4555, oldPrice: 6500, votes: 45, discount: 50),
//                CatalogModel(id: 30, categoryId: 01010102, name: "Barcelonica", thumbnail: "pic18", stars: 3, newPrice: 4555, oldPrice: 6500, votes: 45, discount: 50)
//            ]
//            tmp[01010102] = w2
//        }
//
//
//        if categoryId == 01010103 {
//            let w3 = [
//                CatalogModel(id: 31, categoryId: 01010103, name: "Barkhat", thumbnail: "pic", stars: 3, newPrice: 4555, oldPrice: 6500, votes: 45, discount: 50),
//                CatalogModel(id: 32, categoryId: 01010103, name: "Barkhat", thumbnail: "pic", stars: 3, newPrice: 4555, oldPrice: 6500, votes: 45, discount: 50),
//                CatalogModel(id: 33, categoryId: 01010103, name: "Basia", thumbnail: "pic", stars: 3, newPrice: 4555, oldPrice: 6500, votes: 45, discount: 50),
//                CatalogModel(id: 34, categoryId: 01010103, name: "C.H.I.C", thumbnail: "pic", stars: 3, newPrice: 4555, oldPrice: 6500, votes: 45, discount: 50),
//                CatalogModel(id: 35, categoryId: 01010103, name: "C.H.I.C", thumbnail: "pic", stars: 3, newPrice: 4555, oldPrice: 6500, votes: 45, discount: 50),
//                CatalogModel(id: 36, categoryId: 01010103, name: "Calista", thumbnail: "pic", stars: 3, newPrice: 4555, oldPrice: 6500, votes: 45, discount: 50),
//                CatalogModel(id: 37, categoryId: 01010103, name: "Calista", thumbnail: "pic", stars: 3, newPrice: 4555, oldPrice: 6500, votes: 45, discount: 50)
//            ]
//            tmp[01010103] = w3
//        }
        return tmp
    }
    
}
