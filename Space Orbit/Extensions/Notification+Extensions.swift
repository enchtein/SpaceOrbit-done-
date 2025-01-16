import Foundation

extension Notification.Name {
  static let currentPrticipantSet = Notification.Name("currentPrticipantSet")
}

extension Notification.Name {
  func post(center: NotificationCenter = NotificationCenter.default,
            object: Any? = nil,
            userInfo: [AnyHashable : Any]? = nil) {
    center.post(name: self, object: object, userInfo: userInfo)
  }
}

extension Notification {
  static func removeObservers(observers: [Any], center: NotificationCenter = NotificationCenter.default) {
    for observer in observers {
      center.removeObserver(observer)
    }
  }
}
