import UIKit

extension UIApplication {
  var windowBounds: CGRect {
    appWindow?.windowScene?.screen.bounds ?? .zero
  }
  var appDelegate: UIApplicationDelegate {
    return UIApplication.shared.delegate as! AppDelegate
  }
  var appWindow: UIWindow? {
    if let window = appDelegate.window {
      return window!
    }
    return nil
  }
  
  var keyWindowVC: UIViewController? {
    appWindow?.rootViewController
  }
  
  class func topViewController(base: UIViewController? = UIApplication.shared.keyWindowVC) -> UIViewController? {
    if let nav = base as? UINavigationController {
      return topViewController(base: nav.visibleViewController)
    }
    if let tab = base as? UITabBarController {
      if let selected = tab.selectedViewController {
        return topViewController(base: selected)
      }
    }
    if let presented = base?.presentedViewController {
      return topViewController(base: presented)
    }
    return base
  }
}
