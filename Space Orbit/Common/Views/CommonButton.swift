import UIKit

final class CommonButton: UIButton {
  private var enabledBgColor: UIColor = AppColor.accentOne
  private var enabledTitleColor: UIColor = AppColor.backgroundOne
  
  override var isEnabled: Bool {
    didSet {
      guard oldValue != isEnabled else { return }
      enabledStateDidChange()
    }
  }
  
  init() {
    super.init(frame: .zero)
    
    setupUI()
  }
  required init?(coder: NSCoder) {
    super.init(coder: coder)
    
    setupUI()
  }
  
  private func setupUI() {
    backgroundColor = enabledBgColor
    
    addTarget(self, action: #selector(setOpaqueButton), for: .touchDown)
    addTarget(self, action: #selector(setNonOpaquesButton), for: .touchDragExit)
    addTarget(self, action: #selector(setOpaqueButton), for: .touchDragEnter)
    addTarget(self, action: #selector(setNonOpaquesButton), for: .touchUpInside)
    
    semanticContentAttribute = .forceRightToLeft
  }
}

//MARK: - CommonButton Actions
private extension CommonButton {
  @objc func setOpaqueButton() {
    updateButtonOpacity(true)
  }
  @objc func setNonOpaquesButton() {
    updateButtonOpacity(false)
  }
  func updateButtonOpacity(_ isOpaque: Bool) {
    guard isEnabled else { return }
    layer.opacity = isOpaque ? Constants.actionsOpacity.highlighted : Constants.actionsOpacity.base
  }
  
  func enabledStateDidChange() {
    UIView.animate(withDuration: Constants.animationDuration) {
      self.backgroundColor = self.isEnabled ? self.enabledBgColor: AppColor.layerThree
    }
  }
}
//MARK: - API
extension CommonButton {
  func setupTitle(with text: String) {
    setTitle(text, for: .normal)
  }
  
  func setupEnabledBgColor(to color: UIColor) {
    enabledBgColor = color
    backgroundColor = color
  }
  func setupEnabledTitleColor(to color: UIColor) {
    enabledTitleColor = color
    setTitleColor(color, for: .normal)
  }
  
  func setupFont(to font: UIFont) {
    titleLabel?.font = font
  }
  
  func setupTitle(contentEdgeInsets: UIEdgeInsets) {
    self.contentEdgeInsets = contentEdgeInsets
  }
}
//MARK: - CommonButton Constants
fileprivate struct Constants: CommonSettings {
  static let actionsOpacity = TargetActionsOpacity()
}
