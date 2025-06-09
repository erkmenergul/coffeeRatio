//  coffeeRatioApp.swift

import SwiftUI

@main
struct CoffeeRatioApp: App {
    @StateObject private var recipeStore = CustomRecipeStore()
    @StateObject private var settings    = SettingsModel()
    @StateObject private var store       = StoreManager() // <-- StoreManager eklendi

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environmentObject(recipeStore)
                .environmentObject(settings)
                .environmentObject(store) // <-- StoreManager'ı environment olarak ekle
                // Tema ayarı
                .preferredColorScheme(settings.darkModeEnabled ? .dark : .light)
                .onAppear {
                    guard settings.notificationsEnabled else { return }
                    // Bildirim izni iste ve haftalık öneri planla
                    NotificationsManager.shared.requestAuthorization()
                    NotificationsManager.shared.scheduleWeeklyRecipeSuggestion()
                }
        }
    }
}

struct MainTabView: View {
    @EnvironmentObject private var settings: SettingsModel

    var body: some View {
        TabView {
            CoffeeRehberiView()
                .tabItem { Label("Genel Tarifler", systemImage: "cup.and.saucer.fill") }

            BrewingMethodsView()
                .tabItem { Label("Demleme Yöntemleri", systemImage: "timer") }

            MyCustomRecipesView()
                .tabItem { Label("Kendi Tariflerim", systemImage: "person.crop.circle") }

            SettingsView()
                .tabItem { Label("Ayarlar", systemImage: "gear") }
        }
    }
}
