//  ContentView.swift

import Foundation

struct CoffeeRecipe: Identifiable, Codable {
    var id = UUID()
    let name: String
    let coffeeAmount: String
    let waterAmount: String
    let brewTime: String
    let instructions: String
}

extension CoffeeRecipe {
    var imageName: String {
        switch name {
        case "Espresso": return "espresso"              // Assets: "espresso"
        case "French Press": return "frenchPress"      // Assets: "frenchPress"
        case "Pour Over (V60)": return "pourOver"      // Assets: "pourOver"
        case "AeroPress": return "aeroPress"           // Assets: "aeroPress"
        case "Moka Pot": return "mokaPot"              // Assets: "mokaPot"
        case "Türk Kahvesi": return "turkKahvesi"      // Assets: "turkKahvesi"
        case "Americano": return "americano"           // Assets: "americano"
        case "Latte": return "latte"                   // Assets: "latte"
        case "Cappuccino": return "cappuccino"         // Assets: "cappuccino"
        case "Espresso Macchiato": return "espressoMacchiato"  // Assets: "espressoMacchiato"
        case "Latte Macchiato": return "latteMacchiato"  // Assets: "latteMacchiato"
        case "Mocha": return "mocha"                   // Assets: "mocha"
        case "Cortado": return "cortado"               // Assets: "cortado"
        case "Flat White": return "flatWhite"          // Assets: "flatWhite"
        case "Ristretto": return "ristretto"           // Assets: "ristretto"
        case "Marocchino": return "marocchino"         // Assets: "marocchino"
        case "Affogato": return "affogato"             // Assets: "affogato"
        case "Caramel Macchiato": return "caramelMacchiato"  // Assets: "caramelMacchiato"
        case "Syphon": return "syphon"                 // Assets: "syphon"
        case "Chemex": return "chemex"                 // Assets: "chemex"
        case "Filtre Kahve": return "filtreKahve"       // Assets: "filtreKahve"
        default: return "defaultCoffee"
        }
    }
    
    /// Sertlik (hardness) skoru: 10 en yüksek, 1 en düşük (sıralama için kullanılır; listede gösterilmeyecek)
    var hardness: Int {
        switch name {
        case "Ristretto": return 10
        case "Espresso": return 9
        case "Espresso Macchiato": return 9
        case "Türk Kahvesi": return 8
        case "Marocchino": return 8
        case "Cortado": return 8
        case "French Press": return 7
        case "Pour Over (V60)": return 7
        case "AeroPress": return 7
        case "Moka Pot": return 7
        case "Syphon": return 7
        case "Chemex": return 7
        case "Flat White": return 6
        case "Americano": return 5
        case "Filtre Kahve": return 5
        case "Latte": return 4
        case "Cappuccino": return 4
        case "Latte Macchiato": return 3
        case "Mocha": return 4
        case "Affogato": return 7
        case "Caramel Macchiato": return 7
        default: return 5
        }
    }
}

let coffeeRecipes: [CoffeeRecipe] = [
    CoffeeRecipe(
        name: "Espresso",
        coffeeAmount: "18gr",
        waterAmount: "36ml",
        brewTime: "25-30 saniye",
        instructions: "Kahveyi ince kalınlıkta öğütün. 18gr kahveyi makinenizin portafiltresine yerleştirin ve 25-30 saniyede 36ml espresso elde edin."
    ),
    CoffeeRecipe(
        name: "French Press",
        coffeeAmount: "15gr",
        waterAmount: "225ml",
        brewTime: "4 dakika",
        instructions: "French Pressi sıcak su ile ısıtın.Orta kalınlıkta öğütülmüş 15gr kahveyi koyun. Üzerine 225ml sıcak suyu yavaş yavaş dökün.Yaklaşık 4 dakika bekleyin ve ardından pistonu yavaşça aşağı itin."
    ),
    CoffeeRecipe(
        name: "Pour Over (V60)",
        coffeeAmount: "15gr",
        waterAmount: "230ml",
        brewTime: "3 dakika",
        instructions: "Önce kağıt filtreyi koyun, su ile yıkayın ve suyu boşaltın.Orta kalınlıkta öğütülmüş 15gr kahveyi filtreye yerleştirin. Suyu yavaşça ve dairesel hareketlerle dökmeye başlayın.2 ya da 3 kişilik yapmak isterseniz kahve miktarının 15 katı kadar su ilave edin."
    ),
    CoffeeRecipe(
        name: "AeroPress",
        coffeeAmount: "15gr",
        waterAmount: "210ml",
        brewTime: "1-2 dakika",
        instructions: "Aeropressi ters çevirin ve orta kalınlıkta öğütülmüş 15gr kahveyi koyun.Üzerine 200-210ml sıcak suyu yavaşça ekleyin.Kaşık ile karıştırın.Kağıt filtreyi yıkayın ve yerleştirin.Üst kapağını kapattıktan sonra 1-2 dakika demlenmesine müsaade edin.Ters çevirip bardak üstüne koyun ve yavaşça üst tarafından bastırın."
    ),
    CoffeeRecipe(
        name: "Moka Pot",
        coffeeAmount: "14gr",
        waterAmount: "160ml",
        brewTime: "4-6 dakika",
        instructions: "Alt haznede vida hizasına kadar sıcak su koyun.Orta kalınlıkta öğütülmüş 14gr kahveyi MokaPotun kahve haznesine koyun.Kısık ateşte yaklaşık 4-6 dakika bekleyin.Kahvenin üst kısma tamamen çıkmasını bekleyin."
    ),
    CoffeeRecipe(
        name: "Türk Kahvesi",
        coffeeAmount: "7gr",
        waterAmount: "70ml",
        brewTime: "3-5 dakika",
        instructions: "İnce öğütülmüş 7gr kahveyi cezveye koyun, 70ml su (isteğe bağlı şeker) ekleyin. Kısık ateşte yavaşça pişirin ve karıştırmayın.Köpük oluşunca cezveyi ocaktan alın."
    ),
    CoffeeRecipe(
        name: "Americano",
        coffeeAmount: "18gr",
        waterAmount: "36ml espresso,90ml su",
        brewTime: "Espresso: 25-30 saniye",
        instructions: "Öncelikle 18gr kahveden 36ml espresso elde edin.Ardından 90ml sıcak su ekleyerek Americano hazırlayın.İstediğiniz sertlik oranına göre ekleyeceğiniz su oranını ayarlayın."
    ),
    CoffeeRecipe(
        name: "Latte",
        coffeeAmount: "18gr",
        waterAmount: "36ml espresso,180ml süt/süt kreması",
        brewTime: "Espresso: 25-30 saniye",
        instructions: "18gr kahveden 36ml espresso elde edin.180ml ısıtılmış sütü veya buhar çubuğuyla hazırladığınız süt kremasını ekleyerek hazırlayın."
    ),
    CoffeeRecipe(
        name: "Cappuccino",
        coffeeAmount: "18gr",
        waterAmount: "36ml espresso,50ml süt,50ml süt köpüğü",
        brewTime: "Espresso: 25-30 saniye",
        instructions: "18gr kahveden 36ml espresso elde edin.Eşit oranlarda 50ml ısıtılmış süt ve süt köpüğünü ekleyerek hazırlayın."
    ),
    CoffeeRecipe(
        name: "Espresso Macchiato",
        coffeeAmount: "18gr",
        waterAmount: "36ml espresso",
        brewTime: "Espresso: 25-30 saniye",
        instructions: "18gr kahveden 36ml espresso elde edin. Üzerine az miktarda(1-2 kaşık) süt köpüğü ekleyerek espresso macchiato hazırlayın."
    ),
    CoffeeRecipe(
        name: "Latte Macchiato",
        coffeeAmount: "18gr",
        waterAmount: "36ml espresso, 200ml süt(bol köpük)",
        brewTime: "Espresso: 25-30 saniye",
        instructions: "Büyük bir bardağa 200ml ısıtılmış süt dökün, ardından yavaşça espresso ekleyerek latte macchiato hazırlayın. Katmanlar belirgin olacaktır."
    ),
    CoffeeRecipe(
        name: "Mocha",
        coffeeAmount: "18gr",
        waterAmount: "36ml espresso, 150ml süt",
        brewTime: "Espresso: 25-30 saniye",
        instructions: "18gr kahveden 36ml espresso elde edin.Espressoya 20gr çikolata şurubu ya da eritilmiş çikolata ekleyin, ardından 150ml ısıtılmış süt ilave edin. İsteğe bağlı süt kreması ekleyin."
    ),
    CoffeeRecipe(
        name: "Cortado",
        coffeeAmount: "18gr",
        waterAmount: "36ml espresso,36ml süt",
        brewTime: "Espresso: 25-30 saniye",
        instructions: "18gr kahveden 36ml espresso elde edin.Ardından 36ml ısıtılmış süt ekleyerek  hazırlayın."
    ),
    CoffeeRecipe(
        name: "Flat White",
        coffeeAmount: "18gr",
        waterAmount: "36ml espresso,120ml süt",
        brewTime: "Espresso: 25-30 saniye",
        instructions: "18gr kahveden 36ml espresso elde edin. Ardından 120ml ısıtılmış süt ekleyerek  hazırlayın."
    ),
    CoffeeRecipe(
        name: "Ristretto",
        coffeeAmount: "18gr",
        waterAmount: "20ml",
        brewTime: "20-25 saniye",
        instructions: "18gr kahveden, normal espressoya göre daha az su kullanarak 20ml ristretto elde edin. Daha yoğun ve aromatik bir shot..."
    ),
    // Yeni Kahve Çeşitleri:
    CoffeeRecipe(
        name: "Marocchino",
        coffeeAmount: "18gr",
        waterAmount: "36ml espresso,20ml süt köpüğü",
        brewTime: "25-30 saniye",
        instructions: "Bardağın tabanına sıcak çikolata ya da kakao ekleyin.Üzerine espresso ve ince bir süt köpüğü ekleyin.İsteğe bağlı en üste rendelenmiş çikolata ekleyebilirsiniz."
    ),
    CoffeeRecipe(
        name: "Affogato",
        coffeeAmount: "18gr",
        waterAmount: "36ml",
        brewTime: "25-30 saniye",
        instructions: "Bir top vanilyalı dondurmanın üzerine sıcak espressoyu dökün."
    ),
    CoffeeRecipe(
        name: "Caramel Macchiato",
        coffeeAmount: "18gr",
        waterAmount: "36ml espresso,150ml süt",
        brewTime: "Espresso: 25-30 saniye",
        instructions: "Bardağın tabanına karamelli sos ekleyin.Isıtılmış süt/süt köpüğünü ve espressoyu üzerine dökün.Üzerini karamel sos ile süsleyin."
    ),
    // Yeni Kahve Demleme Yöntemleri:
    CoffeeRecipe(
        name: "Syphon",
        coffeeAmount: "20gr",
        waterAmount: "300ml",
        brewTime: "3-4 dakika",
        instructions: "Syphonun alt kısmını ılık suyla dodurun.Üst bölümü ve filtreyi yerleştirin.Orta kalınlıkta öğütülmüş 20gr kahveyi üst kısma koyun.Altındaki ısıtıcıyı açın ve suyun ısınarak yukarı çıkmasını keyifle izleyin.Bütün su yukarı çıkınca ısıtıcıyı kapatın ve kahvenin alt hazneye inmesini bekleyin."
    ),
    CoffeeRecipe(
        name: "Chemex",
        coffeeAmount: "22gr",
        waterAmount: "300ml",
        brewTime: "3-4 dakika",
        instructions: "Önce kağıt filtreyi koyun, su ile yıkayın ve suyu boşaltın.Orta kalınlıkta öğütülmüş 22gr kahveyi filtreye yerleştirin. Suyu yavaşça ve dairesel hareketlerle dökmeye başlayın.2 ya da 3 kişilik yapmak isterseniz kahve miktarının 15 katı kadar su ilave edin."
    ),
    CoffeeRecipe(
        name: "Filtre Kahve",
        coffeeAmount: "15gr",
        waterAmount: "225ml",
        brewTime: "5-8 dakika",
        instructions: "Orta kalınlıkta öğütülmüş 15gr kahveyi filtreye koyun.Makinenizi çalıştırın.2 ya da 3 kişilik yapmak isterseniz kahve miktarının yaklaşık 15 katı kadar su ilave edin."
        )
]


