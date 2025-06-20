//  coffeerehberiview.swift

import SwiftUI

struct CoffeeRehberiView: View {
    // Sadece kahve çeşitlerini listeleyen filtre
    var coffeeTypes: [CoffeeRecipe] {
        let order = [
            "Ristretto",
            "Espresso",
            "Espresso Macchiato",
            "Türk Kahvesi", "Turkish Coffee",      // Ekledik
            "Americano",
            "Filtre Kahve", "Filter Coffee",       // Ekledik
            "Cortado",
            "Marocchino",
            "Affogato",
            "Caramel Macchiato",
            "Flat White",
            "Latte",
            "Cappuccino",
            "Mocha",
            "Latte Macchiato"
        ]
        // Global coffeeRecipes dizisinden sadece order içerisinde yer alan tarifleri alır ve sıralar.
        return coffeeRecipes.filter { recipe in
            order.contains(recipe.name)
        }
        .sorted { first, second in
            guard let index1 = order.firstIndex(of: first.name),
                  let index2 = order.firstIndex(of: second.name)
            else {
                return false
            }
            return index1 < index2
        }
    }
    
    var body: some View {
        NavigationView {
            List(coffeeTypes) { recipe in
                NavigationLink(destination: CoffeeDetailView(recipe: recipe)) {
                    HStack(spacing: 12) {
                        Image(recipe.imageName)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 40, height: 40)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                        Text(recipe.name)
                            .font(.headline)
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle("Tarifler")
            .listStyle(PlainListStyle())
        }
        .navigationViewStyle(.stack)  // ← iPad'de split yerine stack modu
    }
}

struct CoffeeRehberiView_Previews: PreviewProvider {
    static var previews: some View {
        CoffeeRehberiView()
    }
}
