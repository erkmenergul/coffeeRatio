//  NotificationsManager.swift

import Foundation
import UserNotifications

final class NotificationsManager {
    static let shared = NotificationsManager()
    private init() {}

    /// Kullanıcıdan bildirim izni ister
    func requestAuthorization() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let err = error {
                print("Bildirim izni hatası: \(err)")
            } else {
                print("Bildirim izni: \(granted)")
            }
        }
    }

    /// Haftada bir kez rastgele tarif önerisi bildirimi planlar
    func scheduleWeeklyRecipeSuggestion() {
        // Pazartesi 09:00'da her hafta
        var dateComponents = DateComponents()
        dateComponents.weekday = 2  // 1 = Pazar, 2 = Pazartesi
        dateComponents.hour = 9
        dateComponents.minute = 0

        guard let randomRecipe = coffeeRecipes.randomElement() else { return }

        let content = UNMutableNotificationContent()
        content.title = "Haftalık Tarif Önerisi"
        content.body  = "Bu haftanın tarifi: \(randomRecipe.name)"
        content.sound = .default

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(
            identifier: "weeklySuggestion",
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request) { error in
            if let err = error {
                print("WeeklySuggestion bildirim hatası: \(err)")
            }
        }
    }
}
