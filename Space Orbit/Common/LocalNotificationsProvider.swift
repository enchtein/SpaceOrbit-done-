import UserNotifications
import UIKit

final class LocalNotificationsProvider {
  static let shared = LocalNotificationsProvider()
  private(set) var isRequested = false
  private(set) var isAuthorized = false
  
  private init() {}
  
  private let notificationHour = 8
  private let notificationMinutes = 00
  private let notificationSeconds = 00
  private let additionalDaysCount = 2
  
  private var notificationDate: Date {
    var currentDateComponents = Calendar.current.dateComponents([.minute, .hour, .day, .month, .year], from: Date())
    currentDateComponents.hour = notificationHour
    currentDateComponents.minute = notificationMinutes
    currentDateComponents.second = notificationSeconds
    
    let currentDay = Calendar.current.date(from: currentDateComponents) ?? Date()
    let dayAfterTomorrow = Calendar.current.date(byAdding: .day, value: additionalDaysCount, to: currentDay) ?? currentDay
    
    return dayAfterTomorrow
  }
  
  func requestPermissionAndScheduleNotificationIfNeeded() {
    guard !isRequested else { return }
    
    requestNotificationPermission { [weak self] in
      self?.scheduleNotification()
    }
  }
}
//MARK: - Helpers
private extension LocalNotificationsProvider {
  func updateAuthorizationStatus() {
    UNUserNotificationCenter.current().getNotificationSettings { [weak self] settings in
      self?.isAuthorized = settings.authorizationStatus == .authorized
    }
    
    isRequested = true
  }
  
  func removeAllNotifications() {
    updateBadgeCountToZero()
    UNUserNotificationCenter.current().removeAllDeliveredNotifications()
    UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
  }
  
  func requestNotificationPermission(successCompletion: (() -> Void)? = nil) {
    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { [weak self] didAllow, error in
      guard let self else { return }
      
      if didAllow {
        successCompletion?()
      } else {
#if DEBUG
        print("Permission for push notifications denied.")
#endif
      }
      
      updateAuthorizationStatus()
    }
  }
}
//MARK: - Helpers
private extension LocalNotificationsProvider {
  func scheduleNotification() {
    removeAllNotifications()
    
    let dailyNotificationKey = "Daily notification category"
    
    let content = UNMutableNotificationContent()
    
    content.title = CommonAppTitles.notificationTitle.localized
    content.body = CommonAppTitles.notificationMsg.localized
    content.categoryIdentifier = dailyNotificationKey
    content.sound = UNNotificationSound.default
    content.badge = 1
    
    var dateComponents = DateComponents()
    dateComponents.timeZone = Calendar.current.timeZone
    dateComponents.hour = notificationHour
    dateComponents.minute = notificationMinutes
    
    let notificationDateComponents = Calendar.current.dateComponents([.minute, .hour, .day, .month, .year], from: notificationDate)
    let trigger = UNCalendarNotificationTrigger(dateMatching: notificationDateComponents, repeats: false)
    let request = UNNotificationRequest(identifier: dailyNotificationKey, content: content, trigger: trigger)
    
    UNUserNotificationCenter.current().add(request) { error in
      if let error = error {
#if DEBUG
        print("❌ Daily Local Push Notification added failure: \(error.localizedDescription)")
#endif
      } else {
#if DEBUG
        print("✅ Daily Local Push Notification successfully added.")
#endif
      }
    }
  }
}
//MARK: - API
extension LocalNotificationsProvider {
  func updateBadgeCountToZero() {
    UNUserNotificationCenter.current().removeAllDeliveredNotifications()
    if #available(iOS 16.0, *) {
      UNUserNotificationCenter.current().setBadgeCount(0)
    } else {
      // Fallback on earlier versions
      UIApplication.shared.applicationIconBadgeNumber = 0
    }
  }
}
