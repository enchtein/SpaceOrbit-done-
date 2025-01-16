//
//  GamePageController.swift
//  Space Orbit
//
//  Created by Дмитрий Хероим on 25.12.2024.
//

import UIKit

class GamePageController: BaseViewController, StoryboardInitializable {
  @IBOutlet weak var gameContainer: UIView!
  @IBOutlet weak var gameContainerCenterY: NSLayoutConstraint!
  @IBOutlet weak var gameContainerVStack: UIStackView!
  @IBOutlet weak var gameContainerVStackLeading: NSLayoutConstraint!
  @IBOutlet weak var orbitTitle: UILabel!
  @IBOutlet weak var spaceOrbitContainer: UIView!
  
  var pageVC: MainPageViewController? { parent as? MainPageViewController }
  
  var planetType: PlanetType = .auricas
  private lazy var spaceOrbit = SpaceOrbit(planet: planetType, gameState: .pedding)
  private lazy var planetInfo = PlanetInfoView(planetType: planetType)
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Do any additional setup after loading the view.
  }
  
  override func addUIComponents() {
    spaceOrbitContainer.addSubview(spaceOrbit)
    spaceOrbit.fillToSuperview()
    
    spaceOrbitContainer.addSubview(planetInfo)
    planetInfo.translatesAutoresizingMaskIntoConstraints = false
    planetInfo.centerXAnchor.constraint(equalTo: spaceOrbitContainer.centerXAnchor).isActive = true
    planetInfo.bottomAnchor.constraint(equalTo: spaceOrbitContainer.bottomAnchor, constant: -14.5).isActive = true
  }
  override func setupColorTheme() {
    view.backgroundColor = .clear
    gameContainer.backgroundColor = .clear
    spaceOrbitContainer.backgroundColor = .clear
    
    orbitTitle.textColor = Constants.orbitTitleColor
  }
  override func setupFontTheme() {
    orbitTitle.font = Constants.orbitTitleFont
  }
  override func setupLocalizeTitles() {
    orbitTitle.text = planetType.name.uppercased()
  }
  override func additionalUISettings() {
    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(inGameTapAction))
    view.addGestureRecognizer(tapGesture)
    
    let upSwipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(inGameUpSwipeAction))
    upSwipeGesture.direction = .up
    view.addGestureRecognizer(upSwipeGesture)
    
    let downSwipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(inGameDownSwipeAction))
    downSwipeGesture.direction = .down
    view.addGestureRecognizer(downSwipeGesture)
  }
  
  private func updateUIElementsVisibility(_ gameState: GameState) {
    switch gameState {
    case .pedding:
      orbitTitle.linearShowAnimated(in: gameContainerVStack)
    default:
      orbitTitle.linearHideAnimated(in: gameContainerVStack)
    }
    
    UIView.animate(withDuration: view.animationDuration) {
      self.planetInfo.alpha = gameState == .pedding ? 1.0 : .zero
      
      switch gameState {
      case .win, .crashed:
        self.gameContainerCenterY.constant = self.view.frame.midY
        self.gameContainerVStackLeading.constant = .zero
        self.gameContainer.transform = .init(scaleX: 1.33, y: 1.33)
      default:
        self.gameContainerCenterY.constant = .zero
        self.gameContainerVStackLeading.constant = 23.0
        self.gameContainer.transform = .identity
      }
      self.view.layoutIfNeeded()
    }
  }
  
  override func currentParticipantSet(_ participant: Participant) {
    spaceOrbit.currentParticipantSet(participant)
  }
}
//MARK: - API
extension GamePageController {
  func forceUpdateGameStateToWin() {
    spaceOrbit.forceUpdateGameStateToWin()
  }
  func updateGameState(_ gameState: GameState) {
    guard spaceOrbit.gameState != gameState else { return }

    updateUIElementsVisibility(gameState)
    spaceOrbit.changeGameState(to: gameState)
  }
  func outerUpdateGameState(_ gameState: GameState) {
    pageVC?.outerUpdateGameState(gameState)
    updateUIElementsVisibility(gameState)
  }
  func updateHitCoinsCount(to value: Int) {
    pageVC?.updateHitCoinsCount(to: value)
  }
}
//MARK: - Gesture Actions
private extension GamePageController {
  @objc func inGameTapAction() {
    guard spaceOrbit.gameState == .playing else { return }
    spaceOrbit.changeRocketDirection()
  }
  @objc func inGameUpSwipeAction() {
    guard spaceOrbit.gameState == .playing else { return }
    spaceOrbit.changeRocketOrbit(direction: .up)
  }
  @objc func inGameDownSwipeAction() {
    guard spaceOrbit.gameState == .playing else { return }
    spaceOrbit.changeRocketOrbit(direction: .down)
  }
}
//MARK: - Constants
fileprivate struct Constants: CommonSettings {
  static var orbitTitleFont: UIFont {
    let fontSize = sizeProportion(for: 26.0)
    return AppFont.font(type: .bold, size: fontSize)
  }
  static let orbitTitleColor = AppColor.layerTwo
}
