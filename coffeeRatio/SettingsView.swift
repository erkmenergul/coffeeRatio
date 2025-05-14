//  SettingsView.swift

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var settings: SettingsModel

    let languageOptions = ["Türkçe", "İngilizce"]
    let unitOptions     = ["Metric", "Imperial"]

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Genel Ayarlar")) {
                    Toggle("Karanlık Mod", isOn: $settings.darkModeEnabled)
                    Toggle("Bildirimler", isOn: $settings.notificationsEnabled)
                }

                Section(header: Text("Dil ve Birim")) {
                    HStack {
                        Text("Dil:")
                        Spacer()
                        Picker("", selection: $settings.selectedLanguage) {
                            ForEach(languageOptions, id: \.self) { Text($0) }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                    }
                    HStack {
                        Text("Birim:")
                        Spacer()
                        Picker("", selection: $settings.selectedUnit) {
                            ForEach(unitOptions, id: \.self) { Text($0) }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                    }
                }

                Section(header: Text("Hakkında")) {
                    Text("Bu uygulama, çeşitli kahve tarifleri ve demleme yöntemlerini sunar.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle("Ayarlar")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
            .environmentObject(SettingsModel())
    }
}
