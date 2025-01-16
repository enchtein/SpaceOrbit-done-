import UIKit

extension UIViewController {
  func hideKeyboardWhenTappedAround(cancelsTouchesInView: Bool = false) {
    let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboardByTap(_:)))
    tap.cancelsTouchesInView = cancelsTouchesInView
    view.addGestureRecognizer(tap)
  }
  
  @objc private func dismissKeyboardByTap(_ sender: UITapGestureRecognizer) {
    let location = sender.location(in: sender.view)
    let isTextFieldTapped = isTextFieldTapped(at: location)
    
    guard !isTextFieldTapped else { return }
    
    view.endEditing(true)
  }
  
  func isTextFieldTapped(at location: CGPoint) -> Bool {
    let allTextFields = getAllTextFields(fromView: view)
    guard !allTextFields.isEmpty else { return false }
    
    let allTextFieldsGlobalFrame = allTextFields.compactMap { $0.globalFrame }
    let tappedTextFieldGlobalFrame = allTextFieldsGlobalFrame.first { globalFrame in
      globalFrame.contains(location)
    }
    return tappedTextFieldGlobalFrame != nil
  }
  
  private func getAllTextFields(fromView view: UIView)-> [UITextField] {
    return view.subviews.flatMap { (view) -> [UITextField] in
      if view is UITextField {
        return [(view as! UITextField)]
      } else {
        return getAllTextFields(fromView: view)
      }
    }.compactMap { $0 }
  }
}
//MARK: - Hide Keyboard for presentation VC
extension UIViewController {
  func hideKeyboardWhenTappedAroundForPresentationVC(cancelsTouchesInView: Bool = false) {
    let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboardByTapForPresentationVC(_:)))
    tap.cancelsTouchesInView = cancelsTouchesInView
    view.addGestureRecognizer(tap)
  }
  
  @objc private func dismissKeyboardByTapForPresentationVC(_ sender: UITapGestureRecognizer) {
    let location = sender.location(in: sender.view)
    let updatedLocation = CGPoint(x: location.x, y: location.y + view.frame.origin.y)
    
    let unCloseKbView = getUnCloseKbView(from: view).first {
      if let globalFrame = $0.globalFrame {
        globalFrame.contains(updatedLocation)
      } else {
        $0.frame.contains(updatedLocation)
      }
    }
    
    guard unCloseKbView == nil else { return }
    view.endEditing(true)
  }
  private func getUnCloseKbView(from view: UIView) -> [UIView] {
    return view.subviews.flatMap { (view) -> [UIView] in
      if view is UIButton || view is UITextField {
        return [view]
      } else {
        return getUnCloseKbView(from: view)
      }
    }.compactMap { $0 }
  }
}

extension UIViewController {
  var isOnScreen: Bool { isViewLoaded && view.window != nil }
  
  private var screenBounds: CGRect? { view.window?.windowScene?.screen.bounds }
  var screenWidth: CGFloat { screenBounds?.width ?? view.bounds.width }
  var screenHeight: CGFloat { screenBounds?.height ?? view.bounds.height }
  
  var safeArea: UIEdgeInsets {
    UIApplication.shared.appWindow?.safeAreaInsets ?? .zero
  }
  var screenWidthWOSafeArea: CGFloat {
    screenWidth - safeArea.left - safeArea.right
  }
  var screenHeightWOSafeArea: CGFloat {
    screenHeight - safeArea.top - safeArea.bottom
  }
}

extension UIViewController {
  static func initFromNib() -> Self {
    func instanceFromNib<T: UIViewController>() -> T {
      return T(nibName: String(describing: self), bundle: nil)
    }
    return instanceFromNib()
  }
}

//MARK: - Take screenshot and share
extension UIViewController {
  func getScreenshotAndShare() {
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
      let screenshot = self.view.createSnapshot()
      
      let activityVC = UIActivityViewController(activityItems: [screenshot], applicationActivities: nil)
      activityVC.popoverPresentationController?.sourceView = self.view // so that iPads won't crash
      
      self.present(activityVC, animated: true)
    }
  }
}
