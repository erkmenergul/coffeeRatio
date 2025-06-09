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
            
            Text("Sınırsız tarif kaydı\nTüm gelecekteki premium özelliklere ücretsiz erişim")
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
        .alert(isPresented: $store.restoreAlert) {        // ---- EKLENEN SATIR
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
