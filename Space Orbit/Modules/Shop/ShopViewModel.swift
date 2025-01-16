//
//  ShopViewModel.swift
//  Space Orbit
//
//  Created by Дмитрий Хероим on 07.01.2025.
//

import Foundation

protocol ShopViewModelDelegate: AnyObject {
  func dataSourceDidChange()
  func reloadCell(at indexPath: IndexPath, with model: ShopModel)
  
  func participantDidChange(to value: Participant)
  func participantBalanceDidChange(to value: Float)
  
  func showWatchAddsAlert(according model: ShopModel)
}
final class ShopViewModel {
  private weak var delegate: ShopViewModelDelegate?
  
  private var participant: Participant = .mock
  var balance: Float { participant.coinsScore }
  private var dataSource = [ShopModel]()
  
  init(participant: Participant, delegate: ShopViewModelDelegate?) {
    self.participant = participant
    self.delegate = delegate
  }
  
  func viewDidLoad() {
    reCreateDataSourceAndReload()
    
    delegate?.participantBalanceDidChange(to: participant.coinsScore)
  }
}
//MARK: - Helpers
private extension ShopViewModel {
  func updateParticipant(to newParticipant: Participant) {
    participant = newParticipant
    delegate?.participantDidChange(to: newParticipant)
    delegate?.participantBalanceDidChange(to: newParticipant.coinsScore)
    
    Task {
      try? await FirebaseDBManager.shared.updateParticipant(by: participant)
    }
  }
}
//MARK: - Helpers
private extension ShopViewModel {
  func reCreateDataSource() {
    dataSource.removeAll()
    
    let watchAddModel = ShopModel(watchAddsPrice: 200)
    dataSource.append(watchAddModel)
    
    let shopModels = RocketType.allCases.map { type in
      let isSelected = participant.selectedRocket == type
      let isPurchased = participant.rocketsPurchased.contains(type)
      
      return ShopModel.init(rocketType: type, isSelected: isSelected, isPurchased: isPurchased)
    }
    
    dataSource.append(contentsOf: shopModels)
  }
  func reCreateDataSourceAndReload() {
    reCreateDataSource()
    
    delegate?.dataSourceDidChange()
  }
  
  func index(for model: ShopModel?) -> Int? {
    guard let model else { return nil }
    return dataSource.firstIndex { $0.rocketType == model.rocketType }
  }
  func indexPath(for model: ShopModel) -> IndexPath? {
    let index = index(for: model)
    guard let index else { return nil }
    
    return IndexPath(row: index, section: 0)
  }
  func reloadCell(for model: ShopModel) {
    guard let indexPath = indexPath(for: model) else { return }
    delegate?.reloadCell(at: indexPath, with: model)
  }
}
//MARK: - API
extension ShopViewModel {
  func replaceParticipant(by newParticipant: Participant) {
    participant = newParticipant
  }
  
  func addWatchAddCoinsToParticipant(from model: ShopModel?) {
    guard let model, model.isWatchAdds else { return }
    
    let newParticipant = Participant.init(coinsScore: participant.coinsScore + model.watchAddsPrice, basedOn: participant)
    updateParticipant(to: newParticipant)
  }
}
//MARK: - DataSource API
extension ShopViewModel {
  func numberOfItemsInSection(_ section: Int) -> Int {
    dataSource.count
  }
  func itemForRow(at indexPath: IndexPath) -> ShopModel {
    dataSource[indexPath.row]
  }
  
  func buyRocket(at model: ShopModel) {
    guard let rocketType = model.rocketType else { return }
    guard !participant.rocketsPurchased.contains(rocketType) else { return }
    
    if participant.coinsScore >= rocketType.price {
      let ost = participant.coinsScore - rocketType.price
      let newParticipantScore = Participant.init(coinsScore: ost, basedOn: participant)
      
      var newRocketsPurchsed = newParticipantScore.rocketsPurchased
      newRocketsPurchsed.append(rocketType)
      
      let newParticipant = Participant.init(rocketsPurchased: newRocketsPurchsed, basedOn: newParticipantScore)
      updateParticipant(to: newParticipant)
      
      //set rocket as purchased
      let purchasedModel = ShopModel.init(isPurchased: !model.isPurchased, basedOn: model)
      replaceModelAndReloadCell(with: purchasedModel)
    } else {
      delegate?.showWatchAddsAlert(according: model)
    }
  }
  func selectRocket(at model: ShopModel) {
    guard let rocketType = model.rocketType else { return }
    guard participant.selectedRocket != rocketType else { return }
    
    let newParticipant = Participant.init(selectedRocket: rocketType, baseOn: participant)
    updateParticipant(to: newParticipant)
    
    //deselect old rocket
    let oldSelectedModels = dataSource.filter { $0.isSelected }
    let updatedUnSelectedModels = oldSelectedModels.map { ShopModel.init(isSelected: !$0.isSelected, basedOn: $0) }
    replaceModelsAndReloadCells(with: updatedUnSelectedModels)
    //select new rocket
    let newSelectedModel = ShopModel.init(isSelected: !model.isSelected, basedOn: model)
    replaceModelAndReloadCell(with: newSelectedModel)
  }
  func replaceModelsAndReloadCells(with models: [ShopModel]) {
    for model in models {
      replaceModelAndReloadCell(with: model)
    }
  }
  func replaceModelAndReloadCell(with model: ShopModel) {
    guard let modelIndex = index(for: model) else { return }
    dataSource[modelIndex] = model
    
    reloadCell(for: dataSource[modelIndex])
  }
  
  func findWatchAddShopModel() -> ShopModel? {
    dataSource.first { $0.isWatchAdds }
  }
}
