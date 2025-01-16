import UIKit

final class MainViewController: BaseViewController, StoryboardInitializable {
  @IBOutlet weak var bgImageView: UIImageView!
  
  @IBOutlet weak var navPanelContainer: UIView!
  @IBOutlet weak var navPanelContainerHeight: NSLayoutConstraint!
  
  @IBOutlet weak var gameAreaContainer: UIView!
  @IBOutlet weak var gameAreaContainerBottom: NSLayoutConstraint!
  
  @IBOutlet weak var pageControlContainer: UIView!
  @IBOutlet weak var customPageControlContainer: UIView!
  @IBOutlet weak var customPageControlContainerTop: NSLayoutConstraint!
  
  @IBOutlet weak var gameBottomContainer: UIView!
  @IBOutlet weak var gameBottomHitCoinCollection: UICollectionView!
  @IBOutlet weak var gameBottomHitCoinCollectionHeight: NSLayoutConstraint!
  @IBOutlet weak var gameBottomCoinOutContainer: UIView!
  @IBOutlet weak var gameBottomCoinOutContainerHeight: NSLayoutConstraint!
  
  
  @IBOutlet weak var setBetContainer: UIView!
  @IBOutlet weak var setBetBorderContainer: UIView!
  @IBOutlet weak var setBetBorderOverlayContainer: UIView!
  
  
  @IBOutlet weak var setBetSubContainer: UIView!
  @IBOutlet weak var setBetVStack: UIStackView!
  @IBOutlet weak var setBetAmountHStack: UIStackView!
  @IBOutlet weak var setBetSubSubContainer: UIView!
  @IBOutlet weak var amountMinusButton: CommonButton!
  @IBOutlet weak var amountMinusButtonHeight: NSLayoutConstraint!
  @IBOutlet weak var amountMinusButtonWidth: NSLayoutConstraint!
  @IBOutlet weak var amountTitle: UILabel!
  @IBOutlet weak var amountLabel: UILabel!
  @IBOutlet weak var amountPlusButton: CommonButton!
  @IBOutlet weak var betButton: CommonButton!
  
  @IBOutlet weak var setBetAmountCollection: UICollectionView!
  @IBOutlet weak var setBetAmountCollectionHeight: NSLayoutConstraint!
  
  @IBOutlet weak var setBetVStackBottom: NSLayoutConstraint!
  @IBOutlet weak var setBetContainerBottom: NSLayoutConstraint!
  
  private(set) lazy var navPanel = CommonNavPanel.init(type: .gamePrepair, delegate: self)
  private lazy var customPageControl = CustomPageControl(planetType: .auricas)
  
  private lazy var pageVC = MainPageViewController.init(transitionStyle: .scroll, navigationOrientation: .horizontal, options: [UIPageViewController.OptionsKey.interPageSpacing: 10])
  
  private lazy var coinOutButton = CoinOutButton()
  
  private lazy var viewModel = MainViewModel(participant: currentParticipant, delegate: self)
  
  private lazy var endGameResultView = EngGameResultView(delegate: self)

  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Do any additional setup after loading the view.
    gameBottomHitCoinCollection.register(UINib(nibName: HitCoinCollectionViewCell.identifier, bundle: nil), forCellWithReuseIdentifier: HitCoinCollectionViewCell.identifier)
    gameBottomHitCoinCollection.delegate = self
    gameBottomHitCoinCollection.dataSource = self
    gameBottomHitCoinCollection.contentInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
    gameBottomHitCoinCollection.isUserInteractionEnabled = false
    
    setBetAmountCollection.register(UINib(nibName: BetAmountCollectionViewCell.identifier, bundle: nil), forCellWithReuseIdentifier: BetAmountCollectionViewCell.identifier)
    setBetAmountCollection.delegate = self
    setBetAmountCollection.dataSource = self
    
    viewModel.viewDidLoad()
  }
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    LocalNotificationsProvider.shared.requestPermissionAndScheduleNotificationIfNeeded()
  }
  
  override func addUIComponents() {
    navPanelContainerHeight.isActive = false
    navPanelContainer.addSubview(navPanel)
    navPanel.fillToSuperview()
    
    addChild(pageVC)
    gameAreaContainer.addSubview(pageVC.view)
    pageVC.view.fillToSuperview()
    pageVC.didMove(toParent: self)
    
    customPageControlContainer.addSubview(customPageControl)
    customPageControl.fillToSuperview(verticalIndents: 8.0, horizontalIndents: 12.0)
    
    gameBottomCoinOutContainerHeight.isActive = false
    gameBottomCoinOutContainer.addSubview(coinOutButton)
    coinOutButton.fillToSuperview(horizontalIndents: 16.0)
    
    view.addSubview(endGameResultView)
  }
  override func setupColorTheme() {
    navPanelContainer.backgroundColor = .clear
    gameAreaContainer.backgroundColor = .clear
    pageControlContainer.backgroundColor = .clear
    customPageControlContainer.backgroundColor = .clear
    
    gameBottomContainer.backgroundColor = .clear
    gameBottomHitCoinCollection.backgroundColor = .clear
    gameBottomCoinOutContainer.backgroundColor = .clear
    
    
    setBetContainer.backgroundColor = .clear
    setBetBorderContainer.backgroundColor = .clear
    setBetBorderOverlayContainer.backgroundColor =  AppColor.backgroundOne
    setBetSubContainer.backgroundColor = .clear
    
    setBetBorderContainer.layer.borderWidth = 2
    setBetBorderContainer.layer.borderColor = AppColor.layerTwo.cgColor
    
    amountMinusButton.setupEnabledBgColor(to: AppColor.layerTwo)
    amountMinusButton.setupEnabledTitleColor(to: AppColor.layerOne)
    amountPlusButton.setupEnabledBgColor(to: AppColor.layerTwo)
    amountPlusButton.setupEnabledTitleColor(to: AppColor.layerOne)
    
    betButton.setupEnabledBgColor(to: AppColor.accentOne)
    betButton.setupEnabledTitleColor(to: AppColor.layerOne)
    betButton.layer.borderWidth = 2
    betButton.layer.borderColor = AppColor.layerTwo.cgColor
    
    amountTitle.textColor = AppColor.layerTwo
    amountLabel.textColor = AppColor.layerOne
    
    setBetSubSubContainer.backgroundColor = AppColor.layerTwo
    setBetSubSubContainer.layer.borderWidth = 2
    setBetSubSubContainer.layer.borderColor = AppColor.layerTwo.cgColor
  }
  override func setupFontTheme() {
    amountMinusButton.setupFont(to: Constants.amountMinusButtonFont)
    amountPlusButton.setupFont(to: Constants.amountPlusButtonFont)
    betButton.setupFont(to: Constants.betButtonFont)
    
    amountTitle.font = Constants.amountTitleFont
    amountLabel.font = Constants.amountLabelFont
  }
  override func setupLocalizeTitles() {
    amountMinusButton.setupTitle(with: "-")
    amountTitle.text = MainTitles.betAmount.localized
    amountLabel.text = "10"
    amountPlusButton.setupTitle(with: "+")
    betButton.setupTitle(with: MainTitles.bet.localized)
  }
  override func setupIcons() {
    bgImageView.image = AppImage.GameLevelType.low
  }
  override func setupConstraintsConstants() {
    endGameResultView.translatesAutoresizingMaskIntoConstraints = false
    endGameResultView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    endGameResultView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    endGameResultView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16.0).isActive = true
    
    gameBottomHitCoinCollectionHeight.constant = Constants.hCollectionHeight
    setBetAmountCollectionHeight.constant = Constants.hCollectionHeight
    setBetVStackBottom.constant = UIDevice.current.hasNotch ? 21 : .zero
    amountMinusButtonHeight.constant = Constants.amountMinusButtonHeight
    amountMinusButtonWidth.constant = Constants.amountMinusButtonWidth
  }
  override func additionalUISettings() {
    bgImageView.contentMode = .scaleAspectFill
    view.layoutIfNeeded()
    
    amountMinusButton.cornerRadius = 8.0
    amountPlusButton.cornerRadius = 8.0
    betButton.cornerRadius = 14.0
    
    setBetContainer.roundCorners([.topLeft, .topRight], radius: Constants.setBetContainerRadius)
    setBetBorderContainer.cornerRadius = Constants.setBetContainerRadius
    setBetBorderOverlayContainer.roundCorners([.topLeft, .topRight], radius: Constants.setBetOverlayBorderContainerRadius)
    setBetContainer.clipsToBounds = true
    
    setBetSubSubContainer.cornerRadius = 14.0
    
    coinOutButton.addTarget(self, action: #selector(coinOutButtonAction), for: .touchUpInside)
  }
  
  //MARK: - Actions
  @IBAction func amountMinusButtonAction(_ sender: CommonButton) {
    viewModel.decreaseBalance()
  }
  @IBAction func amountPlusButtonAction(_ sender: CommonButton) {
    viewModel.increaseBalance()
  }
  @IBAction func betButtonAction(_ sender: CommonButton) {
    showTimingVC()
  }
  @objc private func coinOutButtonAction() {
    pageVC.forceUpdateGameStateToWin()
  }
  
  override func currentParticipantSet(_ participant: Participant) {
    viewModel.replaceParticipant(by: participant)
    navPanel.updateBalance(to: participant.coinsScore)
  }
}
//MARK: - API
extension MainViewController {
  func pageControlDidChange(to planetType: PlanetType) {
    viewModel.updateGamePlanet(to: planetType)
    customPageControl.updateSelected(to: planetType)
    
    updateBgImage(to: planetType.gameLvl)
  }
  func outerUpdateGameState(_ gameState: GameState) {
    viewModel.updateGameState(to: gameState)
  }
  
  func updateHitCoinsCount(to value: Int) {
    viewModel.updateHitCoinsCount(to: value)
  }
  
  func showOutGameAlertFromTimingVC() {
    let timingVC = presentedViewController as? TimingViewController
    let timingPresentationVC = timingVC?.presentationController as? TimingPresentationController
    
    guard let timingVC, let timingPresentationVC else { return }
    
    let stayAction = UIAlertAction(title: MainTitles.stay.localized, style: .default) { [weak timingVC, weak timingPresentationVC] _ in
      timingPresentationVC?.containerView?.setNonOpaqueAnimated {
        timingVC?.resumeGameAfterOurGameAlert()
      }
    }
    let quitAction = UIAlertAction(title: MainTitles.quit.localized, style: .destructive) { [weak self, weak timingVC] _ in
      timingVC?.dismiss(animated: false)
      self?.outerUpdateGameState(.pedding)
    }
    
    timingPresentationVC.containerView?.setOpaqueAnimated {
      UIAlertController.alert(with: MainTitles.quitGame.localized, message: MainTitles.quitGameMsg.localized, actions: [stayAction, quitAction])
    }
  }
}
//MARK: - UI Helpers
private extension MainViewController {
  func updateBgImage(to type: GameLevelType) {
    UIView.transition(with: bgImageView, duration: view.animationDuration, options: .transitionCrossDissolve) {
      self.bgImageView.image = type.image
    }
  }
  func updateUIAccording(_ gameState: GameState) {
    switch gameState {
    case .playing, .paused:
      pageControlContainer.fadeOut()
      gameBottomContainer.fadeIn()
    default:
      pageControlContainer.fadeIn()
      gameBottomContainer.fadeOut()
    }
    
    switch gameState {
    case .win, .crashed:
      gameAreaContainerBottom.constant = .zero
      
      let model = viewModel.getEndGameResultModel()
      endGameResultView.showAnimated(with: model)
    default:
      endGameResultView.hideAnimated()
    }
    
    switch gameState {
    case .win, .crashed: return
    default:
      let pageControlContainerHeight = pageControlContainer.frame.height
      let gameBottomContainerIndent = self.screenHeight - gameBottomContainer.frame.minY
      let setBetContainerBottomConstant = gameState.isOrbitVisible ? setBetContainer.frame.height : .zero
      
      let gameAreaContainerBottomConstant: CGFloat
      if gameState.isOrbitVisible {
        gameAreaContainerBottomConstant = gameBottomContainerIndent
      } else {
        gameAreaContainerBottomConstant = pageControlContainerHeight + setBetContainer.frame.height
      }
      
      self.gameAreaContainerBottom.constant = gameAreaContainerBottomConstant
      
      UIView.animate(withDuration: view.animationDuration) {
        self.setBetContainerBottom.constant = -setBetContainerBottomConstant
        self.view.layoutIfNeeded()
      }
    }
  }
  
  func showTimingVC() {
    let timingVC = TimingViewController.createFromNibHelper()
    timingVC.gameState = viewModel.gameState
    
    timingVC.modalPresentationStyle = .custom
    timingVC.transitioningDelegate = self
    
    present(timingVC, animated: true)
  }
}
//MARK: - CommonNavPanelDelegate
extension MainViewController: CommonNavPanelDelegate {
  func gamePauseButtonAction() {
    viewModel.updateGameState(to: .paused)
    showTimingVC()
  }
  
  func shopBurgerButtonAction() {
    AppCoordinator.shared.push(.shop)
  }
  func leaderboardBurgerButtonAction() {
    AppCoordinator.shared.push(.leaderboard)
  }
  func settingsBurgerButtonAction() {
    AppCoordinator.shared.push(.settings)
  }
}
//MARK: - hitTest overriding
extension UIWindow {
  open override func hitTest(_ point: CGPoint, with e: UIEvent?) -> UIView? {
    if let mainVC = UIApplication.topViewController() as? MainViewController {
      let convertedPoint = mainVC.view.convert(point, to: mainVC.navPanel.burgerMenuVStack)
      
      if mainVC.navPanel.burgerMenuVStack.bounds.contains(convertedPoint) {
        return mainVC.navPanel.burgerMenuVStack.hitTest(convertedPoint, with: e)
      } else {
        return super.hitTest(point, with: e)
      }
    } else {
      return super.hitTest(point, with: e)
    }
  }
}
//MARK: - UICollectionViewDelegate
extension MainViewController: UICollectionViewDelegate {
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    didSelectItem(at: indexPath, in: collectionView)
    collectionView.deselectItem(at: indexPath, animated: false)
  }
}
//MARK: - UICollectionViewDataSource
extension MainViewController: UICollectionViewDataSource {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    guard let type = type(of: collectionView) else { return .zero }
    return viewModel.numberOfItemsInSection(section, for: type)
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    guard let cell = cellForItem(at: indexPath, in: collectionView) else { return UICollectionViewCell() }
    
    if let cell = cell as? BetAmountCollectionViewCell {
      let type = viewModel.betAmountType(at: indexPath)
      let isAvailableBetAmountType = viewModel.isAvailableBetAmountType(at: indexPath)
      cell.setupCell(with: type, isAvailable: isAvailableBetAmountType)
      
      return cell
    } else if let cell = cell as? HitCoinCollectionViewCell {
      let model = viewModel.hitCoinModel(at: indexPath)
      cell.setupCell(with: model)
      
      return cell
    } else {
      return UICollectionViewCell()
    }
  }
  private func cellForItem(at indexPath: IndexPath, in collectionView: UICollectionView) -> UICollectionViewCell? {
    guard let type = type(of: collectionView) else { return nil }
    
    let identifier: String
    switch type {
    case .hit: identifier = HitCoinCollectionViewCell.identifier
    case .betAmount: identifier = BetAmountCollectionViewCell.identifier
    }
    
    return collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath)
  }
  private func type(of collection: UICollectionView) -> MainViewModel.CollectionType? {
    switch collection {
    case gameBottomHitCoinCollection: .hit
    case setBetAmountCollection: .betAmount
    default: nil
    }
  }
}
extension MainViewController: UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
    guard let type = type(of: collectionView) else { return .zero }
    switch type {
    case .betAmount: return .zero
    case .hit: return 2.0
    }
  }
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
    guard let type = type(of: collectionView) else { return .zero }
    switch type {
    case .betAmount: return .zero
    case .hit: return .zero
    }
  }
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    guard let type = type(of: collectionView) else { return .zero }
    
    switch type {
    case .betAmount:
      let width = (collectionView.frame.width / CGFloat(BetAmountType.editableTypes.count)) - Constants.spacingBetweenBetAmountTypeCells
      return CGSize(width: width, height: collectionView.frame.height)
    case .hit:
      let clearWidth = collectionView.frame.width - 16.0
      let width = (clearWidth / 4.5) - 2.0
      
      return CGSize(width: width, height: collectionView.frame.height)
    }
  }
}
//MARK: - Actions (UICollectionViewDelegate)
private extension MainViewController {
  func didSelectItem(at indexPath: IndexPath, in collectionView: UICollectionView) {
    let collectionCell = collectionView.cellForItem(at: indexPath)
    
    guard let setBetAmountCell = collectionCell as? BetAmountCollectionViewCell else { return }
    let otherCells = collectionView.visibleCells.filter { $0 !== setBetAmountCell }.map { $0 as? BetAmountCollectionViewCell }
    
    let isChangable = viewModel.isAvailableBetAmountType(at: indexPath)
    setBetAmountCell.contentContainer.springAnimation(scaleFactor: 0.85) { [weak self] in
      guard isChangable else { return }
      
      setBetAmountCell.updateSelectedState(to: true)
      otherCells.forEach { $0?.updateSelectedState(to: false) }
      
      self?.viewModel.didSelectBetAmountType(at: indexPath)
    }
  }
}
//MARK: - MainViewModelDelegate
extension MainViewController: MainViewModelDelegate {
  func navPanelTypeDidChange(to value: CommonNavPanel.NavPanelType) {
    navPanel.update(type: value)
  }
  
  func increaseBalanceButtonAvailabilityChange(to isAvailable: Bool) {
    amountPlusButton.isEnabled = isAvailable
  }
  
  func decreaseBalanceButtonAvailabilityChange(to isAvailable: Bool) {
    amountMinusButton.isEnabled = isAvailable
  }
  
  func currentBetAmountDidChange(to value: Int) {
    amountLabel.text = String(value)
  }
  func gameStateDidChange(to value: GameState) {
    pageVC.updateGameState(value)
    updateUIAccording(value)
  }
  
  func hitCoinOutDidChange(to value: Float) {
    coinOutButton.updateCoinOutTitle(with: value)
  }
  
  func hitCoinDataSourceDidChange() {
    gameBottomHitCoinCollection.reloadData()
  }
  func hitCoinModelCellTypeDidChange(to model: HitCoinModel, at indexPath: IndexPath) {
    guard let hitCell = gameBottomHitCoinCollection.cellForItem(at: indexPath) as? HitCoinCollectionViewCell else { return }
    hitCell.updateCell(with: model)
  }
  func updateHitCoinsCollectionPositionVisability(to indexPath: IndexPath, animated: Bool) {
    gameBottomHitCoinCollection.scrollToItem(at: indexPath, at: .right, animated: animated)
  }
  
  func participantDidChange(to value: Participant) {
    AppCoordinator.shared.updateCurrentParticipant(with: value)
  }
  func participantBalanceDidChange(to value: Float) {
    navPanel.updateBalance(to: value)
  }
}
//MARK: - EngGameResultViewDelegate
extension MainViewController: EngGameResultViewDelegate {
  func peddingNewGameButtonAction() {
    viewModel.resetBetAmount()
    viewModel.updateGameState(to: .pedding)
  }
  
  func rePlayGameButtonAction() {
    viewModel.updateGameState(to: .pedding)
    DispatchQueue.main.asyncAfter(deadline: .now() + Constants.animationDuration) {
      self.viewModel.updateGameState(to: .playing)
    }
  }
  
  func shareResultGameButtonAction() {
    let model = endGameResultView.resultModel ?? viewModel.getEndGameResultModel()
    let betAmount = Constants.getFormattedText(from: model.betAmount)
    let hitCount = String(model.coef.hit)
    let win = Constants.getFormattedText(from: model.betAmount * model.coef.coefficient)
    let text = String(format: EngGameResultViewTitles.shareWinMsg.localized, betAmount, hitCount, win)
    
    let activityVC = UIActivityViewController(activityItems: [text], applicationActivities: nil)
    activityVC.popoverPresentationController?.sourceView = self.view // so that iPads won't crash
    
    self.present(activityVC, animated: true)
  }
}
//MARK: - UIViewControllerTransitioningDelegate
extension MainViewController: UIViewControllerTransitioningDelegate {
  func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
    if presented is TimingViewController {
      TimingPresentationController(presentedViewController: presented, presenting: presenting)
    } else {
      nil
    }
  }
}
//MARK: - Constants
fileprivate struct Constants: CommonSettings {
  static var amountMinusButtonFont: UIFont {
    let fontSize = sizeProportion(for: 18.0)
    return AppFont.font(type: .bold, size: fontSize)
  }
  static var amountPlusButtonFont: UIFont {
    let fontSize = sizeProportion(for: 18.0)
    return AppFont.font(type: .bold, size: fontSize)
  }
  static var betButtonFont: UIFont {
    let fontSize = sizeProportion(for: 16.0)
    return AppFont.font(type: .bold, size: fontSize)
  }
  
  static var setBetContainerRadius: CGFloat {
    sizeProportion(for: 30.0)
  }
  static var setBetOverlayBorderContainerRadius: CGFloat {
    setBetContainerRadius - 1.0
  }
  
  static var amountTitleFont: UIFont {
    let fontSize = sizeProportion(for: 12.0, minSize: 9.0)
    return AppFont.font(type: .regular, size: fontSize)
  }
  static var amountLabelFont: UIFont {
    let fontSize = sizeProportion(for: 16.0, minSize: 11.0)
    return AppFont.font(type: .bold, size: fontSize)
  }
  
  static let spacingBetweenBetAmountTypeCells: CGFloat = 4.0
  
  static var hCollectionHeight: CGFloat {
    sizeProportion(for: 48.0)
  }
  static var amountMinusButtonHeight: CGFloat {
    sizeProportion(for: 52.0)
  }
  static var amountMinusButtonWidth: CGFloat {
    sizeProportion(for: 44.0)
  }
}
