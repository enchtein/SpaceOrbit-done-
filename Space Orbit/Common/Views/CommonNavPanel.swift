import UIKit

@objc protocol CommonNavPanelDelegate: AnyObject {
  @objc optional func backButtonAction()
  @objc optional func gamePauseButtonAction()
  
  @objc optional func shopBurgerButtonAction()
  @objc optional func leaderboardBurgerButtonAction()
  @objc optional func settingsBurgerButtonAction()
}
final class CommonNavPanel: UIView {
  private var type: NavPanelType
  private weak var delegate: CommonNavPanelDelegate?
  
  private lazy var contentHStack = createContentHStack()
  private lazy var emptyLeadingViewInsteadButton = createEmptyLeadingViewInsteadButton()
  private lazy var emptyTrailingViewInsteadButton = createEmptyTrailingViewInsteadButton()
  
  private lazy var backButton = createBackButton()
  
  private lazy var balanceVStack = createBalanceVStack()
  private lazy var balanceTitle = createBalanceTitle()
  private lazy var balanceCoinHStack = createBalanceCoinHStack()
  private lazy var coinImageView = createCoinImageView()
  private lazy var coinLabel = createCoinLabel()
  
  private lazy var burgerButton = createBurgerButton()
  private(set) lazy var burgerMenuVStack = createBurgerMenuVStack()
  private lazy var closeBurgerButton = createCloseBurgerButton()
  private lazy var shopBurgerButton = createShopBurgerButton()
  private lazy var leaderboardBurgerButton = createLeaderboardBurgerButton()
  private lazy var settingsBurgerButton = createSettingsBurgerButton()

  private lazy var gamePauseButton = createGamePauseButton()
  //---> helpers properties (Start)
  private var burgerMenuAnimationIsProcessing = false
  //<--- helpers properties (End)
  
  private var currentBalance: Float = Participant.mock.coinsScore
  
  init(type: NavPanelType, delegate: CommonNavPanelDelegate) {
    self.type = type
    self.delegate = delegate
    
    super.init(frame: .zero)
    setupUI()
  }
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func setupUI() {
    addSubview(contentHStack)
    contentHStack.translatesAutoresizingMaskIntoConstraints = false
    contentHStack.topAnchor.constraint(equalTo: topAnchor, constant: Constants.contentHStackSideIndent / 2).isActive = true
    contentHStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Constants.contentHStackSideIndent).isActive = true
    contentHStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Constants.contentHStackSideIndent).isActive = true
    contentHStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -Constants.contentHStackSideIndent).isActive = true
    contentHStack.heightAnchor.constraint(equalToConstant: Constants.buttonSize.height).isActive = true
    
    update(type: type)
    
    addSubview(burgerMenuVStack)
    burgerMenuVStack.translatesAutoresizingMaskIntoConstraints = false
    burgerMenuVStack.topAnchor.constraint(equalTo: contentHStack.topAnchor).isActive = true
    burgerMenuVStack.trailingAnchor.constraint(equalTo: contentHStack.trailingAnchor).isActive = true
    burgerMenuVStack.widthAnchor.constraint(equalToConstant: Constants.buttonSize.width).isActive = true
    updateBurgerMenuVisibility(to: false)
  }
  
  func isInBurgerMenuVStack(point: CGPoint) -> Bool {
    guard let superview else { return false }
    let convertedPoint = superview.convert(point, to: burgerMenuVStack)
    
    return burgerMenuVStack.bounds.contains(convertedPoint)
  }
}
//MARK: - UI elements creating
private extension CommonNavPanel {
  func createBackButton() -> UIButton {
    let button = createCommonButton()
    button.setImage(AppImage.CommonNavPanel.back, for: .normal)
    button.addTarget(self, action: #selector(backButtonAction), for: .touchUpInside)
    
    return button
  }
  func createBurgerButton() -> UIButton {
    let button = createCommonButton()
    button.setImage(AppImage.CommonNavPanel.menu, for: .normal)
    button.addTarget(self, action: #selector(burgerButtonAction), for: .touchUpInside)
    
    return button
  }
  
  func createBurgerMenuVStack() -> UIStackView {
    let stackView = UIStackView()
    stackView.axis = .vertical
    stackView.spacing = Constants.burgerMenuVStackSpacing
    
    stackView.addArrangedSubview(closeBurgerButton)
    stackView.addArrangedSubview(shopBurgerButton)
    stackView.addArrangedSubview(leaderboardBurgerButton)
    stackView.addArrangedSubview(settingsBurgerButton)
    
    return stackView
  }
  func createCloseBurgerButton() -> UIButton {
    let button = createCommonButton()
    button.setImage(AppImage.CommonNavPanel.close, for: .normal)
    button.addTarget(self, action: #selector(burgerButtonAction), for: .touchUpInside)
    
    return button
  }
  func createShopBurgerButton() -> UIButton {
    let button = createCommonButton()
    button.setImage(AppImage.CommonNavPanel.shop, for: .normal)
    button.addTarget(self, action: #selector(shopBurgerButtonAction), for: .touchUpInside)
    
    return button
  }
  func createLeaderboardBurgerButton() -> UIButton {
    let button = createCommonButton()
    button.setImage(AppImage.CommonNavPanel.leaderboard, for: .normal)
    button.addTarget(self, action: #selector(leaderboardBurgerButtonAction), for: .touchUpInside)
    
    return button
  }
  func createSettingsBurgerButton() -> UIButton {
    let button = createCommonButton()
    button.setImage(AppImage.CommonNavPanel.settings, for: .normal)
    button.addTarget(self, action: #selector(settingsBurgerButtonAction), for: .touchUpInside)
    
    return button
  }
  
  func createBalanceVStack() -> UIStackView {
    let vStack = UIStackView()
    vStack.axis = .vertical
    vStack.spacing = Constants.balanceVStackSpacing
    vStack.alignment = .center
    
    vStack.addArrangedSubview(balanceTitle)
    vStack.addArrangedSubview(balanceCoinHStack)
    
    return vStack
  }
  func createBalanceTitle() -> UILabel {
    let label = UILabel()
    label.text = CommonNavPanelTitles.balance.localized + ":"
    label.font = Constants.balanceTitleFont
    label.textColor = Constants.balanceTitleColor
    
    return label
  }
  func createBalanceCoinHStack() -> UIStackView {
    let hStack = UIStackView()
    hStack.axis = .horizontal
    hStack.spacing = Constants.balanceCoinHStackSpacing
    
    hStack.addArrangedSubview(coinImageView)
    hStack.addArrangedSubview(coinLabel)
    
    return hStack
  }
  func createCoinImageView() -> UIImageView {
    let imageView = UIImageView()
    imageView.translatesAutoresizingMaskIntoConstraints = false
    imageView.widthAnchor.constraint(equalToConstant: Constants.coinImageViewSize.width).isActive = true
    imageView.heightAnchor.constraint(equalToConstant: Constants.coinImageViewSize.height).isActive = true
    imageView.image = AppImage.CommonNavPanel.coin
    
    return imageView
  }
  func createCoinLabel() -> UILabel {
    let label = UILabel()
    label.text = "1 000.00"
    label.font = Constants.coinLabelFont
    label.textColor = Constants.coinLabelColor
    
    return label
  }
  
  func createGamePauseButton() -> UIButton {
    let button = createCommonButton()
    button.setImage(AppImage.CommonNavPanel.pause, for: .normal)
    button.addTarget(self, action: #selector(gamePauseButtonAction), for: .touchUpInside)
    
    return button
  }
}
//MARK: - Common UI elements creating
private extension CommonNavPanel {
  func createContentHStack() -> UIStackView {
    let stackView = UIStackView()
    stackView.axis = .horizontal
    stackView.spacing = .zero
    stackView.alignment = .fill
    stackView.distribution = .equalSpacing
    
    return stackView
  }
  
  func createEmptyLeadingViewInsteadButton() -> UIView {
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.widthAnchor.constraint(equalToConstant: Constants.buttonSize.width).isActive = true
    view.heightAnchor.constraint(equalToConstant: Constants.buttonSize.height).isActive = true
    
    return view
  }
  func createEmptyTrailingViewInsteadButton() -> UIView {
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.widthAnchor.constraint(equalToConstant: Constants.buttonSize.width).isActive = true
    view.heightAnchor.constraint(equalToConstant: Constants.buttonSize.height).isActive = true
    
    return view
  }
  
  func createCommonButton() -> UIButton {
    let button = UIButton()
    button.translatesAutoresizingMaskIntoConstraints = false
    button.widthAnchor.constraint(equalToConstant: Constants.buttonSize.width).isActive = true
    button.heightAnchor.constraint(equalToConstant: Constants.buttonSize.height).isActive = true
    
    return button
  }
}


//MARK: - Actions
private extension CommonNavPanel {
  @objc func backButtonAction() {
    delegate?.backButtonAction?()
  }
  @objc func burgerButtonAction() {
    let menuButtons = burgerMenuVStack.arrangedSubviews
    let hiddenButtonsArr = menuButtons.map { $0.isHidden }
    let isAllHiddenButtons = hiddenButtonsArr.allSatisfy { $0 }
    
    updateBurgerMenuVisibility(to: isAllHiddenButtons)
  }
  @objc func gamePauseButtonAction() {
    delegate?.gamePauseButtonAction?()
  }
  
  @objc func shopBurgerButtonAction() {
    delegate?.shopBurgerButtonAction?()
    burgerButtonAction() //close dropdown
  }
  @objc func leaderboardBurgerButtonAction() {
    delegate?.leaderboardBurgerButtonAction?()
    burgerButtonAction() //close dropdown
  }
  @objc func settingsBurgerButtonAction() {
    delegate?.settingsBurgerButtonAction?()
    burgerButtonAction() //close dropdown
  }
}
//MARK: - UI Helpers
private extension CommonNavPanel {
  func updateBurgerMenuVisibility(to isShouldVisible: Bool) {
    guard !burgerMenuAnimationIsProcessing else { return }
    
    let menuButtons = burgerMenuVStack.arrangedSubviews
    let delay = Double(animationDuration) / Double(menuButtons.count)
    
    burgerMenuAnimationIsProcessing = true
    
    if isShouldVisible {
      for (index, button) in menuButtons.enumerated() {
        DispatchQueue.main.asyncAfter(deadline: .now() + delay * Double(index)) {
          button.fadeIn()
         
          if index == menuButtons.indices.last {
            self.burgerMenuAnimationIsProcessing = false
          }
        }
      }
    } else {
      for (index, button) in menuButtons.reversed().enumerated() {
        DispatchQueue.main.asyncAfter(deadline: .now() + delay * Double(index)) {
          button.fadeOut()
          if index == menuButtons.indices.last {
            self.burgerMenuAnimationIsProcessing = false
          }
        }
      }
    }
  }
}
//MARK: - API
extension CommonNavPanel {
  func update(type: NavPanelType) {
    self.type = type
    
    let balanceVStackAlignment: UIStackView.Alignment
    let balanceTitleText: String
    let coinLabelText: String
    let flipAnimation: UIView.AnimationOptions
    switch type {
    case .gamePrepair:
      balanceVStackAlignment = .center
      balanceTitleText = CommonNavPanelTitles.balance.localized + ":"
      coinLabelText = Constants.getFormattedText(from: currentBalance)
      
      flipAnimation = [.transitionFlipFromTop]
    case .game(let betAmount):
      balanceVStackAlignment = .leading
      
      balanceTitleText = CommonNavPanelTitles.betAmount.localized + ":"
      coinLabelText = Constants.getFormattedText(from: Float(betAmount))
      
      flipAnimation = [.transitionFlipFromTop]
    case .gameEnd:
      balanceVStackAlignment = .center
      balanceTitleText = CommonNavPanelTitles.balance.localized + ":"
      coinLabelText = Constants.getFormattedText(from: currentBalance)
      
      flipAnimation = [.transitionFlipFromBottom]
    case .navigatable:
      balanceVStackAlignment = .center
      balanceTitleText = CommonNavPanelTitles.balance.localized + ":"
      coinLabelText = Constants.getFormattedText(from: currentBalance)
      
      flipAnimation = []
    }
    
    updateUIElementsAccordingType()
    balanceVStack.alignment = balanceVStackAlignment
    balanceTitle.text = balanceTitleText
    coinLabel.text = coinLabelText
    
    func updateUIElementsAccordingType() {
      UIView.transition(with: contentHStack, duration: animationDuration, options: flipAnimation) {
        self.contentHStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        switch type {
        case .gamePrepair:
          self.contentHStack.addArrangedSubview(self.emptyLeadingViewInsteadButton)
          self.contentHStack.addArrangedSubview(self.balanceVStack)
          self.contentHStack.addArrangedSubview(self.burgerButton)
        case .game:
          self.contentHStack.addArrangedSubview(self.balanceVStack)
          self.contentHStack.addArrangedSubview(self.gamePauseButton)
        case .gameEnd:
          self.contentHStack.addArrangedSubview(self.balanceVStack)
        case .navigatable:
          self.contentHStack.addArrangedSubview(self.backButton)
          self.contentHStack.addArrangedSubview(self.balanceVStack)
          self.contentHStack.addArrangedSubview(self.emptyTrailingViewInsteadButton)
        }
      }
    }
  }
  
  func updateBalance(to value: Float) {
    guard currentBalance != value else { return }
    currentBalance = value
    coinLabel.text = Constants.getFormattedText(from: value)
  }
}
//MARK: - NavPanelType
extension CommonNavPanel {
  enum NavPanelType {
    case gamePrepair // emptyLeadingViewInsteadButton + balanceVStack + burgerButton
    case game(betAmount: Int) // balanceVStack + burgerButton
    case gameEnd //balanceVStack
    
    case navigatable //backButton + balanceVStack + emptyTrailingViewInsteadButton
    
    var isGame: Bool {
      switch self {
      case .game: true
      default: false
      }
    }
  }
}
fileprivate struct Constants: CommonSettings {
  static var contentHStackSideIndent: CGFloat {
    sizeProportion(for: 16.0)
  }
  
  static var buttonSize: CGSize {
    let sideSize = sizeProportion(for: 46)
    
    return CGSize(width: sideSize, height: sideSize)
  }
  static let balanceVStackSpacing: CGFloat = 4
  static var balanceTitleFont: UIFont {
    let fontSize = sizeProportion(for: 14.0, minSize: 10.0)
    return AppFont.font(type: .regular, size: fontSize)
  }
  static let balanceTitleColor = AppColor.layerTwo
  
  static let balanceCoinHStackSpacing: CGFloat = 6
  static var coinImageViewSize: CGSize {
    let sideSize = sizeProportion(for: 24)
    
    return CGSize(width: sideSize, height: sideSize)
  }
  static var coinLabelFont: UIFont {
    let fontSize = sizeProportion(for: 18.0, minSize: 14.0)
    return AppFont.font(type: .bold, size: fontSize)
  }
  static let coinLabelColor = AppColor.layerOne
  
  static let burgerMenuVStackSpacing: CGFloat = 10
}
