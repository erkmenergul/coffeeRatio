//  coffeeRatioApp.swift

import SwiftUI

struct AlertMessage: Identifiable {
    let id = UUID()
    let message: String
}

@main
struct CoffeeRatioApp: App {
    @StateObject private var recipeStore = CustomRecipeStore()
    @StateObject private var settings    = SettingsModel()
    @StateObject private var store       = StoreManager()
    @State private var importAlertMessage: AlertMessage? = nil

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environmentObject(recipeStore)
                .environmentObject(settings)
                .environmentObject(store)
                .preferredColorScheme(settings.darkModeEnabled ? ColorScheme.dark : ColorScheme.light)
                .onAppear {
                    guard settings.notificationsEnabled else { return }
                    NotificationsManager.shared.requestAuthorization()
                    NotificationsManager.shared.scheduleWeeklyRecipeSuggestion()
                }
                .onOpenURL { url in
                    handleImport(url: url)
                }
                .alert(item: $importAlertMessage) { alertMessage in
                    Alert(title: Text(alertMessage.message))
                }
        }
    }

    private func handleImport(url: URL) {
        // Önemli: security-scoped resource erişimini aç
        let accessing = url.startAccessingSecurityScopedResource()
        defer {
            if accessing { url.stopAccessingSecurityScopedResource() }
        }
        do {
            let fileManager = FileManager.default
            let tempUrl = fileManager.temporaryDirectory.appendingPathComponent(url.lastPathComponent)
            if url != tempUrl {
                if fileManager.fileExists(atPath: tempUrl.path) {
                    try? fileManager.removeItem(at: tempUrl)
                }
                try fileManager.copyItem(at: url, to: tempUrl)
            }
            let data = try Data(contentsOf: tempUrl)
            let decoder = JSONDecoder()
            let importedRecipe = try decoder.decode(CustomCoffeeRecipe.self, from: data)
            if !recipeStore.recipes.contains(where: { $0.id == importedRecipe.id }) {
                recipeStore.recipes.append(importedRecipe)
                importAlertMessage = AlertMessage(message: NSLocalizedString("import_success", comment: ""))
            } else {
                importAlertMessage = AlertMessage(message: NSLocalizedString("import_duplicate", comment: ""))
            }
        } catch {
            print("IMPORT ERROR:", error)
            importAlertMessage = AlertMessage(message: NSLocalizedString("import_error", comment: ""))
        }
    }
}

// Eğer MainTabView bu dosyada tanımlı değilse, aşağıdaki şekilde ekle (veya ayrı dosyada tanımlıysa sil):

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
