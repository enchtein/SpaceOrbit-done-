import UIKit

final class PlanetInfoView: UIView {
  let planetType: PlanetType
  private var gameLvl: GameLevelType { planetType.gameLvl }
  
  private var hitCount: Int {
    gameLvl.orbits.map { $0.countOfStars }.reduce(0, +)
  }
  private var coeefficientModel: CoefficientCalculatorModel { CoefficientCalculatorModel.init(hit: hitCount) }
  
  private lazy var blurView = createBlurView()
  
  init(planetType: PlanetType) {
    self.planetType = planetType
    
    super.init(frame: .zero)
    
    setupUI()
  }
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func setupUI() {
    addSubview(blurView)
    blurView.fillToSuperview()
    
    let contentVStack = UIStackView()
    contentVStack.axis = .vertical
    contentVStack.spacing = 4.0
    contentVStack.alignment = .center
    
    contentVStack.addArrangedSubview(maxCoefHStack())
    contentVStack.addArrangedSubview(lvlHStack())
    
    addSubview(contentVStack)
    contentVStack.fillToSuperview(verticalIndents: Constants.sideIndent, horizontalIndents: Constants.sideIndent)
    
    cornerRadius = Constants.cornerRadius
    layer.borderWidth = 1.0
    layer.borderColor = AppColor.layerTwo.cgColor
  }
}
//MARK: - UI elements creating
private extension PlanetInfoView {
  func createBlurView() -> UIVisualEffectView {
    let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.dark)
    return UIVisualEffectView(effect: blurEffect)
  }
  
  func maxCoefHStack() -> UIStackView {
    let stackView = UIStackView()
    stackView.axis = .horizontal
    stackView.spacing = 4
    
    stackView.addArrangedSubview(maxCoefTitle())
    stackView.addArrangedSubview(maxCoefLabel())
    
    return stackView
  }
  func maxCoefTitle() -> UILabel {
    let label = UILabel()
    label.text = PlanetInfoViewTitles.maxX.localized + ":"
    label.textColor = Constants.titleColor
    label.font = Constants.titleFont
    
    return label
  }
  func maxCoefLabel() -> UILabel {
    let label = UILabel()
    label.text = Constants.getFormattedText(from: coeefficientModel.coefficient)
    label.textColor = AppColor.layerOne
    label.font = Constants.labelFont
    
    return label
  }
  
  func lvlHStack() -> UIStackView {
    let stackView = UIStackView()
    stackView.axis = .horizontal
    stackView.spacing = 4
    
    stackView.addArrangedSubview(lvlTitle())
    stackView.addArrangedSubview(lvlLabel())
    
    return stackView
  }
  func lvlTitle() -> UILabel {
    let label = UILabel()
    label.text = PlanetInfoViewTitles.lvl.localized + ":"
    label.textColor = Constants.titleColor
    label.font = Constants.titleFont
    
    return label
  }
  func lvlLabel() -> UILabel {
    let label = UILabel()
    label.text = gameLvl.name
    label.textColor = gameLvl.color
    label.font = Constants.labelFont
    
    return label
  }
}
//MARK: - Constants
fileprivate struct Constants: CommonSettings {
  static var cornerRadius: CGFloat {
    sizeProportion(for: 12.0)
  }
  
  static let titleColor = AppColor.layerTwo
  static var titleFont: UIFont {
    let fontSize = sizeProportion(for: 12.0, minSize: 9.0)
    return AppFont.font(type: .regular, size: fontSize)
  }
  
  static var labelFont: UIFont {
    let fontSize = sizeProportion(for: 12.0, minSize: 9.0)
    return AppFont.font(type: .bold, size: fontSize)
  }
  
  static var sideIndent: CGFloat {
    sizeProportion(for: 12.0)
  }
}
