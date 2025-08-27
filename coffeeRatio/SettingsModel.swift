//  SettingsModel.swift

import SwiftUI
import Combine

final class SettingsModel: ObservableObject {
    // Mevcut ayarlar
    @AppStorage("selectedLanguage")     var selectedLanguage: String   = "Türkçe"
    @AppStorage("selectedUnit")         var selectedUnit: String       = "Metric"
    @AppStorage("darkModeEnabled")      var darkModeEnabled: Bool      = false
    @AppStorage("notificationsEnabled") var notificationsEnabled: Bool = true

    // YENİ: Öneri (bildirim) zamanı tercihleri – varsayılan: Pazartesi 09:00
    // Calendar’da 1=Pazar, 2=Pazartesi, ... 7=Cumartesi
    @AppStorage("notificationWeekday")  var notificationWeekday: Int   = 2
    @AppStorage("notificationHour")     var notificationHour: Int      = 9
    @AppStorage("notificationMinute")   var notificationMinute: Int    = 0
}
