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
        case "Türk Kahvesi", "Turkish Coffee":
                return "turkKahvesi"      // Assets: "turkKahvesi"
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
        case "Filtre Kahve", "Filter Coffee":
                return "filtreKahve"       // Assets: "filtreKahve"
        default: return "defaultCoffee"
        }
    }
    
    /// Sertlik (hardness) skoru: 10 en yüksek, 1 en düşük (sıralama için kullanılır; listede gösterilmeyecek)
    var hardness: Int {
        switch name {
        case "Ristretto": return 10
        case "Espresso": return 9
        case "Espresso Macchiato": return 9
        case "Türk Kahvesi", "Turkish Coffee":
                return 8
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
        case "Filtre Kahve", "Filter Coffee":
            return 5
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
        brewTime: NSLocalizedString("espresso_brew_time", comment: ""),
        instructions: NSLocalizedString("espresso_instructions", comment: "")
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
        name: NSLocalizedString("turkish_coffee_name", comment: ""),
        coffeeAmount: "7gr",
        waterAmount: "70ml",
        brewTime: NSLocalizedString("turkish_coffee_brew_time", comment: ""),
        instructions: NSLocalizedString("turkish_coffee_instructions", comment: "")
    ),
    CoffeeRecipe(
        name: "Americano",
        coffeeAmount: "18gr",
        waterAmount: NSLocalizedString("americano_water_amount", comment: ""),
        brewTime: NSLocalizedString("americano_brew_time", comment: ""),
        instructions: NSLocalizedString("americano_instructions", comment: "")
    ),
    CoffeeRecipe(
        name: "Latte",
        coffeeAmount: "18gr",
        waterAmount: NSLocalizedString("latte_water_amount", comment: ""),
        brewTime: NSLocalizedString("latte_brew_time", comment: ""),
        instructions: NSLocalizedString("latte_instructions", comment: "")
    ),
    CoffeeRecipe(
        name: "Cappuccino",
        coffeeAmount: "18gr",
        waterAmount: NSLocalizedString("cappuccino_water_amount", comment: ""),
        brewTime: NSLocalizedString("cappuccino_brew_time", comment: ""),
        instructions: NSLocalizedString("cappuccino_instructions", comment: "")
    ),
    CoffeeRecipe(
        name: "Espresso Macchiato",
        coffeeAmount: "18gr",
        waterAmount: NSLocalizedString("espresso_macchiato_water_amount", comment: ""),
        brewTime: NSLocalizedString("espresso_macchiato_brew_time", comment: ""),
        instructions: NSLocalizedString("espresso_macchiato_instructions", comment: "")
    ),
    CoffeeRecipe(
        name: "Latte Macchiato",
        coffeeAmount: "18gr",
        waterAmount: NSLocalizedString("latte_macchiato_water_amount", comment: ""),
        brewTime: NSLocalizedString("latte_macchiato_brew_time", comment: ""),
        instructions: NSLocalizedString("latte_macchiato_instructions", comment: "")
    ),
    CoffeeRecipe(
        name: "Mocha",
        coffeeAmount: "18gr",
        waterAmount: NSLocalizedString("mocha_water_amount", comment: ""),
        brewTime: NSLocalizedString("mocha_brew_time", comment: ""),
        instructions: NSLocalizedString("mocha_instructions", comment: "")
    ),
    CoffeeRecipe(
        name: "Cortado",
        coffeeAmount: "18gr",
        waterAmount: NSLocalizedString("cortado_water_amount", comment: ""),
        brewTime: NSLocalizedString("cortado_brew_time", comment: ""),
        instructions: NSLocalizedString("cortado_instructions", comment: "")
    ),
    CoffeeRecipe(
        name: "Flat White",
        coffeeAmount: "18gr",
        waterAmount: NSLocalizedString("flat_white_water_amount", comment: ""),
        brewTime: NSLocalizedString("flat_white_brew_time", comment: ""),
        instructions: NSLocalizedString("flat_white_instructions", comment: "")
    ),
    CoffeeRecipe(
        name: "Ristretto",
        coffeeAmount: "18gr",
        waterAmount: NSLocalizedString("ristretto_water_amount", comment: ""),
        brewTime: NSLocalizedString("ristretto_brew_time", comment: ""),
        instructions: NSLocalizedString("ristretto_instructions", comment: "")
    ),
    // Yeni Kahve Çeşitleri:
    CoffeeRecipe(
        name: "Marocchino",
        coffeeAmount: "18gr",
        waterAmount: NSLocalizedString("marocchino_water_amount", comment: ""),
        brewTime: NSLocalizedString("marocchino_brew_time", comment: ""),
        instructions: NSLocalizedString("marocchino_instructions", comment: "")
    ),
    CoffeeRecipe(
        name: "Affogato",
        coffeeAmount: "18gr",
        waterAmount: NSLocalizedString("affogato_water_amount", comment: ""),
        brewTime: NSLocalizedString("affogato_brew_time", comment: ""),
        instructions: NSLocalizedString("affogato_instructions", comment: "")
    ),
    CoffeeRecipe(
        name: "Caramel Macchiato",
        coffeeAmount: "18gr",
        waterAmount: NSLocalizedString("caramel_macchiato_water_amount", comment: ""),
        brewTime: NSLocalizedString("caramel_macchiato_brew_time", comment: ""),
        instructions: NSLocalizedString("caramel_macchiato_instructions", comment: "")
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
        name: NSLocalizedString("filter_coffee_name", comment: ""),
        coffeeAmount: "15gr",
        waterAmount: "225ml",
        brewTime: NSLocalizedString("filter_coffee_brew_time", comment: ""),
        instructions: NSLocalizedString("filter_coffee_instructions", comment: "")
    )
]


