//  MyCustomRecipesView.swift

import SwiftUI

struct MyCustomRecipesView: View {
    @EnvironmentObject var recipeStore: CustomRecipeStore
    @EnvironmentObject var settings: SettingsModel
    @EnvironmentObject var store: StoreManager
    @State private var showingAddRecipe = false
    @State private var customTemperature: Int = 94
    @State private var showPremiumSheet = false

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
                .onMove(perform: recipeStore.move) // Sürükleyip sıralama özelliği
            }
            .navigationTitle("Kendi Tariflerim")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    EditButton() // Düzenleme modunu açar
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        if store.isPurchased {
                            showingAddRecipe = true
                        } else {
                            showPremiumSheet = true
                        }
                    }) {
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
            .sheet(isPresented: $showPremiumSheet) {
                PremiumInfoView()
            }
        }
        .navigationViewStyle(.stack)  // ← iPad'de split yerine stack modu
    }
}

struct MyCustomRecipesView_Previews: PreviewProvider {
    static var previews: some View {
        MyCustomRecipesView()
            .environmentObject(SettingsModel())
            .environmentObject(CustomRecipeStore())
            .environmentObject(StoreManager())
    }
}
