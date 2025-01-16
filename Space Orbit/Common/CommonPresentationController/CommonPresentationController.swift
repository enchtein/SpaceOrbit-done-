import UIKit

class CommonPresentationController: UIPresentationController {
  var baseBlurViewAlpha: CGFloat {
    return self.shouldShowBlur ? 0.7 : 1.0
  }
  let blurEffectView: UIView!
  private lazy var tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissController))
  
  private(set) var updateViewSize: CGRect?
  
  //*** override this properties for set view size parameters
  var dismissByTap: Bool {
    return true
  }
  var shouldShowBlur: Bool {
    return true
  }
  var indent: CGFloat {
    return .zero
  }
  var customHeight: CGFloat {
    return .zero
  }
  var customWidth: CGFloat {
    return .zero
  }
  
  //final properties
  final var height: CGFloat {
    customHeight == .zero ? self.containerView!.frame.height : customHeight
  }
  final var width: CGFloat {
    customWidth == .zero ? self.containerView!.frame.width : customWidth
  }
  
  //MARK: - override init if needed
  override init(presentedViewController: UIViewController, presenting presentingViewController: UIViewController?) {
    let darkBlur = UIBlurEffect(style: UIBlurEffect.Style.dark)
    let blurView = UIVisualEffectView(effect: darkBlur)
    blurEffectView = blurView
    
    super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
    if !self.shouldShowBlur {
      blurEffectView.backgroundColor = .clear
    }
    
    self.blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    self.blurEffectView.isUserInteractionEnabled = true
    self.blurEffectView.addGestureRecognizer(tapGestureRecognizer)
  }
  
  //MARK: - Dont change!
  @objc private func dismissController() {
    guard dismissByTap else { return }
    self.presentedViewController.dismiss(animated: true, completion: nil)
  }
  
  override var frameOfPresentedViewInContainerView: CGRect {
    let viewSettings: CGRect = CGRect(x: self.containerView!.frame.width / 2, y: self.indent, width: self.width, height: self.height)
    
    return CGRect(origin: CGPoint(x: (self.containerView!.frame.width / 2) - (viewSettings.size.width / 2), y: indent), size: viewSettings.size)
  }
  
  override func presentationTransitionWillBegin() {
    self.blurEffectView.alpha = 0
    self.containerView?.addSubview(blurEffectView)
    self.presentedViewController.transitionCoordinator?.animate(alongsideTransition: { (UIViewControllerTransitionCoordinatorContext) in
      self.blurEffectView.alpha = self.baseBlurViewAlpha
    }, completion: { (UIViewControllerTransitionCoordinatorContext) in })
  }
  
  override func dismissalTransitionWillBegin() {
    self.presentedViewController.transitionCoordinator?.animate(alongsideTransition: { (UIViewControllerTransitionCoordinatorContext) in
      self.blurEffectView.alpha = 0
    }, completion: { (UIViewControllerTransitionCoordinatorContext) in
      self.blurEffectView.removeFromSuperview()
    })
  }
  
  //MARK: - Override to set cornerRadius
  override func containerViewWillLayoutSubviews() {
    super.containerViewWillLayoutSubviews()
  }
  
  //MARK: - Override to set vc.pointOrigin on rotate (only if needed)
  override func containerViewDidLayoutSubviews() {
    super.containerViewDidLayoutSubviews()
    blurEffectView.frame = containerView!.bounds
    UIView.animate(withDuration: Constants.animationDuration) {
      self.presentedView?.frame = self.frameOfPresentedViewInContainerView
      if let commonBasedOnPresentationViewController = self.presentedViewController as? CommonBasedOnPresentationViewController {
        commonBasedOnPresentationViewController.pointOrigin = self.presentedView?.frame.origin
      }
    }
  }
  override func preferredContentSizeDidChange(forChildContentContainer container: any UIContentContainer) {
    super.preferredContentSizeDidChange(forChildContentContainer: container)
    
    guard let containerView = containerView else {
        return
    }
    containerView.setNeedsLayout()
    containerView.layoutIfNeeded()
  }
}

//MARK: - Constants
fileprivate struct Constants: CommonSettings { }
