//
//  CoinOutButton.swift
//  Space Orbit
//
//  Created by Дмитрий Хероим on 28.12.2024.
//

import UIKit

final class CoinOutButton: UIControl {
  private lazy var coinTitle = createCoinTitle()
  private lazy var coinIcon = createCoinIcon()
  private lazy var coinLabel = createCoinLabel()
  
  private let enabledBgColor: UIColor = AppColor.layerOne
  private let enabledTitleColor: UIColor = AppColor.backgroundOne
  
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
    
    let hStack = createCommonHStack()
    addSubview(hStack)
    hStack.translatesAutoresizingMaskIntoConstraints = false
    hStack.topAnchor.constraint(equalTo: topAnchor, constant: Constants.vIndent).isActive = true
    hStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -Constants.vIndent).isActive = true
    hStack.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
    hStack.isUserInteractionEnabled = false
    
    cornerRadius = 12.0
  }
}
//MARK: - API
extension CoinOutButton {
  func updateCoinOutTitle(with value: Float) {
    coinLabel.text = Constants.getFormattedText(from: value)
  }
}
//MARK: - CommonButton Actions
private extension CoinOutButton {
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
      self.backgroundColor = self.isEnabled ? self.enabledBgColor : AppColor.layerFour
    }
    UIView.transition(with: coinTitle, duration: Constants.animationDuration) {
      self.coinTitle.textColor = self.isEnabled ? Constants.labelColor : Constants.inactiveLabelColor
    }
    UIView.transition(with: coinLabel, duration: Constants.animationDuration) {
      self.coinLabel.textColor = self.isEnabled ? Constants.labelColor : Constants.inactiveLabelColor
    }
  }
}
//MARK: - UI elements creating
private extension CoinOutButton {
  func createCommonHStack() -> UIStackView {
    let stackView = UIStackView()
    stackView.axis = .horizontal
    stackView.spacing = 12.0
    
    stackView.addArrangedSubview(coinTitle)
    stackView.addArrangedSubview(createCoinLabelHStack())
    
    return stackView
  }
  
  func createCoinTitle() -> UILabel {
    let label = UILabel()
    label.text = MainTitles.coinOut.localized
    label.font = Constants.labelFont
    label.textColor = Constants.labelColor
    
    return label
  }
  
  func createCoinLabelHStack() -> UIStackView {
    let stackView = UIStackView()
    stackView.axis = .horizontal
    stackView.spacing = 4.0
    stackView.alignment = .center
    
    stackView.addArrangedSubview(coinIcon)
    stackView.addArrangedSubview(coinLabel)
    
    return stackView
  }
  func createCoinIcon() -> UIImageView {
    let imageView = UIImageView()
    imageView.image = AppImage.CommonNavPanel.coin
    
    imageView.translatesAutoresizingMaskIntoConstraints = false
    imageView.heightAnchor.constraint(equalToConstant: Constants.coinImageViewSize).isActive = true
    imageView.widthAnchor.constraint(equalToConstant: Constants.coinImageViewSize).isActive = true
    
    return imageView
  }
  func createCoinLabel() -> UILabel {
    let label = UILabel()
    label.text = "0.00"
    label.font = Constants.labelFont
    label.textColor = Constants.labelColor
    
    return label
  }
}
//MARK: - CommonButton Constants
fileprivate struct Constants: CommonSettings {
  static let actionsOpacity = TargetActionsOpacity()
  
  static var labelFont: UIFont {
    let fontSize = sizeProportion(for: 16.0, minSize: 12.0)
    return AppFont.font(type: .bold, size: fontSize)
  }
  
  
  static let labelColor = AppColor.backgroundOne
  static let inactiveLabelColor = AppColor.layerTwo
  
  static let coinImageViewSize: CGFloat = 24.0
  
  static var vIndent: CGFloat { sizeProportion(for: 20.0, minSize: 12.0) }
}
