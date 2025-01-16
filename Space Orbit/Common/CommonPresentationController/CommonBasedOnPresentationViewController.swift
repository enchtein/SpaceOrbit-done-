import UIKit

class CommonBasedOnPresentationViewController: BaseViewController {
  var pointOrigin: CGPoint?
  
  private(set) var presentDirection: TransitionDirection = .bottom
  
  private(set) var basePanGesture: UIPanGestureRecognizer!
  var isPanGestureShouldRecognizeSimultaneouslyWith: Bool {
    return true
  }
  
  //MARK: - Need to write convinience init in inherited class for init
  //*******************************
  static func createFromNibHelper(presentDirection: TransitionDirection = .bottom) -> Self {
    let vc = Self.initFromNib()
    
    vc.presentDirection = presentDirection
    
    return vc
  }
  //*******************************
  
  //MARK: - need to override for set additional settings
  override func viewDidLoad() {
    super.viewDidLoad()
    
    if self.modalPresentationStyle == .custom {
      addBasePanGesture(to: view)
    }
    
    NotificationCenter.default.addObserver(self, selector: #selector(kbWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(kbWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(appWillMovedToBackground), name: UIApplication.willResignActiveNotification, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(appWillMovedToForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
  }
  
  //MARK: - need to override for set pointOrigin
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
  }
  
  //MARK: - override if needed
  deinit {
#if DEBUG
    print("deinit CommonBasedOnPresentationViewController")
#endif
    
    NotificationCenter.default.removeObserver(self)
  }
  
  //MARK: - Helpers (Override if needed)
  @objc func kbWillShow(notification: NSNotification) {}
  @objc func kbWillHide(notification: NSNotification) {}
  @objc func appWillMovedToBackground(notification: NSNotification) {}
  @objc func appWillMovedToForeground(notification: NSNotification) {}
  
  //MARK: - Helpers (NOT need to override)
  final func addBasePanGesture(to view: UIView?) {
    self.removeBasePanGesture()
    
    let viewForGesuure = view == nil ? self.view : view
    
    let panGesture = UIPanGestureRecognizer(target: self, action: #selector(panGestureRecognizerAction))
    panGesture.cancelsTouchesInView = false
    panGesture.delegate = self
    viewForGesuure?.addGestureRecognizer(panGesture)
    
    self.basePanGesture = panGesture
  }
  final func removeBasePanGesture() {
    guard let basePanGesture else {return}
    basePanGesture.view?.removeGestureRecognizer(basePanGesture)
  }
  @objc func panGestureRecognizerAction(sender: UIPanGestureRecognizer) {
    let translation = sender.translation(in: view)
    
    let dismissPanDirection: Bool
    let currentBlurAlpha: CGFloat
    let newOrigin: CGPoint
    switch self.presentDirection {
      
    case .left:
      dismissPanDirection = translation.x <= 0
      currentBlurAlpha = (self.view.frame.width + translation.x) / self.view.frame.width
      newOrigin = CGPoint(x: self.pointOrigin!.x + translation.x, y: self.view.frame.origin.y)
    case .right:
      dismissPanDirection = translation.x >= 0
      currentBlurAlpha = (self.view.frame.width - translation.x) / self.view.frame.width
      newOrigin = CGPoint(x: self.pointOrigin!.x + translation.x, y: self.view.frame.origin.y)
    case .top:
      dismissPanDirection = translation.y <= 0
      currentBlurAlpha = (self.view.frame.height + translation.y) / self.view.frame.height
      newOrigin = CGPoint(x: self.view.frame.origin.x, y: self.pointOrigin!.y + translation.y)
    case .bottom:
      dismissPanDirection = translation.y >= 0
      currentBlurAlpha = (self.view.frame.height - translation.y) / self.view.frame.height
      newOrigin = CGPoint(x: self.view.frame.origin.x, y: self.pointOrigin!.y + translation.y)
    }
    // Not allowing the user to drag the view upward
    guard dismissPanDirection else {
      if sender.state == .ended {
        self.setDefaultFrameWithAnimation()
      }
      return }
    
    //Change alpha of shadow
    if let commonPresentationController = self.presentationController as? CommonPresentationController {
      let baseValue = commonPresentationController.baseBlurViewAlpha
      let newBlurAlpha = commonPresentationController.shouldShowBlur ? baseValue - (1 - currentBlurAlpha) : baseValue
      
      commonPresentationController.blurEffectView.alpha = newBlurAlpha
    }
    
    view.frame.origin = newOrigin
    if sender.state == .ended {
      let dragVelocity = sender.velocity(in: view)
      if self.presentDirection == .left && dragVelocity.x <= -750 {
        self.dismiss(animated: true, completion: nil)
      } else if self.presentDirection == .right && dragVelocity.x >= 750 {
        self.dismiss(animated: true, completion: nil)
      } else if self.presentDirection == .top && dragVelocity.y <= -1300 {
        self.dismiss(animated: true, completion: nil)
      } else if self.presentDirection == .bottom && dragVelocity.y >= 1300 {
        self.dismiss(animated: true, completion: nil)
      } else {
        // Set back to original position of the view controller
        self.setDefaultFrameWithAnimation()
      }
    }
  }
  
  final func setDefaultFrameWithAnimation() {
    UIView.animate(withDuration: 0.3) {
      self.view.frame.origin = self.pointOrigin ?? CGPoint(x: 0, y: 400)
      if let commonPresentationController = self.presentationController as? CommonPresentationController {
        commonPresentationController.blurEffectView.alpha = commonPresentationController.baseBlurViewAlpha
      }
    }
  }
}

extension CommonBasedOnPresentationViewController: UIGestureRecognizerDelegate {
  func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
    return isPanGestureShouldRecognizeSimultaneouslyWith
  }
}
