//
//  TimingViewController.swift
//  Space Orbit
//
//  Created by Дмитрий Хероим on 04.01.2025.
//

import UIKit

class TimingViewController: CommonBasedOnPresentationViewController {
  @IBOutlet weak var topBarContainer: UIView!
  @IBOutlet weak var topBarButton: CommonButton!
  
  @IBOutlet weak var timerContainer: UIView!
  @IBOutlet weak var timerTitle: UILabel!
  @IBOutlet weak var timerLabel: UILabel!
  @IBOutlet weak var timerHelperMsg: UILabel!
  
  @IBOutlet weak var pauseViewContainer: UIView!
  @IBOutlet weak var pauseVStack: UIStackView!
  @IBOutlet weak var pauseTitle: UILabel!
  @IBOutlet weak var pauseLeadingSpacer: UIView!
  @IBOutlet weak var pauseButtonsHStack: UIStackView!
  @IBOutlet weak var homeButton: CommonButton!
  @IBOutlet weak var homeButtonHeight: NSLayoutConstraint!
  @IBOutlet weak var soundButton: CommonButton!
  @IBOutlet weak var playButton: CommonButton!
  @IBOutlet weak var pauseTrailingSpacer: UIView!
  
  @IBOutlet weak var turtorialContainer: UIView!
  @IBOutlet weak var turtorialTitle: UILabel!
  @IBOutlet weak var turtorialTitleBottom: NSLayoutConstraint!
  @IBOutlet weak var turtorialSubContainer: UIView!
  @IBOutlet weak var turtorialTapScreenContainer: UIView!
  @IBOutlet weak var turtorialTapScreenTitle: UILabel!
  @IBOutlet weak var turtorialTapScreenHelperMsg: UILabel!
  
  @IBOutlet weak var turtorialSwipeUpDownContainer: UIView!
  @IBOutlet weak var turtorialSwipeUpDownTitle: UILabel!
  @IBOutlet weak var turtorialSwipeUpDownHelpersMsg: UILabel!
  
  var gameState: GameState = .pedding
  private let baseRotationIndent: CGFloat = -(.pi / 2) //non changable constants
  
  private var timerDuration = 3
  private var timer: Timer?
  
  private var isTurtorialAlreadyAppeared: Bool {
    UserDefaults.standard.isTurtorialAlreadyAppeared
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Do any additional setup after loading the view.
    view.backgroundColor = .clear
    removeBasePanGesture()
  }
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    if gameState != .paused && isTurtorialAlreadyAppeared {
      startTimer()
    }
  }
  
  override func addUIComponents() {
    let turtorialTapScreenSpaceOrbit = TimingSpaceOrbit(frame: .zero)
    turtorialTapScreenContainer.addSubview(turtorialTapScreenSpaceOrbit)
    
    turtorialTapScreenSpaceOrbit.translatesAutoresizingMaskIntoConstraints = false
    turtorialTapScreenSpaceOrbit.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10.5).isActive = true
    turtorialTapScreenSpaceOrbit.heightAnchor.constraint(equalTo: turtorialTapScreenSpaceOrbit.widthAnchor).isActive = true
    turtorialTapScreenSpaceOrbit.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    turtorialTapScreenSpaceOrbit.topAnchor.constraint(equalTo: turtorialTapScreenContainer.centerYAnchor).isActive = true
    let leadingRocket = createSpaceOrbitRocet()
    leadingRocket.alpha = 0.5
    leadingRocket.updateImageView(to: baseRotationIndent)
    turtorialTapScreenContainer.addSubview(leadingRocket)
    leadingRocket.trailingAnchor.constraint(equalTo: turtorialTapScreenContainer.centerXAnchor).isActive = true
    leadingRocket.centerYAnchor.constraint(equalTo: turtorialTapScreenContainer.centerYAnchor).isActive = true
    
    let trailingRocket = createSpaceOrbitRocet()
    trailingRocket.updateImageView(to: (baseRotationIndent * -1))
    turtorialTapScreenContainer.addSubview(trailingRocket)
    trailingRocket.leadingAnchor.constraint(equalTo: turtorialTapScreenContainer.centerXAnchor).isActive = true
    trailingRocket.centerYAnchor.constraint(equalTo: turtorialTapScreenContainer.centerYAnchor).isActive = true
    
    
    
    let turtorialSwipeUpDownSpaceOrbitFirst = TimingSpaceOrbit(frame: .zero)
    turtorialSwipeUpDownContainer.addSubview(turtorialSwipeUpDownSpaceOrbitFirst)
    
    turtorialSwipeUpDownSpaceOrbitFirst.translatesAutoresizingMaskIntoConstraints = false
    turtorialSwipeUpDownSpaceOrbitFirst.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10.5).isActive = true
    turtorialSwipeUpDownSpaceOrbitFirst.heightAnchor.constraint(equalTo: turtorialSwipeUpDownSpaceOrbitFirst.widthAnchor).isActive = true
    turtorialSwipeUpDownSpaceOrbitFirst.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    turtorialSwipeUpDownSpaceOrbitFirst.topAnchor.constraint(equalTo: turtorialSwipeUpDownContainer.topAnchor, constant: 26.0).isActive = true
    
    
    let turtorialSwipeUpDownSpaceOrbitLast = TimingSpaceOrbit(frame: .zero)
    turtorialSwipeUpDownContainer.addSubview(turtorialSwipeUpDownSpaceOrbitLast)
    turtorialSwipeUpDownSpaceOrbitLast.translatesAutoresizingMaskIntoConstraints = false
    turtorialSwipeUpDownSpaceOrbitLast.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10.5).isActive = true
    turtorialSwipeUpDownSpaceOrbitLast.heightAnchor.constraint(equalTo: turtorialSwipeUpDownSpaceOrbitLast.widthAnchor).isActive = true
    turtorialSwipeUpDownSpaceOrbitLast.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    turtorialSwipeUpDownSpaceOrbitLast.topAnchor.constraint(equalTo: turtorialSwipeUpDownContainer.topAnchor, constant: 65.5).isActive = true
    
    //1)
    let secondRocket = createSpaceOrbitRocet()
    secondRocket.alpha = 0.3
    secondRocket.updateImageView(to: (baseRotationIndent * -1))
    turtorialSwipeUpDownContainer.addSubview(secondRocket)
    secondRocket.centerXAnchor.constraint(equalTo: turtorialSwipeUpDownContainer.centerXAnchor).isActive = true
    secondRocket.topAnchor.constraint(equalTo: turtorialSwipeUpDownContainer.topAnchor, constant: 19.0).isActive = true
    //2)
    let thirdRocket = createSpaceOrbitRocet()
    thirdRocket.alpha = 0.6
    thirdRocket.updateImageView(to: (baseRotationIndent * -1))
    turtorialSwipeUpDownContainer.addSubview(thirdRocket)
    thirdRocket.centerXAnchor.constraint(equalTo: turtorialSwipeUpDownContainer.centerXAnchor).isActive = true
    thirdRocket.topAnchor.constraint(equalTo: turtorialSwipeUpDownContainer.topAnchor, constant: 39.0).isActive = true
    //3)
    let firstRocket = createSpaceOrbitRocet()
    firstRocket.updateImageView(to: (baseRotationIndent * -1))
    turtorialSwipeUpDownContainer.addSubview(firstRocket)
    firstRocket.centerXAnchor.constraint(equalTo: turtorialSwipeUpDownContainer.centerXAnchor).isActive = true
    firstRocket.topAnchor.constraint(equalTo: turtorialSwipeUpDownContainer.topAnchor).isActive = true
  }
  override func setupColorTheme() {
    topBarButton.setupEnabledBgColor(to: AppColor.layerOne)
    topBarButton.setupEnabledTitleColor(to: AppColor.backgroundOne)
    
    [timerTitle, turtorialTapScreenHelperMsg, turtorialSwipeUpDownHelpersMsg].forEach {
      $0?.textColor = Constants.additionalTextColor
    }
    
    [timerLabel, timerHelperMsg, pauseTitle, turtorialTitle, turtorialTapScreenTitle, turtorialSwipeUpDownTitle].forEach {
      $0?.textColor = Constants.mainTextColor
    }
    
    [topBarContainer, timerContainer, pauseViewContainer, pauseLeadingSpacer, pauseTrailingSpacer, turtorialContainer, turtorialSubContainer, turtorialTapScreenContainer, turtorialSwipeUpDownContainer].forEach {
      $0?.backgroundColor = .clear
    }
    
    homeButton.backgroundColor = AppColor.layerTwo
    soundButton.backgroundColor = AppColor.layerTwo
    playButton.backgroundColor = AppColor.accentTwo
    [homeButton, soundButton, playButton].forEach {
      $0?.layer.borderColor = AppColor.layerTwo.cgColor
      $0?.layer.borderWidth = 1.0
    }
  }
  override func setupFontTheme() {
    timerLabel.font = Constants.timerLabelFont
    
    [timerTitle, turtorialTapScreenTitle, turtorialSwipeUpDownTitle].forEach {
      $0?.font = Constants.timerTitleFont
    }
    [timerHelperMsg, turtorialTapScreenHelperMsg, turtorialSwipeUpDownHelpersMsg].forEach {
      $0?.font = Constants.timerHelperMsgFont
    }
    [pauseTitle, turtorialTitle].forEach {
      $0?.font = Constants.turtorialTitleFont
    }
  }
  override func setupLocalizeTitles() {
    timerTitle.text = TimingTitles.getReady.localized
    updateTimerLabel()
    timerHelperMsg.text = TimingTitles.timerHelperMsg.localized
    
    updateTopBarTitleIfNeeded()
    
    pauseTitle.text = TimingTitles.pause.localized
    
    turtorialTitle.text = TimingTitles.tutorial.localized
    turtorialTapScreenTitle.text = TimingTitles.turtorialTapScreenTitle.localized
    turtorialTapScreenHelperMsg.text = TimingTitles.turtorialTapScreenHelperMsg.localized
    turtorialSwipeUpDownTitle.text = TimingTitles.turtorialSwipeUpDownTitle.localized
    turtorialSwipeUpDownHelpersMsg.text = TimingTitles.turtorialSwipeUpDownHelpersMsg.localized
  }
  override func setupIcons() {
    [homeButton, soundButton, playButton].forEach {
      $0?.setTitle("", for: .normal)
    }
    
    homeButton.setImage(AppImage.Timing.home, for: .normal)
    updateSoundButtonImage()
    playButton.setImage(AppImage.Timing.play, for: .normal)
  }
  override func setupConstraintsConstants() {
    homeButtonHeight.constant = Constants.homeButtonHeight
    turtorialTitleBottom.constant = Constants.turtorialTitleBottom
  }
  override func additionalUISettings() {
    if isTurtorialAlreadyAppeared {
      turtorialContainer.alpha = .zero
      topBarContainer.alpha = gameState == .paused ? .zero : 1.0
      pauseViewContainer.alpha = gameState != .paused ? .zero : 1.0
      timerContainer.alpha = gameState == .paused ? .zero : 1.0
    } else {
      turtorialContainer.alpha = 1.0
      pauseViewContainer.alpha = .zero
      timerContainer.alpha = .zero
    }
    
    topBarButton.cornerRadius = Constants.topBarButtonCornerRadius
    topBarButton.setupTitle(contentEdgeInsets: Constants.topBarButtonContentEdgeInsets)
    
    turtorialTapScreenContainer.clipsToBounds = true
    turtorialSwipeUpDownContainer.clipsToBounds = true
    
    [homeButton, soundButton, playButton].forEach {
      $0?.cornerRadius = Constants.homeButtonRadius
    }
    
    pauseVStack.spacing = Constants.pauseVStackSpacing
    pauseButtonsHStack.spacing = Constants.pauseButtonsHStackSpacing
  }
  
  //MARK: - Button actions
  @IBAction func homeButtonAction(_ sender: CommonButton) {
    AppSoundManager.shared.tapButton()
    
    let mainVC = AppCoordinator.shared.currentNavigator?.children.first as? MainViewController
    mainVC?.showOutGameAlertFromTimingVC()
  }
  @IBAction func soundButtonAction(_ sender: CommonButton) {
    UserDefaults.standard.isGameSoundOff.toggle()
    AppSoundManager.shared.tapButton()
    
    updateSoundButtonImage()
  }
  @IBAction func playButtonAction(_ sender: CommonButton) {
    AppSoundManager.shared.tapButton()
    
    resumeGameAfterOurGameAlert()
  }
  @IBAction func topBarAction(_ sender: CommonButton) {
    if !isTurtorialAlreadyAppeared {
      UserDefaults.standard.isTurtorialAlreadyAppeared = true
      
      turtorialContainer.setOpaqueAnimated()
      topBarContainer.setNonOpaqueAnimated()
      timerContainer.setNonOpaqueAnimated { [weak self] in
        self?.startTimer()
      }
      
      updateTopBarTitleIfNeeded()
    } else {
      stopTimer()
    }
  }
}
//MARK: - Timer helpers
private extension TimingViewController {
  func startTimer() {
    guard timer == nil else { return }
    timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(fireTimer), userInfo: nil, repeats: true)
  }
  @objc func fireTimer() {
    timerDuration -= 1
    
    if timerDuration > .zero {
      updateTimerLabel()
    } else {
      stopTimer()
    }
  }
  func stopTimer() {
    AppSoundManager.shared.startGame()
    
    timer?.invalidate()
    timer = nil
    dismiss(animated: true) {
      let mainVC = AppCoordinator.shared.currentNavigator?.children.first as? MainViewController
      mainVC?.outerUpdateGameState(.playing)
    }
  }
  
  func updateTimerLabel() {
    timerLabel.text = String(timerDuration)
  }
}
//MARK: - UI helpers
private extension TimingViewController {
  func updateTopBarTitleIfNeeded() {
    let newTitle = !isTurtorialAlreadyAppeared ? TimingTitles.ok.localized : TimingTitles.skip.localized
    UIView.transition(with: topBarButton, duration: Constants.animationDuration, options: .transitionCrossDissolve) {
      self.topBarButton.setupTitle(with: newTitle)
    }
  }
  func createSpaceOrbitRocet() -> RocketView {
    let view = RocketView(frame: .init(origin: .zero, size: Constants.rocketSize))
    view.translatesAutoresizingMaskIntoConstraints = false
    view.widthAnchor.constraint(equalToConstant: Constants.rocketSize.width).isActive = true
    view.heightAnchor.constraint(equalToConstant: Constants.rocketSize.height).isActive = true
    
    return view
  }
  func updateSoundButtonImage() {
    let image = UserDefaults.standard.isGameSoundOff ? AppImage.Timing.soundOff : AppImage.Timing.soundOn
    
    UIView.transition(with: soundButton, duration: Constants.animationDuration, options: .transitionCrossDissolve) {
      self.soundButton.setImage(image, for: .normal)
    }
  }
}
//MARK: - API
extension TimingViewController {
  func resumeGameAfterOurGameAlert() {
    pauseViewContainer.setOpaqueAnimated()
    topBarContainer.setNonOpaqueAnimated()
    timerContainer.setNonOpaqueAnimated { [weak self] in
      self?.startTimer()
    }
  }
}
//MARK: - Constants
fileprivate struct Constants: CommonSettings {
  static var timerTitleFont: UIFont {
    let fontSize = sizeProportion(for: 18.0, minSize: 14.0)
    return AppFont.font(type: .bold, size: fontSize)
  }
  static var timerLabelFont: UIFont {
    let fontSize = sizeProportion(for: 160.0, minSize: 120.0)
    return AppFont.font(type: .black, size: fontSize)
  }
  static var timerHelperMsgFont: UIFont {
    let fontSize = sizeProportion(for: 14.0, minSize: 10.0)
    return AppFont.font(type: .regular, size: fontSize)
  }
  static var turtorialTitleFont: UIFont {
    let fontSize = sizeProportion(for: 48.0, minSize: 36.0)
    return AppFont.font(type: .black, size: fontSize)
  }
  
  static let mainTextColor = AppColor.layerOne
  static let additionalTextColor = AppColor.layerTwo
  
  static var topBarButtonCornerRadius: CGFloat {
    sizeProportion(for: 12.0)
  }
  static var topBarButtonContentEdgeInsets: UIEdgeInsets {
    let hIndent = topBarButtonCornerRadius
    let vIndent = sizeProportion(for: 18.0)
    
    return .init(top: hIndent, left: vIndent, bottom: hIndent, right: vIndent)
  }
  
  static let rocketSize = CGSize(width: 54.0, height: 54.0)
  
  static var homeButtonHeight: CGFloat {
    sizeProportion(for: 64.0)
  }
  static var homeButtonRadius: CGFloat {
    sizeProportion(for: 16.0)
  }
  
  static var pauseVStackSpacing: CGFloat{
    sizeProportion(for: 31.0)
  }
  static var pauseButtonsHStackSpacing: CGFloat{
    sizeProportion(for: 28.0)
  }
  
  static var turtorialTitleBottom: CGFloat {
    sizeProportion(for: 32.0)
  }
}
