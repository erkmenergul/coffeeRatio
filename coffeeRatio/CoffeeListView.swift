//  coffeelistview.swift

import SwiftUI

struct CoffeeListView: View {
    // Sadece kahve çeşitlerini listeleyen filtre
    var coffeeTypes: [CoffeeRecipe] {
        return coffeeRecipes.filter { recipe in
            [
                "Americano",
                "Latte",
                "Cappuccino",
                "Espresso Macchiato",
                "Latte Macchiato",
                "Mocha",
                "Cortado",
                "Flat White",
                "Türk Kahvesi", "Turkish Coffee",    // Her iki dilde!
                "Ristretto",
                "Marocchino",
                "Affogato",
                "Caramel Macchiato",
                "Filtre Kahve", "Filter Coffee",      // Her iki dilde!
                "Espresso"
            ].contains(recipe.name)
        }.sorted { $0.name < $1.name }
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
            .navigationTitle("Kahve Rehberi")
            .listStyle(PlainListStyle())
        }
    }
}

struct CoffeeListView_Previews: PreviewProvider {
    static var previews: some View {
        CoffeeListView()
    }
}

