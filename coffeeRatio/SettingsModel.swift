//  SettingsModel.swift

import SwiftUI
import Combine

final class SettingsModel: ObservableObject {
    // Bu property’ler artık UserDefaults’a otomatik yazılır/okunur:
    @AppStorage("selectedLanguage")     var selectedLanguage: String   = "Türkçe"
    @AppStorage("selectedUnit")         var selectedUnit: String       = "Metric"
    @AppStorage("darkModeEnabled")      var darkModeEnabled: Bool      = false
    @AppStorage("notificationsEnabled") var notificationsEnabled: Bool = true
}
