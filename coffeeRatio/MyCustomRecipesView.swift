//  MyCustomRecipesView.swift

import SwiftUI

struct MyCustomRecipesView: View {
    @EnvironmentObject var recipeStore: CustomRecipeStore
    @EnvironmentObject var settings: SettingsModel
    @State private var showingAddRecipe = false
    @State private var customTemperature: Int = 94

    var body: some View {
        NavigationView {
            List {
                ForEach(recipeStore.recipes) { recipe in
                    NavigationLink(
                        destination: CustomCoffeeRecipeDetailView(
                            recipeStore: recipeStore,
                            recipe: recipe
                        )
                    ) {
                        Text(recipe.name)
                            .font(.headline)
                            .padding(.vertical, 8)
                    }
                    .swipeActions {
                        Button(role: .destructive) {
                            recipeStore.delete(recipe: recipe)
                        } label: {
                            Label("Sil", systemImage: "trash")
                        }
                    }
                }
            }
            .navigationTitle("Kendi Tariflerim")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddRecipe = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddRecipe) {
                AddCustomRecipeView(
                    temperature: $customTemperature,
                    recipeStore: recipeStore
                )
                .environmentObject(settings)
            }
        }
    }
}

struct MyCustomRecipesView_Previews: PreviewProvider {
    static var previews: some View {
        MyCustomRecipesView()
            .environmentObject(SettingsModel())
            .environmentObject(CustomRecipeStore())
    }
}
