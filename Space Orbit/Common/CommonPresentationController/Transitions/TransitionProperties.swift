import Foundation

@objc
public protocol TransitionProperties {
  var duration: TimeInterval {get set}
  var springWithDamping: CGFloat {get set}
  var isDisabledDismissAnimation: Bool {get set}
}
