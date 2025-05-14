//  BrewingMethodsView.swift

import SwiftUI

struct BrewingMethodsView: View {
    // Kullanmak istediğiniz demleme yöntemlerinin isimleri
    var methods: [CoffeeRecipe] {
        let methodsArray = ["French Press", "Pour Over (V60)", "AeroPress", "Moka Pot", "Syphon", "Chemex"]
        return coffeeRecipes.filter { methodsArray.contains($0.name) }
    }
    
    var body: some View {
        NavigationView {
            List(methods) { recipe in
                NavigationLink(destination: destinationView(for: recipe)) {
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
            .navigationTitle("Demleme Yöntemleri")
            .listStyle(PlainListStyle())
        }
    }
    
    // Yardımcı fonksiyon, her demleme yöntemi için ilgili view'ı döndürüyor.
    @ViewBuilder
    func destinationView(for recipe: CoffeeRecipe) -> some View {
        if recipe.name == "French Press" {
            FrenchPressView()
        } else if recipe.name == "Pour Over (V60)" {
            PourOverView()
        } else if recipe.name == "AeroPress" {
            AeroPressView()
        } else if recipe.name == "Moka Pot" {
            MokaPotView()
        } else if recipe.name == "Syphon" {
            SyphonView()
        } else if recipe.name == "Chemex" {
            ChemexView()
        } else {
            CoffeeDetailView(recipe: recipe)
        }
    }
}

struct BrewingMethodsView_Previews: PreviewProvider {
    static var previews: some View {
        BrewingMethodsView()
    }
}

