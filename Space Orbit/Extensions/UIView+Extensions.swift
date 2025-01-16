import UIKit

extension UIView {
  @IBInspectable var cornerRadius: CGFloat {
    get {
      return layer.cornerRadius
    }
    set {
      layer.masksToBounds = true
      layer.cornerRadius = abs(CGFloat(Int(newValue * 100)) / 100)
    }
  }
  
  func setRounded() {
    self.contentMode = .scaleAspectFill
    self.layer.masksToBounds = false
    self.layer.cornerRadius = min(self.bounds.width, self.bounds.height) / 2
    self.clipsToBounds = true
  }
  func roundCorners(_ corners: UIRectCorner, radius: CGFloat) {
    if #available(iOS 11, *) {
      var cornerMask = CACornerMask()
      if(corners.contains(.topLeft)){
        cornerMask.insert(.layerMinXMinYCorner)
      }
      if(corners.contains(.topRight)){
        cornerMask.insert(.layerMaxXMinYCorner)
      }
      if(corners.contains(.bottomLeft)){
        cornerMask.insert(.layerMinXMaxYCorner)
      }
      if(corners.contains(.bottomRight)){
        cornerMask.insert(.layerMaxXMaxYCorner)
      }
      self.layer.cornerRadius = radius
      self.layer.maskedCorners = cornerMask
      
    } else {
      let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
      let mask = CAShapeLayer()
      mask.path = path.cgPath
      self.layer.mask = mask
    }
  }
  
  func fillToSuperview(verticalIndents: CGFloat, horizontalIndents: CGFloat) {
    translatesAutoresizingMaskIntoConstraints = false
    if let superview = superview {
      let left = leftAnchor.constraint(equalTo: superview.leftAnchor, constant: horizontalIndents)
      let right = rightAnchor.constraint(equalTo: superview.rightAnchor, constant: -horizontalIndents)
      let top = topAnchor.constraint(equalTo: superview.topAnchor, constant: verticalIndents)
      let bottom = bottomAnchor.constraint(equalTo: superview.bottomAnchor, constant: -verticalIndents)
      NSLayoutConstraint.activate([left, right, top, bottom])
    }
  }
  func fillToSuperview() {
    fillToSuperview(verticalIndents: .zero, horizontalIndents: .zero)
  }
  func fillToSuperview(verticalIndents: CGFloat) {
    fillToSuperview(verticalIndents: verticalIndents, horizontalIndents: .zero)
  }
  func fillToSuperview(horizontalIndents: CGFloat) {
    fillToSuperview(verticalIndents: .zero, horizontalIndents: horizontalIndents)
  }
}

//MARK: - spring animation
extension UIView {
  func springAnimation(scaleFactor: CGFloat = 0.97, additionalFunc: (() -> Void)? = nil) {
    let duration: TimeInterval = 0.2
    
    UIView.animate(withDuration: duration) {
      self.transform = CGAffineTransform(scaleX: scaleFactor, y: scaleFactor)
    } completion: { _ in
      UIView.animate(withDuration: duration) {
        self.transform = .identity
      } completion: { _ in
        additionalFunc?()
      }
    }
  }
}

//MARK: - apply CommonShadowSettings
extension UIView {
  func setShadow(with cornerRadius: CGFloat, and color: UIColor) {
    layer.shadowColor = color.cgColor
    layer.shadowOffset = CGSize(width: 0, height: 2)
    layer.shadowRadius = 4.0
    layer.shadowOpacity = 1
    layer.cornerRadius = cornerRadius
    clipsToBounds = false
  }
  func setShadow(_ corners: UIRectCorner, with cornerRadius: CGFloat, and color: UIColor) {
    layer.shadowColor = color.cgColor
    layer.shadowOffset = .zero
    layer.shadowRadius = 4.0
    layer.shadowOpacity = 1
    layer.cornerRadius = cornerRadius
    layer.maskedCorners = CACornerMask(rawValue: corners.rawValue)
    clipsToBounds = false
  }
}
//MARK: - findViewController
extension UIView {
  func findViewController() -> UIViewController? {
    if let nextResponder = self.next as? UIViewController {
      return nextResponder
    } else if let nextResponder = self.next as? UIView {
      return nextResponder.findViewController()
    } else {
      return nil
    }
  }
  func findBaseViewController() -> BaseViewController? {
    findViewController() as? BaseViewController
  }
  var isBaseVCAppeared: Bool {
    guard let baseVC = findBaseViewController() else { return false }
    return baseVC.isAppeared
  }
}
//MARK: - globalPoint + globalFrame
extension UIView {
  var globalPoint: CGPoint? { superview?.convert(self.frame.origin, to: nil) }
  var globalFrame: CGRect? { superview?.convert(self.frame, to: nil) }
}

//MARK: - findFirstResponder
extension UIView {
  func findFirstResponder() -> UIView? {
    if self.isFirstResponder {
      return self
    } else {
      for possibleResponder in self.subviews {
        if let sub = possibleResponder.findFirstResponder() {
          return sub
        }
      }
      return nil
    }
  }
}
//MARK: - Hide/Show view in StackView
extension UIView {
  var animationDuration: TimeInterval {
    isBaseVCAppeared ? Constants.animationDuration : .zero
  }
  
  func linearHideAnimated(in stackView: UIStackView) {
    guard !isHidden else { return }
    
    UIView.animate(withDuration: animationDuration) {
      self.alpha = .zero
      self.isHidden = true
      stackView.layoutIfNeeded()
    }
  }
  func linearShowAnimated(in stackView: UIStackView) {
    guard isHidden else { return }
    
    UIView.animate(withDuration: animationDuration) {
      self.alpha = 1.0
      self.isHidden = false
      stackView.layoutIfNeeded()
    }
  }
  func hideAnimated(in stackView: UIStackView) {
    guard !isHidden else { return }
    
    UIView.animate(withDuration: animationDuration, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 1) {
      self.alpha = .zero
      self.isHidden = true
      stackView.layoutIfNeeded()
    }
  }
  
  func showAnimated(in stackView: UIStackView) {
    guard isHidden else { return }
    
    UIView.animate(withDuration: animationDuration, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 1) {
      self.alpha = 1.0
      self.isHidden = false
      stackView.layoutIfNeeded()
    }
  }
  
  func fadeOut() {
    guard !isHidden || alpha != .zero else { return }
    
    UIView.animate(withDuration: animationDuration, delay: .zero, options: .curveEaseOut) {
      self.alpha = .zero
    } completion: { _ in
      self.isHidden = true
    }
  }
  func fadeIn() {
    guard isHidden || alpha == .zero else { return }
    
    self.isHidden = false
    UIView.animate(withDuration: animationDuration, delay: .zero, options: .curveEaseIn) {
      self.alpha = 1.0
    }
  }
  
  func setOpaqueAnimated(customCompletion: (() -> Void)? = nil) {
    guard alpha != .zero else { return }
    
    isUserInteractionEnabled = false
    UIView.animate(withDuration: Constants.animationDuration) {
      self.alpha = .zero
    } completion: { _ in
      customCompletion?()
    }
  }
  
  func setNonOpaqueAnimated(customCompletion: (() -> Void)? = nil) {
    guard alpha != 1.0 else { return }
    
    UIView.animate(withDuration: Constants.animationDuration) {
      self.alpha = 1.0
    } completion: { _ in
      self.isUserInteractionEnabled = true
      customCompletion?()
    }
  }
}
//MARK: - Take screenshot
extension UIView {
  func createSnapshot() -> UIImage {
    // Begin context
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, false, UIScreen.main.scale)
    
    // Draw view in that context
    drawHierarchy(in: self.bounds, afterScreenUpdates: false)
    
    // And finally, get image
    let image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    if let image {
      return image
    } else {
      return UIImage()
    }
  }
}
//MARK: - Vertical Gradient
extension UIView {
  func setupVGradient(color1: UIColor, color2: UIColor) {
    let name = "setupVGradient"
    //clear layer
    (layer.sublayers ?? []).filter { $0.name == name }.forEach {
      $0.removeFromSuperlayer()
    }
    
    let gradientLayer = CAGradientLayer()
    gradientLayer.name = name
    
    gradientLayer.colors = [color1.cgColor, color2.cgColor]
    gradientLayer.locations = [0.0, 1.0]
    gradientLayer.frame = bounds
    
    layer.insertSublayer(gradientLayer, at:0)
  }
}
//MARK: - Constants
fileprivate struct Constants: CommonSettings {}
