//
//  AppDelegate.swift
//  Clear Project
//
//  Created by Дмитрий Хероим on 17.11.2024.
//

import UIKit
import FirebaseCore

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  var window: UIWindow?
  
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    window = UIWindow(frame: UIScreen.main.bounds)
    guard let window = window else {
      assertionFailure("Please, choose launch storyboard")
      return false
    }
    
    UNUserNotificationCenter.current().delegate = self
    
    AppCoordinator.shared.start(with: window)
    
    FirebaseApp.configure()
    AppCoordinator.shared.getParticipantFromKeychain()
    
    return true
  }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
  func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
    completionHandler([.sound, .badge, .banner])
  }
  func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse) async {
    LocalNotificationsProvider.shared.updateBadgeCountToZero()
  }
  
}
