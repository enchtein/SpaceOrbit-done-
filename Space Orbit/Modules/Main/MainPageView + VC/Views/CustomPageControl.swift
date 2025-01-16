import UIKit

final class CustomPageControl: UIView {
  private let types = PlanetType.allCases
  private var planetType: PlanetType = .auricas
  
  private lazy var commonHStack = createCommonHStack()
  
  init(planetType: PlanetType) {
    self.planetType = planetType
    
    super.init(frame: .zero)
    setupUI()
  }
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  override func layoutSubviews() {
    super.layoutSubviews()
    
    commonHStack.arrangedSubviews.forEach {
      $0.layoutIfNeeded()
      $0.setRounded()
    }
  }
  
  private func setupUI() {
    addSubview(commonHStack)
    
    types.forEach {
      let circle = createCircle()
      commonHStack.addArrangedSubview(circle)
      scaleAnimation(for: circle, for: $0, isSelected: planetType == $0)
    }
    
    commonHStack.fillToSuperview()
  }
}
//MARK: - UI elements creating
private extension CustomPageControl {
  func createCommonHStack() -> UIStackView {
    let stackView = UIStackView()
    stackView.axis = .horizontal
    stackView.distribution = .equalSpacing
    return stackView
  }
  func createCircle() -> UIView {
    let view = UIView()
    view.backgroundColor = .red
    view.translatesAutoresizingMaskIntoConstraints = false
    view.widthAnchor.constraint(equalTo: view.heightAnchor).isActive = true
    
    return view
  }
}
//MARK: - Helpers
private extension CustomPageControl {
  func scaleAnimation(for view: UIView, for type: PlanetType, isSelected: Bool) {
    let duration = isBaseVCAppeared ? Constants.animationDuration : .zero
    UIView.animate(withDuration: duration) {
      view.transform = isSelected ? CGAffineTransform(scaleX: 1.0, y: 1.0) : CGAffineTransform(scaleX: 0.8, y: 0.8)
      view.backgroundColor = isSelected ? AppColor.layerOne : AppColor.layerOne.withAlphaComponent(0.3)
    }
  }
}
//MARK: - API
extension CustomPageControl {
  func updateSelected(to type: PlanetType) {
    guard planetType != type else { return }
    planetType = type
    
    for (index, view) in commonHStack.arrangedSubviews.enumerated() {
      guard let viewType = PlanetType(rawValue: index) else { continue }
      
      scaleAnimation(for: view, for: viewType, isSelected: viewType == planetType)
    }
  }
}
//MARK: - Constants
fileprivate struct Constants: CommonSettings {
  static let unSelectedBg = AppColor.layerTwo
}
