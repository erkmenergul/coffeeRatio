// CoffeeRatioApp.swift (tam dosya)
import SwiftUI
import UserNotifications
import UIKit

struct AlertMessage: Identifiable {
    let id = UUID()
    let message: String
}

@main
struct CoffeeRatioApp: App {
    // 🔧 AppDelegate’i çok erken aşamada bağla
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    @StateObject private var recipeStore = CustomRecipeStore()
    @StateObject private var settings    = SettingsModel()
    @StateObject private var store       = StoreManager()

    @Environment(\.scenePhase) private var scenePhase

    @State private var importAlertMessage: AlertMessage? = nil
    @State private var pendingRecipeName: String? = nil

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environmentObject(recipeStore)
                .environmentObject(settings)
                .environmentObject(store)
                .preferredColorScheme(settings.darkModeEnabled ? .dark : .light)

                // App açıldığında: (1) delegate zaten AppDelegate’de, (2) varsa bekleyen tarif adını oku
                .onAppear {
                    // Kullanıcı bildirimleri kapattıysa planlama yapma
                    if settings.notificationsEnabled {
                        NotificationsManager.shared.requestAuthorization()
                        NotificationsManager.shared.scheduleWeeklyRecipeSuggestion()
                    }

                    // 🔧 Soğuk başlatma: didReceive tetiklenmeden önce tarif adı yazılmış olabilir
                    if let name = UserDefaults.standard.string(forKey: "launchRecipeName") {
                        UserDefaults.standard.removeObject(forKey: "launchRecipeName")
                        pendingRecipeName = name
                        tryPresentPendingRecipe()
                    }
                }

                // NotificationsManager -> .openRecipeDetail post ederse yakala
                .onReceive(NotificationCenter.default.publisher(for: .openRecipeDetail)) { note in
                    if let name = note.userInfo?["recipeName"] as? String {
                        pendingRecipeName = name
                        tryPresentPendingRecipe()
                    }
                }

                // App aktif olduğunda bekleyen tarif varsa aç (garanti)
                .onChange(of: scenePhase) { phase in
                    if phase == .active {
                        tryPresentPendingRecipe()
                    }
                }

                // Deeplink veya mevcut IMPORT akışı
                .onOpenURL { url in
                    if url.scheme?.lowercased() == "coffeeratio",
                       url.host?.lowercased() == "recipe",
                       let items = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems,
                       let name = items.first(where: { $0.name == "name" })?.value {
                        pendingRecipeName = name
                        tryPresentPendingRecipe()
                        return
                    }
                    handleImport(url: url)
                }

                .alert(item: $importAlertMessage) { alertMessage in
                    Alert(title: Text(alertMessage.message))
                }
        }
    }

    // MARK: - Bekleyen tarifi güvenle sun
    private func tryPresentPendingRecipe() {
        guard let name = pendingRecipeName,
              let recipe = coffeeRecipes.first(where: { $0.name == name }) else { return }

        // Mikro gecikme ile, en üstteki VC üzerinden
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            presentRecipeDetail(recipe)
            pendingRecipeName = nil
        }
    }

    private func presentRecipeDetail(_ recipe: CoffeeRecipe) {
        guard let top = topMostViewController() else { return }
        let detail = CoffeeDetailView(recipe: recipe)
            .environmentObject(settings)
        let hosting = UIHostingController(rootView: NavigationView { detail })
        hosting.modalPresentationStyle = .formSheet
        top.present(hosting, animated: true)
    }

    private func topMostViewController(base: UIViewController? = UIApplication.shared.connectedScenes
        .compactMap { $0 as? UIWindowScene }
        .flatMap { $0.windows }
        .first { $0.isKeyWindow }?.rootViewController) -> UIViewController? {

        if let nav = base as? UINavigationController {
            return topMostViewController(base: nav.visibleViewController)
        }
        if let tab = base as? UITabBarController {
            return topMostViewController(base: tab.selectedViewController)
        }
        if let presented = base?.presentedViewController {
            return topMostViewController(base: presented)
        }
        return base
    }

    // MARK: - IMPORT (mevcut)
    private func handleImport(url: URL) {
        let accessing = url.startAccessingSecurityScopedResource()
        defer { if accessing { url.stopAccessingSecurityScopedResource() } }
        do {
            let fm = FileManager.default
            let tempUrl = fm.temporaryDirectory.appendingPathComponent(url.lastPathComponent)
            if url != tempUrl {
                if fm.fileExists(atPath: tempUrl.path) { try? fm.removeItem(at: tempUrl) }
                try fm.copyItem(at: url, to: tempUrl)
            }
            let data = try Data(contentsOf: tempUrl)
            let imported = try JSONDecoder().decode(CustomCoffeeRecipe.self, from: data)
            if !recipeStore.recipes.contains(where: { $0.id == imported.id }) {
                recipeStore.recipes.append(imported)
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

// (MainTabView sende zaten varsa bu bloğu kaldırabilirsin)
struct MainTabView: View {
    @EnvironmentObject private var settings: SettingsModel
    var body: some View {
        TabView {
            CoffeeRehberiView().tabItem { Label("Genel Tarifler", systemImage: "cup.and.saucer.fill") }
            BrewingMethodsView().tabItem { Label("Demleme Yöntemleri", systemImage: "timer") }
            MyCustomRecipesView().tabItem { Label("Kendi Tariflerim", systemImage: "person.crop.circle") }
            SettingsView().tabItem { Label("Ayarlar", systemImage: "gear") }
        }
    }
}
