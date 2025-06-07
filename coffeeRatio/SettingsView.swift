//  SettingsView.swift

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var settings: SettingsModel
    @EnvironmentObject var recipeStore: CustomRecipeStore
    @State private var showDeleteAlert = false
    @State private var showPremiumSheet = false

    let unitOptions = ["Metric", "Imperial"]

    var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "?"
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Genel Ayarlar")) {
                    Toggle("Karanlık Mod", isOn: $settings.darkModeEnabled)
                    Toggle("Bildirimler", isOn: $settings.notificationsEnabled)
                }

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

                Section(header: Text("Tarifleri Yönet")) {
                    Button("Kahve Tariflerini Sil") {
                        showDeleteAlert = true
                    }
                    .foregroundColor(.red)
                }

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

                // En alta Premium'a Geç bölümü eklendi
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
            }
            .navigationTitle("Ayarlar")
            .navigationBarTitleDisplayMode(.inline)
            .alert(isPresented: $showDeleteAlert) {
                Alert(
                    title: Text("Emin misiniz?"),
                    message: Text("Kendi tariflerinizdeki tüm kahve tarifleri silinecek."),
                    primaryButton: .destructive(Text("Sil")) {
                        recipeStore.recipes.removeAll()
                    },
                    secondaryButton: .cancel()
                )
            }
            .sheet(isPresented: $showPremiumSheet) {
                PremiumInfoView()
            }
        }
    }
}

// Basit bir PremiumInfoView, ileride gerçek StoreKit ekranı ile değiştirilebilir.
struct PremiumInfoView: View {
    @Environment(\.dismiss) var dismiss
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

            Text("• Sınırsız tarif kaydı\n• Tüm gelecekteki premium özelliklere ücretsiz erişim\n\nYakında burada!")
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)

            Button("Kapat") {
                dismiss()
            }
            .padding(.top, 8)
        }
        .padding()
        .presentationDetents([.medium])
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
            .environmentObject(SettingsModel())
            .environmentObject(CustomRecipeStore())
    }
}
