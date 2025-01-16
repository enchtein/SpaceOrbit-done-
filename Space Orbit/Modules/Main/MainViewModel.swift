//
//  MainViewModel.swift
//  Space Orbit
//
//  Created by Дмитрий Хероим on 28.12.2024.
//

import Foundation

protocol MainViewModelDelegate: AnyObject {
  func currentBetAmountDidChange(to value: Int)
  
  func navPanelTypeDidChange(to value: CommonNavPanel.NavPanelType)
  func gameStateDidChange(to value: GameState)
  
  func increaseBalanceButtonAvailabilityChange(to isAvailable: Bool)
  func decreaseBalanceButtonAvailabilityChange(to isAvailable: Bool)
  
  func hitCoinDataSourceDidChange()
  func hitCoinModelCellTypeDidChange(to model: HitCoinModel, at indexPath: IndexPath)
  func updateHitCoinsCollectionPositionVisability(to indexPath: IndexPath, animated: Bool)
  func hitCoinOutDidChange(to value: Float)
  
  func participantDidChange(to value: Participant)
  func participantBalanceDidChange(to value: Float)
}
final class MainViewModel {
  private var participant: Participant
  private var balance: Float { participant.coinsScore }
  
  private var selectedBetAmountStep: BetAmountType = .defaultTen
  private var currentBetAmount: Int = BetAmountType.defaultTen.rawValue
  
  private let betAmountDataSource = BetAmountType.editableTypes
  
  private var navPanelType: CommonNavPanel.NavPanelType = .gamePrepair
  private(set) var gameState: GameState = .pedding
  private var gamePlanet: PlanetType = .auricas
  private var currentHitCoins: Int = .zero
  private var hitCoinDataSource = [HitCoinModel]()
  
  private weak var delegate: MainViewModelDelegate?
  
  init(participant: Participant, delegate: MainViewModelDelegate?) {
    self.participant = participant
    self.delegate = delegate
  }
  
  func viewDidLoad() {
    delegate?.currentBetAmountDidChange(to: currentBetAmount)
    
    delegate?.navPanelTypeDidChange(to: navPanelType)
    delegate?.gameStateDidChange(to: gameState)
    delegate?.participantBalanceDidChange(to: participant.coinsScore)
    
    updateStepBalanceButtonsAvailability()
    
    let coef = CoefficientCalculatorModel(hit: currentHitCoins)
    updateHitCoinsCount(with: coef)
    reCreateHitCoinsDataSource()
  }
}
//MARK: - Network Layer
private extension MainViewModel {
  func updateParticipantInFirebase() {
    Task {
      try? await FirebaseDBManager.shared.updateParticipant(by: participant)
    }
  }
}
//MARK: - API
extension MainViewModel {
  func increaseBalance() {
    let expectedValue = currentBetAmount + currentStepValue(isIncrease: true)
    guard expectedValue <= BetAmountType.max.rawValue else { return }
    currentBetAmount = expectedValue
    delegate?.currentBetAmountDidChange(to: currentBetAmount)
    updateStepBalanceButtonsAvailability()
  }
  func decreaseBalance() {
    let expectedValue = currentBetAmount - currentStepValue(isIncrease: false)
    guard expectedValue >= BetAmountType.min.rawValue else { return }
    currentBetAmount = expectedValue
    delegate?.currentBetAmountDidChange(to: currentBetAmount)
    updateStepBalanceButtonsAvailability()
  }
  
  func updateGameState(to value: GameState) {
    guard gameState != value else { return }
    gameState = value
    delegate?.gameStateDidChange(to: value)
    
    updateParticipantAccordingGameStateIfNeeded()
    
    switch value {
    case .pedding:
      navPanelType = .gamePrepair
      reCreateHitCoinsDataSource()
    case .playing:
      navPanelType = .game(betAmount: currentBetAmount)
    case .paused:
      return
    case .win:
      currentHitCoins = .zero
      navPanelType = .gameEnd
    case .crashed:
      currentHitCoins = .zero
      navPanelType = .gameEnd
    }
    
    delegate?.navPanelTypeDidChange(to: navPanelType)
  }
  func updateGamePlanet(to type: PlanetType) {
    guard gamePlanet != type else { return }
    gamePlanet = type
    
    reCreateHitCoinsDataSource()
    guard let startIndexPath = indexPath(for: .hit, with: 0) else { return }
    delegate?.updateHitCoinsCollectionPositionVisability(to: startIndexPath, animated: false)
  }
  
  func updateHitCoinsCount(to value: Int) {
    guard currentHitCoins != value && gameState.isOrbitVisible else { return }
    currentHitCoins = value
    updateHitCoinsCollectionPositionVisabilityIfNeeded()
    
    let coef = CoefficientCalculatorModel(hit: value)
    updateHitCoinsCount(with: coef)
  }
  
  func resetBetAmount() {
    currentBetAmount = BetAmountType.defaultTen.rawValue
    delegate?.currentBetAmountDidChange(to: currentBetAmount)
  }
}
//MARK: - API
extension MainViewModel {
  func numberOfItemsInSection(_ section: Int, for type: CollectionType) -> Int {
    switch type {
    case .betAmount: betAmountDataSource.count
    case .hit: hitCoinDataSource.count
    }
  }
  func getEndGameResultModel() -> EndGameResultModel {
    EndGameResultModel(gameState: gameState, betAmount: Float(currentBetAmount), coef: CoefficientCalculatorModel(hit: currentHitCoins))
  }
  
  func replaceParticipant(by newParticipant: Participant) {
    participant = newParticipant
  }
}
//MARK: - API (BetAmountType)
extension MainViewModel {
  func betAmountType(at indexPath: IndexPath) -> BetAmountType {
    betAmountDataSource[indexPath.item]
  }
  func isAvailableBetAmountType(at indexPath: IndexPath) -> Bool {
    let type = betAmountType(at: indexPath)
    return Float(type.rawValue) <= balance
  }
  
  func didSelectBetAmountType(at indexPath: IndexPath) {
    let newType = betAmountType(at: indexPath)
    guard selectedBetAmountStep != newType else { return }
    selectedBetAmountStep = newType
    
    currentBetAmount = newType.rawValue
    delegate?.currentBetAmountDidChange(to: currentBetAmount)
    updateStepBalanceButtonsAvailability()
  }
}
//MARK: - API (HitCoins)
extension MainViewModel {
  func hitCoinModel(at indexPath: IndexPath) -> HitCoinModel {
    hitCoinDataSource[indexPath.item]
  }
}
//MARK: - Helpers
private extension MainViewModel {
  func indexPath(for type: CollectionType, with index: Int) -> IndexPath? {
    let isIndexExist: Bool
    switch type {
    case .betAmount:
      isIndexExist = betAmountDataSource.indices.contains(index)
    case .hit:
      isIndexExist = hitCoinDataSource.indices.contains(index)
    }
    
    guard isIndexExist else { return nil }
    return IndexPath(item: index, section: 0)
  }
  func currentStepValue(isIncrease: Bool) -> Int {
    let stepType: BetAmountType
    if isIncrease {
      stepType = Int(currentBetAmount) < BetAmountType.first.rawValue ? .min : .defaultTen
    } else {
      stepType = Int(currentBetAmount) > BetAmountType.first.rawValue ? .defaultTen : .min
    }
    
    return stepType.rawValue
  }
  
  func updateStepBalanceButtonsAvailability() {
    delegate?.increaseBalanceButtonAvailabilityChange(to: currentBetAmount < BetAmountType.max.rawValue)
    delegate?.decreaseBalanceButtonAvailabilityChange(to: currentBetAmount > BetAmountType.min.rawValue)
  }
  
  func updateHitCoinsCount(with model: CoefficientCalculatorModel) {
    let value = model.coefficient * Float(currentBetAmount)
    delegate?.hitCoinOutDidChange(to: value)
  }
  
  func createHitCoinsDataSource() -> [HitCoinModel] {
    let countOfStars = gamePlanet.gameLvl.orbits.map {$0.countOfStars}.reduce(0, +)
    
    var result: [HitCoinModel] = []
    for index in 0..<countOfStars {
      let starNumber = index + 1
      
      let model = HitCoinModel.init(hit: starNumber, currentHit: currentHitCoins, hitsCount: countOfStars)
      result.append(model)
    }
    
    return result
  }
  func reCreateHitCoinsDataSource() {
    hitCoinDataSource = createHitCoinsDataSource()
    delegate?.hitCoinDataSourceDidChange()
    
    guard let firstIndex = hitCoinDataSource.indices.first else { return }
    guard let firstIndexPath = indexPath(for: .hit, with: firstIndex) else { return }
    delegate?.updateHitCoinsCollectionPositionVisability(to: firstIndexPath, animated: false)
  }
  func updateHitCoinsCollectionPositionVisabilityIfNeeded() {
    let newDataSource = createHitCoinsDataSource()
    let changedModels = hitCoinDataSource.filter { !newDataSource.contains($0) }
    
    for changedModel in changedModels {
      guard let index = hitCoinDataSource.firstIndex(of: changedModel) else { continue }
      guard let changedModelIndexPath = indexPath(for: .hit, with: index) else { continue }
      delegate?.hitCoinModelCellTypeDidChange(to: newDataSource[index], at: changedModelIndexPath)
    }
    
    hitCoinDataSource = newDataSource
    
    let nextIndex = currentHitCoins
    guard let nextIndexPath = indexPath(for: .hit, with: nextIndex) else { return }
    delegate?.updateHitCoinsCollectionPositionVisability(to: nextIndexPath, animated: true)
  }
  
  func updateParticipantAccordingGameStateIfNeeded() {
    let newParticipant: Participant?
    switch gameState {
    case .win:
      let model = getEndGameResultModel()
      let winBalance = model.betAmount * model.coef.coefficient
      newParticipant = Participant.init(coinsScore: balance + winBalance, basedOn: participant)
    case .crashed:
      newParticipant = Participant.init(coinsScore: balance - Float(currentBetAmount), basedOn: participant)
    default: return
    }
    
    guard let newParticipant else { return }
    participant = newParticipant
    
    delegate?.participantDidChange(to: newParticipant)
    delegate?.participantBalanceDidChange(to: newParticipant.coinsScore)
    
    updateParticipantInFirebase()
  }
}
//MARK: - enum CollectionType
extension MainViewModel {
  enum CollectionType {
    case betAmount
    case hit
  }
}
