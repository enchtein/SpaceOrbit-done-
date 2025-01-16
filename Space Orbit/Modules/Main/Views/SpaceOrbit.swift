//
//  SpaceOrbit.swift
//  Space Orbit
//
//  Created by Дмитрий Хероим on 12.12.2024.
//

import UIKit

final class SpaceOrbit: UIView {
  //---> Setting properties (Start)
  private let baseRotationIndent: CGFloat = -(.pi / 2) //non changable constants
  private let fullCircleRadians: CGFloat = .pi * 2 //non changable constants
  private let twentyDegreesInRadians: CGFloat = CGFloat(20) * .pi / 180
  
  private let bulletShotInterval: TimeInterval = 1.0
  
  private let rocketCrashActive = true //false for debugging
  //<--- Setting properties (End)
  
  private let outerOrbitSideIndent: CGFloat = 3.0
  private let spacingBetweenOrbits: CGFloat = 35.0
  
  private var orbitLayers: [CAShapeLayer] = []
  private var orbitParametersModels: [SpaceOrbitParametersModel] = []
  private var orbitObjs: [UIView] = []
  private var orbitAsteroids: [AsteroidView] = []
  private var starsViews: [UIView] = []
  
  private var containerRadius: CGFloat { min(self.bounds.width, self.bounds.height) / 2 }
  private var orbitCenter: CGPoint { CGPoint(x: containerRadius, y: containerRadius) }
  
  private let models: [SpaceOrbitModel]
  private let planet: PlanetType
  private var gameLvl: GameLevelType { planet.gameLvl }
  
  private(set) var gameState: GameState
  
  private lazy var planetImageView = createPlanetImageView()
  private var planetConstraints: [NSLayoutConstraint] = []
  private lazy var rocket = createSpaceOrbitRocet()
  private var currentRocketLayer: CALayer?
  
  //---> animation properties (Start)
  private var isClockwiseRotation: Bool = true
  private var switcherOrbitIndentAnglet: CGFloat = .zero
  private var currentAnimation: CAKeyframeAnimation?
  private var displayLink: CADisplayLink?
  //<--- animation properties (End)
  
  //---> bullet properties (Start)
  private lazy var bulletsManager = createBulletsManager()
  private var timer: Timer?
  private var shotsCount: Int = 0
  //<--- bullet properties (End)
  
  private var parentVC: GamePageController? { findViewController() as? GamePageController }
  
  init(planet: PlanetType = .jackpotia, gameState: GameState = .playing) {
    self.planet = planet
    self.gameState = gameState
    var models: [SpaceOrbitModel] = []
    for orbit in planet.gameLvl.orbits {
      let orbitModel = SpaceOrbitModel(countOfStars: orbit.countOfStars, countOfAsteroids: orbit.countOfAsteroids, orbit: orbit)
      models.append(orbitModel)
    }
    self.models = models
    
    super.init(frame: .zero)
    
    setupUI()
    transform = CGAffineTransform(rotationAngle: baseRotationIndent)
  }
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  override func layoutSubviews() {
    super.layoutSubviews()
    
    if !isBaseVCAppeared {
      drawOrbitLayers()
    }
  }
  
  private func setupUI() {
    addSubview(planetImageView)
    
    updatePlanetImageViewConstraintsAccordingGameState()
    setAlphaUIOrbitElements(to: .zero)
    
//    DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
//      self.changeGameState(to: .playing)
//      DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
//        self.changeGameState(to: .win)
//      }
//    }
//
//    DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
//      self.gameDidStart()
//    }
//    DispatchQueue.main.asyncAfter(deadline: .now() + 15.0) {
//      self.gameDidEnd()
//    }
  }
}

//MARK: - UI elements creating
private extension SpaceOrbit {
  func drawOrbitLayers() {
    //clear layer
    orbitLayers.forEach { $0.removeFromSuperlayer() }
    orbitLayers.removeAll()
    orbitParametersModels.removeAll()
    //remove views
    orbitAsteroids.removeAll()
    starsViews.removeAll()
    
    orbitObjs.forEach { $0.removeFromSuperview() }
    orbitObjs.removeAll()
    //remove rocket
    rocket.removeFromSuperview()
    
    for model in models {
      let params = SpaceOrbitParametersModel(according: model,
                                             containerRadius: containerRadius,
                                             outerOrbitSideIndent: outerOrbitSideIndent,
                                             spacingBetweenOrbits: spacingBetweenOrbits)
      orbitParametersModels.append(params)
      let orbitLayer = createOrbitLayer(according: params)
      
      //1) add layer to view
      layer.addSublayer(orbitLayer)
      orbitLayers.append(orbitLayer)
      
      //2) add objects
      drawOrbitObjects(according: params, and: model)
    }
    
    //3) add rocket at first orbit
    drawRocket()
    
    //4) set non visible orbit UI
    setAlphaUIOrbitElements(to: .zero)
  }
  
  func createOrbitLayer(according params: SpaceOrbitParametersModel) -> CAShapeLayer {
    let layer = CAShapeLayer()
    layer.fillColor = UIColor.clear.cgColor
    layer.strokeColor = AppColor.layerTwo.cgColor
    layer.lineWidth = 1.0
    
    //create path for section
    let path = UIBezierPath()
    path.addArc(withCenter: orbitCenter, radius: params.radius, startAngle: params.startAngle, endAngle: params.endAngle, clockwise: true)
    
    //closing path
    path.close()
    
    layer.path = path.cgPath
    layer.name = String(params.orbit.rawValue)
    
    return layer
  }
  func drawOrbitObjects(according paramsModel: SpaceOrbitParametersModel, and model: SpaceOrbitModel) {
    let asteroidObjs = Array(repeating: OrbitObjectModel.init(angle: .zero, outerOrbitSideIndent: paramsModel.indent, orbitRadius: paramsModel.radius, type: .asteroid), count: model.countOfAsteroids)
    let starObjs = Array(repeating: OrbitObjectModel.init(angle: .zero, outerOrbitSideIndent: paramsModel.indent, orbitRadius: paramsModel.radius, type: .star), count: model.countOfStars)
    var orbitObjects = asteroidObjs + starObjs
    orbitObjects.shuffle()
    
    let countOfObjects = orbitObjects.count
    let angleStep = fullCircleRadians / CGFloat(countOfObjects)
    
    for index in 0..<countOfObjects {
      let object = orbitObjects[index]
      
      let additionalAngle = angleStep * CGFloat(index)
      let objAngle = paramsModel.startAngle + additionalAngle
      
      let reCreatedObj = OrbitObjectModel.init(angle: objAngle, basedOn: orbitObjects[index])
      
      let view: UIView
      switch object.type {
      case .asteroid:
        let asteroid = AsteroidView.init(frame: .init(origin: .zero, size: reCreatedObj.size))
        asteroid.updateImageView(to: -baseRotationIndent)
        view = asteroid
        orbitAsteroids.append(asteroid)
      case .star:
        view = UIView(frame: .init(origin: .zero, size: reCreatedObj.size))
        view.backgroundColor = AppColor.systemThree
        starsViews.append(view)
      }
      
      view.center = reCreatedObj.center
      view.cornerRadius = reCreatedObj.cornerRadius
      
      //add rotation
      let startTransformAngle = objAngle - (baseRotationIndent / 2)
      view.transform = CGAffineTransform(rotationAngle: startTransformAngle)
      
      addSubview(view)
      orbitObjs.append(view)
    }
  }
  func drawRocket() {
    guard let largestOrbit = findOrbitParametersModel(for: .low) else { return }
    guard isOrbitLayerExist(for: largestOrbit.orbit) else { return }
    
    let xPosition = (largestOrbit.radius + (cos(largestOrbit.startAngle) * largestOrbit.radius)) + largestOrbit.indent
    let yPosition = (largestOrbit.radius + (sin(largestOrbit.startAngle) * largestOrbit.radius)) + largestOrbit.indent
    
    rocket.center = .init(x: xPosition, y: yPosition)
    
    addSubview(rocket)
    rocket.currentOrbit = largestOrbit.orbit
  }
  
  func createPlanetImageView() -> UIImageView {
    let imageView = UIImageView()
    imageView.image = planet.image
    
    imageView.translatesAutoresizingMaskIntoConstraints = false
    imageView.transform = CGAffineTransform(rotationAngle: -baseRotationIndent)
    
    return imageView
  }
  func createSpaceOrbitRocet() -> RocketView {
    let view = RocketView(frame: .init(origin: .zero, size: Constants.rocketSize))
    view.updateImageView(to: (baseRotationIndent * -1) * 2)
    
    return view
  }
  
  func createRockerFrameCheckerView() -> UIView? {
    let pos = getCurrentRocketPresentationPosition()
    let transform = getCurrentRocketPresentationTransform()
    let transform2 = getCurrentRockerPresentationRotationAngle()
    
    guard let pos, let transform, let transform2 else { return nil }
    let checkerFrameView = UIView()
    
    checkerFrameView.frame.size = Constants.rocketFrameCheckerSize //half of rocker size
    checkerFrameView.center = pos
    checkerFrameView.transform = transform
    checkerFrameView.transform = CGAffineTransform(rotationAngle: transform2)
    checkerFrameView.backgroundColor = .green
    
    return checkerFrameView
  }
}
//MARK: - UI Helpers
private extension SpaceOrbit {
  func updatePlanetImageViewConstraintsAccordingGameState() {
    let multiplier: CGFloat
    if gameState.isOrbitVisible {
      switch gameLvl {
      case .low: multiplier = 1.0 - (0.124 * 2)
      case .medium: multiplier = 1.0 - (0.182 * 2)
      case .high: multiplier = 1.0 - (0.268 * 2)
      }
    } else {
      multiplier = 1.0
    }
    
    let width = NSLayoutConstraint(item: planetImageView, attribute: .width, relatedBy: .equal, toItem: self, attribute: .width, multiplier: multiplier, constant: 0)
    let height = NSLayoutConstraint(item: planetImageView, attribute: .height, relatedBy: .equal, toItem: self, attribute: .height, multiplier: multiplier, constant: 0)
    
    let centerX = NSLayoutConstraint(item: planetImageView, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1.0, constant: 0)
    let centerY = NSLayoutConstraint(item: planetImageView, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1.0, constant: 0)
    
    let newConstraints = [width, height, centerX, centerY]
    
    //Animate changes
    UIView.animate(withDuration: self.animationDuration, delay: .zero, options: .curveEaseInOut) {
      //1) deactivate exist constraints
      NSLayoutConstraint.deactivate(self.planetConstraints)
      //2) activate new constraints
      NSLayoutConstraint.activate(newConstraints)
      
      self.layoutIfNeeded()
    } completion: { [weak self] _ in
      guard let self else { return }
      //clear exist constraints from imageView
      self.planetConstraints.forEach { self.planetImageView.removeConstraint($0) }
      //set new constraints from imageView
      self.planetConstraints = newConstraints
    }
  }
  
  func setAlphaUIOrbitElements(to value: CGFloat) {
    rocket.alpha = value
    orbitLayers.forEach { $0.opacity = Float(value) }
    orbitObjs.forEach { $0.alpha = value }
  }
  func updateUIAccordingGameState(endCompletion: (() -> Void)? = nil) {
    let alphaValue: CGFloat = gameState.isOrbitVisible ? 1.0 : .zero
    
    UIView.animate(withDuration: animationDuration) {
      self.setAlphaUIOrbitElements(to: alphaValue)
      
      self.layoutIfNeeded()
    } completion: { _ in
      endCompletion?()
    }
  }
  
  func findCurrentOrbitIndex() -> Int? {
    guard let currentOrbitType = rocket.currentOrbit else { return nil }
    return orbitParametersModels.firstIndex { $0.orbit == currentOrbitType }
  }
  func findOuterOrbitParametersModel() -> SpaceOrbitParametersModel? {
    guard let currentOrbitIndex = findCurrentOrbitIndex() else { return nil }
    let outerIndex = orbitParametersModels.index(before: currentOrbitIndex)
    guard orbitParametersModels.indices.contains(outerIndex) else { return nil }
    return orbitParametersModels[outerIndex]
  }
  func findInnerOrbitParametersModel() -> SpaceOrbitParametersModel? {
    guard let currentOrbitIndex = findCurrentOrbitIndex() else { return nil }
    let innerIndex = orbitParametersModels.index(after: currentOrbitIndex)
    guard orbitParametersModels.indices.contains(innerIndex) else { return nil }
    return orbitParametersModels[innerIndex]
  }
  
  func findOrbitParametersModel(for type: SpaceOrbitType?) -> SpaceOrbitParametersModel? {
    guard let type else { return nil }
    return orbitParametersModels.first { $0.orbit == type }
  }
  func isOrbitLayerExist(for type: SpaceOrbitType?) -> Bool {
    findOrditLayer(for: type) != nil
  }
  func findOrditLayer(for type: SpaceOrbitType?) -> CAShapeLayer? {
    guard let type else { return nil }
    let searchableOrbitName = String(type.rawValue)
    
    return orbitLayers.first { $0.name?.elementsEqual(searchableOrbitName) ?? false }
  }
}
//MARK: - UI Helpers (Rocket movment)
private extension SpaceOrbit {
  func createPathAccordingCurrentRocketDirection(for orbitType: SpaceOrbitType) -> UIBezierPath? {
    guard let currentOrbitParams = findOrbitParametersModel(for: orbitType) else { return nil }
    
    // Пересчитываем путь на основе текущей позиции
    let currentPosition = getCurrentRocketPresentationPosition() ?? .zero
    let angle = atan2(currentPosition.y - center.y, currentPosition.x - center.x)
    // Пересчитываем начальный и конечный углы в зависимости от нового направления
    let startAngle = !isClockwiseRotation ? angle : angle + .pi * 2
    let endAngle = !isClockwiseRotation ? angle - .pi * 2 : angle
    
    let totalStartAngle: CGFloat
    let totalEndAngle: CGFloat
    if isClockwiseRotation {
      totalStartAngle = startAngle < endAngle ? startAngle : endAngle
      totalEndAngle = startAngle < endAngle ? endAngle : startAngle
    } else {
      totalStartAngle = startAngle > endAngle ? startAngle : endAngle
      totalEndAngle = startAngle > endAngle ? endAngle : startAngle
    }
    
    return UIBezierPath(arcCenter: center,
                        radius: currentOrbitParams.radius,
                        startAngle: totalStartAngle,
                        endAngle: totalEndAngle,
                        clockwise: isClockwiseRotation)
  }
  func startRocketAnimation() {
    guard let rocketOrbit = rocket.currentOrbit else { return }
    guard let newPath = createPathAccordingCurrentRocketDirection(for: rocketOrbit) else { return }
    
    let animTypeKey = SpaceOrbitAnimationType.rocketCircularMotion.rawValue
    
    //remove exist animation
    rocket.layer.removeAnimation(forKey: animTypeKey)
    rocket.updateImageView(to: (baseRotationIndent * -1)) //set correct radians angle for rocket image
    //create new animation
    if let currentAnimation {
      currentAnimation.path = newPath.cgPath
      
      rocket.layer.add(currentAnimation, forKey: animTypeKey)
    } else {
      // Настройка анимации
      let animation = CAKeyframeAnimation(keyPath: "position")
      animation.path = newPath.cgPath
      animation.duration = rocketOrbit.orbitMovementDuration // Длительность анимации
      animation.repeatCount = Float.infinity
      animation.calculationMode = CAAnimationCalculationMode.paced
      animation.rotationMode = CAAnimationRotationMode.rotateAuto
      
      rocket.layer.add(animation, forKey: animTypeKey)
      currentAnimation = animation
      
      // Start display link to observe changes
      displayLink = CADisplayLink(target: self, selector: #selector(rocketPositionDidChange))
      displayLink?.add(to: .main, forMode: .default)
    }
    
    //remove switch orbit animation if exist
    SpaceOrbitAnimationType.switchOrbitTypes.forEach {
      rocket.layer.removeAnimation(forKey: $0.rawValue)
    }
  }
  func stopRocketAnimation() {
    rocket.updateImageView(to: (baseRotationIndent * 2))
    // Остановка анимации
    rocket.layer.removeAllAnimations()
    currentAnimation = nil
    displayLink?.invalidate()
    displayLink = nil
  }
  
  @objc func rocketPositionDidChange() {
    guard let checkerFrameView = createRockerFrameCheckerView() else { return }
    
    let obj = orbitObjs.first { $0.frame.contains(checkerFrameView.center) }
    guard let obj else { return }
    
    if let asteroidObj = obj as? AsteroidView {
      //asteroid
      if rocketCrashActive {
        changeGameState(to: .crashed)
        parentVC?.outerUpdateGameState(.crashed)
      } else {
        asteroidObj.backgroundColor = .green
      }
    } else {
      //star
      let newBgColor: UIColor = rocketCrashActive ? .clear : .red
      if obj.backgroundColor != newBgColor && gameState != .crashed {
        AppSoundManager.shared.point()
      }
      obj.backgroundColor = newBgColor
      
      let hittedViews = starsViews.filter { $0.backgroundColor == newBgColor }
      parentVC?.updateHitCoinsCount(to: hittedViews.count)
      
      if starsViews.count == hittedViews.count && rocketCrashActive {
        changeGameState(to: .win)
        parentVC?.outerUpdateGameState(.win)
      }
    }
  }
  
  func getCurrentRocketPresentationPosition() -> CGPoint? {
    guard let presentationLayer = rocket.layer.presentation() else { return nil }
    return presentationLayer.position
  }
  func getCurrentRocketPresentationTransform() -> CGAffineTransform? {
    guard let presentationLayer = rocket.layer.presentation() else { return nil }
    let currentTransform = CATransform3DGetAffineTransform(presentationLayer.transform)
    
    return currentTransform
  }
  func getCurrentRockerPresentationRotationAngle() -> CGFloat? {
    guard let currentTransform = getCurrentRocketPresentationTransform() else { return nil }
    let currentRotation = atan2(currentTransform.b, currentTransform.a) // Угол в радианах
    
    return currentRotation
  }
  
  func switchPocketOrbitIfPossible(for type: SpaceOrbitAnimationType) {
    guard SpaceOrbitAnimationType.switchOrbitTypes.contains(type) else { return }
    
    let newOrbitParams: SpaceOrbitParametersModel?
    switch type {
    case .rocketCircularMotion: return
    case .switchToInnerOrbitMotion: newOrbitParams = findInnerOrbitParametersModel()
    case .switchToOuterOrbitMotion: newOrbitParams = findOuterOrbitParametersModel()
    }
    guard let newOrbitParams else { return }
    let orbitMovementDuration = newOrbitParams.orbit.orbitMovementDuration
    
    //remove exist animation
    rocket.layer.removeAnimation(forKey: SpaceOrbitAnimationType.rocketCircularMotion.rawValue)
    // Пересчитываем путь на основе текущей позиции
    let currentPosition = getCurrentRocketPresentationPosition() ?? .zero
    rocket.center = currentPosition
    let angle = atan2(currentPosition.y - center.y, currentPosition.x - center.x)
    
    let bulletAnimationDuration = calculateBulletMovementDuration(according: newOrbitParams)
    let rocketSpeedInRadians = calculateCircleRocketSpeedInRadians(with: orbitMovementDuration) / 2
    
    let additionalRadiansAngleByTime = bulletAnimationDuration * rocketSpeedInRadians
    let totalAdditionalRadiansAngle = isClockwiseRotation ? additionalRadiansAngleByTime : additionalRadiansAngleByTime * -1
    let expectedRadiansAngle = angle + totalAdditionalRadiansAngle
    
    let endRocketPosition = calculateEndRocketOnChangePosition(center: center, angle: expectedRadiansAngle, radius: newOrbitParams.radius)
    //rocket position animation
    let animKey = type.rawValue
    
    let animation = CABasicAnimation(keyPath: "position")
    animation.toValue = endRocketPosition
    animation.duration = orbitMovementDuration / 10
    
    animation.fillMode = .forwards
    animation.isRemovedOnCompletion = false
    
    animation.delegate = self
    animation.setValue(animKey, forKey: animKey)
    rocket.layer.add(animation, forKey: animKey)
    
    let imageRadiansIndent = isClockwiseRotation ? (baseRotationIndent * 2) : .zero
    rocket.updateImageView(to: expectedRadiansAngle + imageRadiansIndent)
    
    rocket.currentOrbit = newOrbitParams.orbit
    AppSoundManager.shared.orbitalTransition()
  }
}
//MARK: - API
extension SpaceOrbit {
  func forceUpdateGameStateToWin() {
    guard gameState != .win else { return }
    changeGameState(to: .win)
    parentVC?.outerUpdateGameState(.win)
  }
  func changeGameState(to value: GameState) {
    guard gameState != value else { return }
    //1)
    let prevState = gameState
    gameState = value
    
    if prevState == .paused && value == .pedding {
      //restore layer speed
      updateLayerAnimationSpeedAccordingGameState()
      //remove layer animations
      gameDidEnd()
    }
    
    //2)
    updatePlanetImageViewConstraintsAccordingGameState()
    //3)
    updateUIAccordingGameState { [weak self] in
      guard let self else { return }
      switch gameState {
      case .pedding: gameDidEnd()
        
      case .playing: gameDidStart(prevState: prevState)
      case .paused: pause()
      
      case .win: gameDidEnd()
      case .crashed: gameDidEnd()
      }
    }
  }
  func changeRocketDirection() {
    isClockwiseRotation.toggle()
    AppSoundManager.shared.missleTurn()
    
    startRocketAnimation()
  }
  func changeRocketOrbit(direction: UISwipeGestureRecognizer.Direction) {
    let switchOrbitAnimationType: SpaceOrbitAnimationType?
    switch direction {
    case .up: switchOrbitAnimationType = .switchToOuterOrbitMotion
    case .down: switchOrbitAnimationType = .switchToInnerOrbitMotion
    default: switchOrbitAnimationType = nil
    }
    guard let switchOrbitAnimationType else { return }
    
    let isSwitchedNow = (rocket.layer.animationKeys() ?? []).contains{ $0.elementsEqual(SpaceOrbitAnimationType.switchToInnerOrbitMotion.rawValue) || $0.elementsEqual(SpaceOrbitAnimationType.switchToOuterOrbitMotion.rawValue) }
    guard !isSwitchedNow else { return }
    
    switchPocketOrbitIfPossible(for: switchOrbitAnimationType)
  }
  
  func currentParticipantSet(_ participant: Participant) {
    rocket.updateRocketImage(to: participant.selectedRocket)
  }
}
//MARK: - UI Helpers (AsteroidBullet)
private extension SpaceOrbit {
  func createBulletsManager() -> SpaceOrbitBulletsManager {
    let manager = SpaceOrbitBulletsManager()
    manager.delegate = self
    
    return manager
  }
  func createBullet() -> AsteroidBulletView {
    AsteroidBulletView(frame: .init(origin: .zero, size: .init(width: 16.0, height: 16.0)))
  }
  func createAndPrepairBulletToShot() {
    guard let currentOrbitParametersModel = findOrbitParametersModel(for: rocket.currentOrbit) else { return }
    let orbitMovementDuration = currentOrbitParametersModel.orbit.orbitMovementDuration
    
    let currentRadiansAngle = calculateCurrentAngleForBullet()
    let bulletAnimationDuration = calculateBulletMovementDuration(according: currentOrbitParametersModel)
    let rocketSpeedInRadians = calculateCircleRocketSpeedInRadians(with: orbitMovementDuration)
    
    let additionalRadiansAngleByTime = bulletAnimationDuration * rocketSpeedInRadians
    let expectedRadiansAngle = currentRadiansAngle + additionalRadiansAngleByTime
    
    let endBulletPosition = calculateEndBulletPostion(center: center, angle: expectedRadiansAngle, radius: currentOrbitParametersModel.radius)
    let bulletShotAnimtaionDuration = (bulletAnimationDuration * 2)
    let currentTime = CACurrentMediaTime()
    let currentTimeInSuperLayer = layer.convertTime(currentTime, to: nil)
    
    //process bullet shot
    let bullet = createBullet()
    let bulletRotationAngle: CGFloat = calculateEndBulletAngle(according: expectedRadiansAngle)
    bullet.transform = CGAffineTransform(rotationAngle: bulletRotationAngle)
    
    bullet.center = center
    addSubview(bullet)
    
    bulletsManager.getShot(animationDelegate: self, bullet: bullet, to: endBulletPosition, with: bulletShotAnimtaionDuration, cfTimeInterval: currentTimeInSuperLayer)
  }
  
  func calculateBulletMovementDuration(according orbit: SpaceOrbitParametersModel) -> TimeInterval {
    let rocketSpeed = calculateRocketSpeed(at: orbit)
    
    let timeFromCenterToRocket = orbit.radius / rocketSpeed
    return timeFromCenterToRocket
  }
  func calculateEndBulletPostion(center: CGPoint, angle: CGFloat, radius: CGFloat) -> CGPoint {
    var updatedAngle: CGFloat
    if shotsCount > .zero {
      let additionalAngleIndent = isClockwiseRotation ? baseRotationIndent : .zero
      updatedAngle = angle + additionalAngleIndent
    } else {
      let additionalAngleIndent = isClockwiseRotation ? .zero : baseRotationIndent
      updatedAngle = angle + additionalAngleIndent
    }
    
    if !isClockwiseRotation {
      let additionalAngle = twentyDegreesInRadians
      updatedAngle -= additionalAngle
    }
    
    if isClockwiseRotation {
      updatedAngle += switcherOrbitIndentAnglet
    } else {
      updatedAngle -= switcherOrbitIndentAnglet
    }
    
    // Рассчитываем смещение по осям X и Y с учётом тригонометрии
    let offsetX = cos(updatedAngle) * radius * 2
    let offsetY = sin(updatedAngle) * radius * 2
    
    // Создаём новую точку, добавляя смещение к центру
    let newPoint = CGPoint(x: center.x + offsetX, y: center.y + offsetY)
    
    return newPoint
  }
  
  func calculateRocketSpeed(at orbit: SpaceOrbitParametersModel) -> CGFloat {
    return (fullCircleRadians * orbit.radius) / orbit.orbit.orbitMovementDuration
  }
  func calculateCircleRocketSpeedInRadians(with rocketAnimationDuration: TimeInterval) -> CGFloat {
    fullCircleRadians / rocketAnimationDuration
  }
  
  func calculateEndRocketOnChangePosition(center: CGPoint, angle: CGFloat, radius: CGFloat) -> CGPoint {
    let offsetX = cos(angle) * radius
    let offsetY = sin(angle) * radius
    
    // Создаём новую точку, добавляя смещение к центру
    let newPoint = CGPoint(x: center.x + offsetX, y: center.y + offsetY)
    
    return newPoint
  }
  
  func calculateCurrentAngleForBullet() -> Double {
    let existAnimations = rocket.layer.animationKeys() ?? []
    let switchAnimationType = SpaceOrbitAnimationType.switchOrbitTypes.first { existAnimations.contains($0.rawValue) }
    
    let currentRadiansAngle: CGFloat
    if let switchAnimationType {
      let orbitParams: SpaceOrbitParametersModel?
      
      switch switchAnimationType {
      case .switchToInnerOrbitMotion: orbitParams = findInnerOrbitParametersModel()
      case .switchToOuterOrbitMotion: orbitParams = findOuterOrbitParametersModel()
      case .rocketCircularMotion: orbitParams = nil
      }
      
      let additionalSwitchOrbitRadiansAngle: Double
      if let orbitParams {
        let orbitMovementDuration = orbitParams.orbit.orbitMovementDuration
        
        let bulletAnimationDuration = calculateBulletMovementDuration(according: orbitParams)
        let rocketSpeedInRadians = calculateCircleRocketSpeedInRadians(with: orbitMovementDuration) / 2
        
        let additionalRadiansAngleByTime = bulletAnimationDuration * rocketSpeedInRadians
        additionalSwitchOrbitRadiansAngle = isClockwiseRotation ? additionalRadiansAngleByTime : additionalRadiansAngleByTime * -1
      } else {
        additionalSwitchOrbitRadiansAngle = .zero
      }
      
      let currentPosition = getCurrentRocketPresentationPosition() ?? .zero
      let angle = atan2(currentPosition.y - center.y, currentPosition.x - center.x)
      
      let additionalAngle: CGFloat
      if isClockwiseRotation {
        additionalAngle = ((baseRotationIndent / 2) * -1) + twentyDegreesInRadians + additionalSwitchOrbitRadiansAngle
      } else {
        additionalAngle = (baseRotationIndent / 2) - twentyDegreesInRadians + additionalSwitchOrbitRadiansAngle
      }
      
      currentRadiansAngle = angle + additionalAngle
    } else {
      currentRadiansAngle = getCurrentRockerPresentationRotationAngle() ?? .zero
    }
    
    return currentRadiansAngle
  }
  func calculateEndBulletAngle(according expectedRadiansAngle: Double) -> Double {
    let bulletRotationAngle: CGFloat
    if isClockwiseRotation {
      let additionalAngle = shotsCount == .zero ? baseRotationIndent : .zero
      bulletRotationAngle = expectedRadiansAngle + .pi - additionalAngle + switcherOrbitIndentAnglet
    } else {
      bulletRotationAngle = expectedRadiansAngle + .pi - baseRotationIndent - twentyDegreesInRadians - switcherOrbitIndentAnglet
    }
    
    return bulletRotationAngle
  }
}
//MARK: - UI Helpers (Game process)
private extension SpaceOrbit {
  func gameDidStart(prevState: GameState) {
    timer = Timer.scheduledTimer(timeInterval: bulletShotInterval, target: self, selector: #selector(getShot), userInfo: nil, repeats: true)
    timer?.fire()
    
    if prevState == .paused {
      updateLayerAnimationSpeedAccordingGameState()
    } else {
      startRocketAnimation()
    }
  }
  func updateLayerAnimationSpeedAccordingGameState() {
    if gameState == .paused {
      let currentTime = CACurrentMediaTime()
      let pausedTime = layer.convertTime(currentTime, from: nil)
      layer.speed = .zero
      layer.timeOffset = pausedTime
    } else {
      let pausedTime = layer.timeOffset
      layer.speed = 1.0
      layer.timeOffset = .zero
      layer.beginTime = 0.0
      let timeSincePause = layer.convertTime(CACurrentMediaTime(), from: nil) - pausedTime
      layer.beginTime = timeSincePause
    }
  }
  func gameDidEnd() {
    isClockwiseRotation = true
    timer?.invalidate()
    timer = nil
    
    stopRocketAnimation()
    bulletsManager.removeAll()
    drawOrbitLayers() //re-draw game
    shotsCount = .zero
  }
  func pause() {
    timer?.invalidate()
    
    updateLayerAnimationSpeedAccordingGameState()
  }
  
  @objc func getShot() {
    createAndPrepairBulletToShot()
    shotsCount += 1
  }
}
//MARK: - SpaceOrbitBulletsManagerDelegate
extension SpaceOrbit: SpaceOrbitBulletsManagerDelegate {
  func bulletPositionDidChange(bullet: AsteroidBulletView, to value: CGPoint) {
    guard let checkerFrameView = createRockerFrameCheckerView() else { return }
    
    guard checkerFrameView.frame.contains(value) else { return }
    bulletsManager.remove(bullet)
    
    guard gameState != .win && rocketCrashActive else { return }
    changeGameState(to: .crashed)
    parentVC?.outerUpdateGameState(.crashed)
  }
}

//MARK: - CAAnimationDelegate
extension SpaceOrbit: CAAnimationDelegate {
  func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
    bulletsManager.animationDidStop(anim)
    
    SpaceOrbitAnimationType.switchOrbitTypes.forEach { type in
      if let value = anim.value(forKey: type.rawValue) as? String, value.elementsEqual(type.rawValue) {
        let multiplier: CGFloat
        switch rocket.currentOrbit {
        case .low: multiplier = 0.0
        case .medium: multiplier = 0.5//0.75
        case .high: multiplier = 1.0
        default: multiplier = 0.0
        }
        let angle = twentyDegreesInRadians * multiplier
        switcherOrbitIndentAnglet = -angle
        
        startRocketAnimation()
      }
    }
  }
}

//MARK: - Constants
fileprivate struct Constants {
  static let rocketSize = CGSize(width: 54.0, height: 54.0)
  static var rocketFrameCheckerSize: CGSize {
    CGSize(width: rocketSize.width / 2, height: rocketSize.height / 2)
  }
}
//MARK: - enum SpaceOrbitAnimationType
fileprivate enum SpaceOrbitAnimationType: String {
  case rocketCircularMotion
  case switchToInnerOrbitMotion
  case switchToOuterOrbitMotion
  
  static let switchOrbitTypes: [SpaceOrbitAnimationType] = [.switchToOuterOrbitMotion, .switchToInnerOrbitMotion]
}
