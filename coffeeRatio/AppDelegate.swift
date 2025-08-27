// AppDelegate.swift  (yeni küçük dosya)
import UIKit
import UserNotifications

final class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        // Bildirim delegesini en erken noktada ver
        UNUserNotificationCenter.current().delegate = NotificationsManager.shared
        return true
    }
}
