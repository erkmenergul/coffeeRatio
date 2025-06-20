//  SettingsView.swift

import SwiftUI
import UIKit

struct SettingsView: View {
    @EnvironmentObject var settings: SettingsModel
    @EnvironmentObject var recipeStore: CustomRecipeStore
    @State private var showPremiumSheet = false
    @State private var activeAlert: ActiveAlert? = nil

    let unitOptions = ["Metric", "Imperial"]

    var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "?"
    }

    enum ActiveAlert: Identifiable {
        case confirmDelete
        case emptyWarning

        var id: Int { hashValue }
    }

    var body: some View {
        NavigationView {
            Form {
                // GENEL AYARLAR
                Section(header: Text("Genel Ayarlar")) {
                    Toggle("Karanlık Mod", isOn: $settings.darkModeEnabled)
                    Toggle("Bildirimler", isOn: $settings.notificationsEnabled)
                }

                // BİRİM SEÇİMİ
                Section(header: Text("Birim")) {
                    HStack {
                        Text("Birim:")
                        Spacer()
                        Picker("", selection: $settings.selectedUnit) {
                            ForEach(unitOptions, id: \.self) { Text($0) }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                    }
                }

                // TARİFLERİ YÖNET
                Section(header: Text("Tarifleri Yönet")) {
                    Button("Kahve Tariflerini Sil") {
                        if recipeStore.recipes.isEmpty {
                            activeAlert = .emptyWarning
                        } else {
                            activeAlert = .confirmDelete
                        }
                    }
                    .foregroundColor(.red)
                }

                // PREMIUM’A GEÇ
                Section {
                    Button(action: {
                        showPremiumSheet = true
                    }) {
                        HStack {
                            Image(systemName: "star.fill")
                                .foregroundColor(.yellow)
                            Text("Premium’a Geç")
                                .foregroundColor(.primary)
                        }
                    }
                }

                // GERİ BİLDİRİM
                Section {
                    Button(action: {
                        sendFeedbackEmail()
                    }) {
                        HStack {
                            Image(systemName: "envelope")
                            Text("Geri Bildirim Gönderin")
                        }
                    }
                }

                // HAKKINDA – EN ALTA TAŞINDI
                Section(header: Text("Hakkında")) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Bu uygulama, çeşitli kahve tarifleri ve demleme yöntemlerini öğrenmenizi,kaydetmenizi sağlar.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Text("Sürüm: \(appVersion)")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                            .padding(.top, 4)
                    }
                }
            }
            .navigationTitle("Ayarlar")
            .navigationBarTitleDisplayMode(.inline)

            .alert(item: $activeAlert) { alertType in
                switch alertType {
                case .confirmDelete:
                    return Alert(
                        title: Text("Emin misiniz?"),
                        message: Text("Kendi tariflerinizdeki tüm kahve tarifleri silinecek."),
                        primaryButton: .destructive(Text("Sil")) {
                            recipeStore.recipes.removeAll()
                        },
                        secondaryButton: .cancel()
                    )
                case .emptyWarning:
                    return Alert(
                        title: Text("warning"),
                        message: Text("no_recipes_found"),
                        dismissButton: .default(Text("ok"))
                    )
                }
            }

            .sheet(isPresented: $showPremiumSheet) {
                PremiumInfoView()
            }
        }
        .navigationViewStyle(.stack)  // ← iPad'de split yerine stack modu
    }

    // GERİ BİLDİRİM MAİLİ AÇMA
    private func sendFeedbackEmail() {
        let email = "contactmyappstudio@gmail.com"
        let subject = "CoffeeRatio Geri Bildirim"
        let body = "Merhaba,\n\nUygulama hakkında geri bildirimim:\n"

        let encodedSubject = subject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let encodedBody = body.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""

        if let url = URL(string: "mailto:\(email)?subject=\(encodedSubject)&body=\(encodedBody)") {
            UIApplication.shared.open(url)
        }
    }
}

struct PremiumInfoView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var store: StoreManager

    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "star.fill")
                .resizable()
                .frame(width: 60, height: 60)
                .foregroundColor(.yellow)
                .padding(.top)

            Text("CoffeeRatio Premium")
                .font(.title)
                .fontWeight(.bold)

            Text("Sınırsız tarif kaydı\nKendi tariflerinizi paylaşma\nTüm gelecekteki premium özelliklere ücretsiz erişim")
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)

            if store.isPurchased {
                Text("Premium Aktif! 🎉")
                    .foregroundColor(.green)
            } else if let product = store.products.first {
                Button("Satın Al (\(product.displayPrice))") {
                    Task {
                        await store.purchase(product)
                    }
                }
                .buttonStyle(.borderedProminent)

                Button("Satın Alımı Geri Yükle") {
                    Task {
                        await store.restore()
                    }
                }
                .padding(.top, 4)
            } else {
                ProgressView("Ürünler Yükleniyor…")
            }

            Button("Kapat") {
                dismiss()
            }
            .padding(.top)
        }
        .padding()
        .alert(isPresented: $store.restoreAlert) {
            Alert(title: Text(store.restoreAlertMessage))
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
            .environmentObject(SettingsModel())
            .environmentObject(CustomRecipeStore())
    }
}
