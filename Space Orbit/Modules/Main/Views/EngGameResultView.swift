//
//  EngGameResultView.swift
//  Space Orbit
//
//  Created by Дмитрий Хероим on 30.12.2024.
//

import UIKit

protocol EngGameResultViewDelegate: AnyObject {
  func peddingNewGameButtonAction()
  func rePlayGameButtonAction()
  func shareResultGameButtonAction()
}
final class EngGameResultView: UIView {
  private lazy var contentWinVStack = createContentWinVStack()
  private lazy var winCoefficientLabel = createWinCoefficientLabel()
  private lazy var winBetAmountLabel = createWinBetAmountLabel()
  private lazy var winCoinOutLabel = createWinCoinOutLabel()
  
  private lazy var contentCrashedVStack = createContentCrashedVStack()
  private lazy var crashedBetAmountLabel = createCrashedBetAmountLabel()
  
  private lazy var heightConstraint = NSLayoutConstraint(item: self, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 0)
  
  private weak var delegate: EngGameResultViewDelegate?
  private(set) var resultModel: EndGameResultModel?
  
  init(delegate: EngGameResultViewDelegate) {
    self.delegate = delegate
    super.init(frame: .zero)
    
    setupBaseConsraints()
  }
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    setupBaseConsraints()
  }
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func setupBaseConsraints() {
    heightConstraint.isActive = true
    hideAnimated()
  }
  
  func showAnimated(with model: EndGameResultModel) {
    resultModel = model
    guard isHidden || alpha != 1.0 else { return }
    
    heightConstraint.isActive = false
    subviews.forEach { $0.removeFromSuperview() }
    
    switch model.gameState {
    case .pedding, .playing, .paused: return
    case .win:
      AppSoundManager.shared.win()
      addSubview(contentWinVStack)
      contentWinVStack.fillToSuperview()
    case .crashed:
      AppSoundManager.shared.lose()
      addSubview(contentCrashedVStack)
      contentCrashedVStack.fillToSuperview()
    }
    
    setupLabels(according: model)
    
    layoutIfNeeded()
    
    UIView.animate(withDuration: animationDuration) {
      self.alpha = 1.0
    } completion: { _ in
      self.isUserInteractionEnabled = true
    }
  }
  private func setupLabels(according model: EndGameResultModel) {
    switch model.gameState {
    case .pedding, .playing, .paused: return
    case .win:
      winCoefficientLabel.text = "x\(Constants.getFormattedText(from: model.coef.coefficient))"
      winBetAmountLabel.text = "\(Constants.getFormattedText(from: model.betAmount))"
      
      let res = model.betAmount * model.coef.coefficient
      winCoinOutLabel.text = "\(Constants.getFormattedText(from: res))"
    case .crashed:
      crashedBetAmountLabel.text = "-\(Constants.getFormattedText(from: model.betAmount))"
    }
  }
  func hideAnimated() {
    resultModel = nil
    guard !isHidden || alpha != .zero else { return }
    
    isUserInteractionEnabled = false
    UIView.animate(withDuration: animationDuration) {
      self.alpha = .zero
    } completion: { _ in
      self.subviews.forEach { $0.removeFromSuperview() }
      self.heightConstraint.isActive = true
    }
  }
}

//MARK: - UI elements creating (Win)
private extension EngGameResultView {
  func createContentWinVStack() -> UIStackView {
    let vStack = createContentVStack()
    
    let subVStack = createContentVStack()
    subVStack.alignment = .center
    subVStack.spacing = .zero
    subVStack.addArrangedSubview(createWinTitle())
    subVStack.addArrangedSubview(winCoefficientLabel)
    
    vStack.addArrangedSubview(subVStack)
    vStack.addArrangedSubview(createWinAmountContainer())
    vStack.addArrangedSubview(createWinButtonsHStack())
    
    return vStack
  }
  
  func createWinTitle() -> UILabel {
    let label = UILabel()
    label.text = EngGameResultViewTitles.win.localized
    label.font = Constants.winTitleFont
    label.textColor = Constants.winTitleColor
    
    return label
  }
  func createWinCoefficientLabel() -> UILabel {
    let label = UILabel()
    label.text = "x4.88"
    label.font = Constants.winCoefficientLabelFont
    label.textColor = Constants.winCoefficientLabelColor
    
    return label
  }
  
  func createWinAmountContainer() -> UIView {
    let view = UIView()
    
    let hStack = UIStackView()
    hStack.axis = .horizontal
    hStack.spacing = .zero
    hStack.distribution = .fillEqually
    
    hStack.addArrangedSubview(createWinLeadingSubContainer())
    hStack.addArrangedSubview(createWinTrailingSubContainer())
    hStack.cornerRadius = Constants.winSubContainerIndent
    
    view.addSubview(hStack)
    hStack.fillToSuperview()
    
    return view
  }
  func createWinLeadingSubContainer() -> UIView {
    let view = UIView()
    view.backgroundColor = AppColor.layerOne
    
    let vStack = UIStackView()
    vStack.axis = .vertical
    vStack.spacing = Constants.winSubContainerVStackSpacing
    vStack.alignment = .leading
    vStack.addArrangedSubview(createWinBetAmountTitle())
    vStack.addArrangedSubview(winBetAmountLabel)
    
    view.addSubview(vStack)
    vStack.fillToSuperview(verticalIndents: Constants.winSubContainerIndent, horizontalIndents: Constants.winSubContainerIndent)
    
    return view
  }
  func createWinTrailingSubContainer() -> UIView {
    let view = UIView()
    view.backgroundColor = AppColor.accentOne
    
    let vStack = UIStackView()
    vStack.axis = .vertical
    vStack.spacing = Constants.winSubContainerVStackSpacing
    vStack.alignment = .trailing
    vStack.addArrangedSubview(createWinCoinOutTitle())
    vStack.addArrangedSubview(winCoinOutLabel)
    
    view.addSubview(vStack)
    vStack.fillToSuperview(verticalIndents: Constants.winSubContainerIndent, horizontalIndents: Constants.winSubContainerIndent)
    
    return view
  }
  func createWinBetAmountTitle() -> UILabel {
    let label = UILabel()
    label.text = EngGameResultViewTitles.betAmount.localized + ":"
    label.font = Constants.winBetAmountTitleFont
    label.textColor = Constants.winBetAmountTitleColor
    
    return label
  }
  func createWinBetAmountLabel() -> UILabel {
    let label = UILabel()
    label.text = "10.00"
    label.font = Constants.winBetAmountLabelFont
    label.textColor = Constants.winBetAmountLabelColor
    
    return label
  }
  func createWinCoinOutTitle() -> UILabel {
    let label = UILabel()
    label.text = EngGameResultViewTitles.coinOut.localized + ":"
    label.font = Constants.winCoinOutTitleFont
    label.textColor = Constants.winCoinOutTitleColor
    
    return label
  }
  func createWinCoinOutLabel() -> UILabel {
    let label = UILabel()
    label.text = "48.80"
    label.font = Constants.winCoinOutLabelFont
    label.textColor = Constants.winCoinOutLabelColor
    
    return label
  }
  
  func createWinButtonsHStack() -> UIStackView {
    let hStack = UIStackView()
    hStack.axis = .horizontal
    hStack.spacing = .zero
    
    let subHStack = createButtonsHStack()
    
    subHStack.addArrangedSubview(createHomeButton())
    subHStack.addArrangedSubview(createRePlayButton())
    subHStack.addArrangedSubview(createShareButton())
    
    let leadingSpacer = UIView()
    let trailingSpacer = UIView()
    
    hStack.addArrangedSubview(leadingSpacer)
    hStack.addArrangedSubview(subHStack)
    hStack.addArrangedSubview(trailingSpacer)
    
    trailingSpacer.translatesAutoresizingMaskIntoConstraints = false
    trailingSpacer.widthAnchor.constraint(equalTo: leadingSpacer.widthAnchor).isActive = true
    
    return hStack
  }
}
//MARK: - UI elements creating (Crashed)
private extension EngGameResultView {
  func createContentCrashedVStack() -> UIStackView {
    let vStack = createContentVStack()
    
    let subVStack = createContentVStack()
    subVStack.alignment = .center
    subVStack.spacing = Constants.contentCrashedVStackSpacing
    
    subVStack.addArrangedSubview(createCrashedTitle())
    
    let subSubVStack = createContentVStack()
    subSubVStack.spacing = Constants.contentCrashedSubSubVStackSpacing
    subSubVStack.alignment = .center
    subSubVStack.addArrangedSubview(createCrashedBetAmountTitle())
    
    let amountHStack = UIStackView()
    amountHStack.axis = .horizontal
    amountHStack.spacing = Constants.contentCrashedAmountHStackSpacing
    amountHStack.alignment = .center
    amountHStack.addArrangedSubview(createCoinImageView())
    amountHStack.addArrangedSubview(crashedBetAmountLabel)
    subSubVStack.addArrangedSubview(amountHStack)
    
    subVStack.addArrangedSubview(subSubVStack)
    
    vStack.addArrangedSubview(subVStack)
    vStack.addArrangedSubview(createCrashedButtonsHStack())
    
    return vStack
  }
  
  func createCrashedTitle() -> UILabel {
    let label = UILabel()
    label.text = EngGameResultViewTitles.youCrashed.localized
    label.font = Constants.crashedTitleFont
    label.textColor = Constants.crashedTitleColor
    
    return label
  }
  
  func createCrashedBetAmountTitle() -> UILabel {
    let label = UILabel()
    label.text = EngGameResultViewTitles.betAmount.localized + ":"
    label.font = Constants.crashedBetAmountTitleFont
    label.textColor = Constants.crashedBetAmountTitleColor
    
    return label
  }
  func createCoinImageView() -> UIImageView {
    let imageView = UIImageView()
    imageView.image = AppImage.CommonNavPanel.coin
    imageView.translatesAutoresizingMaskIntoConstraints = false
    imageView.heightAnchor.constraint(equalToConstant: Constants.coinImageViewSideSize).isActive = true
    imageView.widthAnchor.constraint(equalToConstant: Constants.coinImageViewSideSize).isActive = true
    
    return imageView
  }
  func createCrashedBetAmountLabel() -> UILabel {
    let label = UILabel()
    label.text = "-10.00"
    label.font = Constants.crashedBetAmountLabelFont
    label.textColor = Constants.crashedBetAmountLabelColor
    
    return label
  }
  
  func createCrashedButtonsHStack() -> UIStackView {
    let hStack = UIStackView()
    hStack.axis = .horizontal
    hStack.spacing = .zero
    
    let subHStack = createButtonsHStack()
    
    subHStack.addArrangedSubview(createHomeButton())
    subHStack.addArrangedSubview(createRePlayButton())
    
    let leadingSpacer = UIView()
    let trailingSpacer = UIView()
    
    hStack.addArrangedSubview(leadingSpacer)
    hStack.addArrangedSubview(subHStack)
    hStack.addArrangedSubview(trailingSpacer)
    
    trailingSpacer.translatesAutoresizingMaskIntoConstraints = false
    trailingSpacer.widthAnchor.constraint(equalTo: leadingSpacer.widthAnchor).isActive = true
    
    return hStack
  }
}
//MARK: - UI elements creating (Common)
private extension EngGameResultView {
  func createHomeButton() -> UIButton {
    let button = createButton()
    
    button.setImage(AppImage.EngGameResultView.home, for: .normal)
    button.addTarget(self, action: #selector(peddingNewGameButtonAction), for: .touchUpInside)
    
    return button
  }
  func createRePlayButton() -> UIButton {
    let button = createButton()
    button.setImage(AppImage.EngGameResultView.replay, for: .normal)
    button.addTarget(self, action: #selector(rePlayGameButtonAction), for: .touchUpInside)
    
    return button
  }
  func createShareButton() -> UIButton {
    let button = createButton()
    button.setImage(AppImage.EngGameResultView.share, for: .normal)
    button.addTarget(self, action: #selector(shareResultGameButtonAction), for: .touchUpInside)
    
    return button
  }
  
  func createContentVStack() -> UIStackView {
    let stackView = UIStackView()
    
    stackView.axis = .vertical
    stackView.spacing = Constants.contentVStackSpacing
    
    return stackView
  }
  func createButton() -> UIButton {
    let button = UIButton()
    button.translatesAutoresizingMaskIntoConstraints = false
    button.widthAnchor.constraint(equalToConstant: Constants.buttonSideSize).isActive = true
    button.heightAnchor.constraint(equalToConstant: Constants.buttonSideSize).isActive = true
    
    return button
  }
  func createButtonsHStack() -> UIStackView {
    let stackView = UIStackView()
    
    stackView.axis = .horizontal
    stackView.spacing = Constants.buttonsHStackSpacing
    
    return stackView
  }
}
//MARK: - Button actions
private extension EngGameResultView {
  @objc func peddingNewGameButtonAction() {
    delegate?.peddingNewGameButtonAction()
  }
  @objc func rePlayGameButtonAction() {
    delegate?.rePlayGameButtonAction()
  }
  @objc func shareResultGameButtonAction() {
    delegate?.shareResultGameButtonAction()
  }
}
//MARK: - Constants
fileprivate struct Constants: CommonSettings {
  //Fonts
  static var winTitleFont: UIFont {
    crashedBetAmountLabelFont
  }
  static var winCoefficientLabelFont: UIFont {
    crashedTitleFont
  }
  static var winBetAmountTitleFont: UIFont {
    let fontSize = sizeProportion(for: 14.0, minSize: 10.0)
    return AppFont.font(type: .regular, size: fontSize)
  }
  static var winBetAmountLabelFont: UIFont {
    let fontSize = sizeProportion(for: 16.0, minSize: 12.0)
    return AppFont.font(type: .bold, size: fontSize)
  }
  static var winCoinOutTitleFont: UIFont {
    winBetAmountTitleFont
  }
  static var winCoinOutLabelFont: UIFont {
    winBetAmountLabelFont
  }
  
  static var crashedTitleFont: UIFont {
    let fontSize = sizeProportion(for: 48.0)
    return AppFont.font(type: .black, size: fontSize)
  }
  static var crashedBetAmountTitleFont: UIFont {
    let fontSize = sizeProportion(for: 16.0, minSize: 12.0)
    return AppFont.font(type: .medium, size: fontSize)
  }
  static var crashedBetAmountLabelFont: UIFont {
    let fontSize = sizeProportion(for: 24.0, minSize: 18.0)
    return AppFont.font(type: .bold, size: fontSize)
  }
  //Text colors
  static let winTitleColor = AppColor.accentOne
  static let winCoefficientLabelColor = AppColor.layerOne
  static let winBetAmountTitleColor = AppColor.backgroundOne
  static let winBetAmountLabelColor = AppColor.backgroundOne
  static let winCoinOutTitleColor = AppColor.layerOne
  static let winCoinOutLabelColor = AppColor.layerOne
  
  static let crashedTitleColor = AppColor.accentOne
  static let crashedBetAmountTitleColor = AppColor.layerTwo
  static let crashedBetAmountLabelColor = AppColor.layerOne
  //Constans
  static var winSubContainerIndent: CGFloat { sizeProportion(for: 16.0) }
  static let winSubContainerVStackSpacing = 2.0
  
  static let coinImageViewSideSize: CGFloat = 24.0
  static var contentVStackSpacing: CGFloat { sizeProportion(for: 31.0) }
  
  static var buttonSideSize: CGFloat { sizeProportion(for: 64.0) }
  static var buttonsHStackSpacing: CGFloat { sizeProportion(for: 28.0) }
  
  static var contentCrashedVStackSpacing: CGFloat { winSubContainerIndent }
  static var contentCrashedSubSubVStackSpacing: CGFloat { contentCrashedVStackSpacing / 4 }
  static var contentCrashedAmountHStackSpacing: CGFloat { sizeProportion(for: 6.0) }
}

//MARK: - EndGameResultModel
struct EndGameResultModel {
  let gameState: GameState
  let betAmount: Float
  let coef: CoefficientCalculatorModel
}
