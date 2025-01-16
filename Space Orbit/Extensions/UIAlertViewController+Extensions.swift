import UIKit

extension UIAlertController {
  static func alert(with title: String = "applicationName", message: String, actions: [UIAlertAction]? = nil) {
    guard let topViewController = UIApplication.topViewController(), !(topViewController is UIAlertController) else { return }
    
    let alert = Self.generate(with: title, message: message, actions: actions)
    topViewController.present(alert, animated: true)
  }
  
  @discardableResult
  static func alert(with title: String = "applicationName", message: String, actions: [UIAlertAction]? = nil, alertStyle: UIAlertController.Style = .alert) -> UIAlertController? {
    guard let topViewController = UIApplication.topViewController() else {
      return nil
    }
    let alert = Self.generate(with: title, message: message, actions: actions, alertStyle: alertStyle)
    
    updatePopoverRect(for: alert, according: topViewController)
    
    topViewController.present(alert, animated: true)
    return alert
  }
  
  static func generate(with title: String = "applicationName", message: String, actions: [UIAlertAction]? = nil, alertStyle: UIAlertController.Style = .alert) -> UIAlertController {
    let alert = UIAlertController.init(title: title, message: message, preferredStyle: alertStyle)
    
    if let _actions = actions, !_actions.isEmpty {
      _actions.forEach { alert.addAction($0) }
    } else {
      alert.addAction(UIAlertAction(title: "Ok", style: .default))
    }
    return alert
  }
  
  static private func updatePopoverRect(for alert: UIAlertController, according topViewController: UIViewController) {
    if let popoverController = alert.popoverPresentationController {
      popoverController.sourceView = topViewController.view
      popoverController.sourceRect = CGRect(x: topViewController.view.bounds.midX, y: topViewController.view.bounds.midY, width: 0, height: 0)
      popoverController.permittedArrowDirections = []
    }
  }
}
