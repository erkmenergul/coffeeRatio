//  NotificationsManager.swift
import Foundation
import UserNotifications
import UIKit

extension Notification.Name {
    static let openRecipeDetail = Notification.Name("coffeeratio.openRecipeDetail")
}

final class NotificationsManager: NSObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationsManager()
    private override init() { super.init() }

    func requestAuthorization() {
        let center = UNUserNotificationCenter.current()
        center.delegate = self
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let err = error {
                print("Bildirim izni hatası: \(err)")
            } else {
                print("Bildirim izni: \(granted)")
                if granted {
                    self.scheduleWeeklyRecipeSuggestion()
                }
            }
        }
    }

    func scheduleWeeklyRecipeSuggestion() {
        UNUserNotificationCenter.current()
            .removePendingNotificationRequests(withIdentifiers: ["weeklySuggestion"])

        let defaults = UserDefaults.standard
        if defaults.object(forKey: "notificationsEnabled") != nil {
            let enabled = defaults.bool(forKey: "notificationsEnabled")
            guard enabled else { return }
        }

        let weekdayStored = defaults.object(forKey: "notificationWeekday") as? Int
        let hourStored    = defaults.object(forKey: "notificationHour") as? Int
        let minuteStored  = defaults.object(forKey: "notificationMinute") as? Int

        let weekday = { let w = weekdayStored ?? 2; return (1...7).contains(w) ? w : 2 }()
        let hour    = hourStored   ?? 9
        let minute  = minuteStored ?? 0

        var comps = DateComponents()
        comps.weekday = weekday
        comps.hour = hour
        comps.minute = minute

        guard let randomRecipe = coffeeRecipes.randomElement() else { return }

        let content = UNMutableNotificationContent()
        content.title = NSLocalizedString("weekly_recipe_title", comment: "")
        content.body  = String(format: NSLocalizedString("weekly_recipe_body", comment: ""), randomRecipe.name)
        content.sound = .default

        // Deeplink + ad bilgisini userInfo'ya ekle
        let nameEncoded = randomRecipe.name.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? randomRecipe.name
        content.userInfo = [
            "deeplink": "coffeeratio://recipe?name=\(nameEncoded)",
            "recipeName": randomRecipe.name
        ]

        let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: true)
        let req = UNNotificationRequest(identifier: "weeklySuggestion", content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(req) { if let e = $0 { print("WeeklySuggestion error:", e) } }
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound, .list, .badge])
    }

    // 🔧 Tıklanınca: iç bildirim yayınla (App yakalasın ve detayı açsın)
    // Bildirime tıklanınca tarif adını post et
    // NotificationsManager.swift içindeki didReceive:
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        let info = response.notification.request.content.userInfo
        if let name = info["recipeName"] as? String {
            // 1) İç bildirim (sıcak/arka plan senaryosu)
            NotificationCenter.default.post(name: .openRecipeDetail,
                                            object: nil,
                                            userInfo: ["recipeName": name])
            // 2) Soğuk başlatma güvenlik ağı
            UserDefaults.standard.set(name, forKey: "launchRecipeName")
        }
        completionHandler()
    }
}
