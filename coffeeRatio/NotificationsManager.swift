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
                // İzin verildiyse, kullanıcı tercih edilen gün/saat ile planla
                if granted {
                    self.scheduleWeeklyRecipeSuggestion()
                }
            }
        }
    }

    /// Haftada bir kez rastgele tarif önerisi bildirimi planlar (kullanıcının seçtiği gün+saat ile)
    func scheduleWeeklyRecipeSuggestion() {
        // Önce eski bildirimi sil (aynı ID ile)
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["weeklySuggestion"])

        let defaults = UserDefaults.standard

        // Bildirimler kapalıysa planlama yapma
        if defaults.object(forKey: "notificationsEnabled") != nil {
            let enabled = defaults.bool(forKey: "notificationsEnabled")
            guard enabled else { return }
        }

        // Kullanıcı tercihleri (varsayılan: Pazartesi 09:00)
        // Calendar: 1 = Pazar, 2 = Pazartesi, ... 7 = Cumartesi
        let weekdayStored = defaults.object(forKey: "notificationWeekday") as? Int
        let hourStored    = defaults.object(forKey: "notificationHour") as? Int
        let minuteStored  = defaults.object(forKey: "notificationMinute") as? Int

        let weekday = {
            let w = weekdayStored ?? 2
            return (1...7).contains(w) ? w : 2
        }()

        let hour   = (hourStored   ?? 9)
        let minute = (minuteStored ?? 0)

        var dateComponents = DateComponents()
        dateComponents.weekday = weekday
        dateComponents.hour = hour
        dateComponents.minute = minute

        guard let randomRecipe = coffeeRecipes.randomElement() else { return }

        let content = UNMutableNotificationContent()
        content.title = NSLocalizedString("weekly_recipe_title", comment: "")
        content.body  = String(format: NSLocalizedString("weekly_recipe_body", comment: ""), randomRecipe.name)
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
