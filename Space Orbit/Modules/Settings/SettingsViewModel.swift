//
//  SettingsViewModel.swift
//  Space Orbit
//
//  Created by Дмитрий Хероим on 12.01.2025.
//

import Foundation

protocol SettingsViewModelDelegate: AnyObject {
  func dataSourceDidChange()
  func reloadCell(at indexPath: IndexPath, with model: SettingsModel)
  
  func participantDidChange(to value: Participant)
  func participantBalanceDidChange(to value: Float)
}
final class SettingsViewModel {
  private weak var delegate: SettingsViewModelDelegate?
  
  private var participant: Participant = .mock
  var balance: Float { participant.coinsScore }
  
  private var dataSource = [SettingsModel]()
  
  init(participant: Participant, delegate: SettingsViewModelDelegate?) {
    self.participant = participant
    self.delegate = delegate
  }
  
  func viewDidLoad() {
    delegate?.participantBalanceDidChange(to: participant.coinsScore)
    createDataSource()
  }
}
//MARK: - DataSource Helpers
private extension SettingsViewModel {
  func createDataSource() {
    let allSettingTypes = SettingType.allCases
    
    dataSource = allSettingTypes.map { SettingsModel.init(type: $0, participantName: participant.name) }
    delegate?.dataSourceDidChange()
  }
  
  func index(for model: SettingsModel?) -> Int? {
    guard let model else { return nil }
    return dataSource.firstIndex { $0.type == model.type }
  }
  func indexPath(for model: SettingsModel) -> IndexPath? {
    let index = dataSource.firstIndex { $0.type == model.type }
    guard let index else { return nil }
    
    return IndexPath(row: index, section: 0)
  }
  
  func reloadCell(for model: SettingsModel) {
    guard let indexPath = indexPath(for: model) else { return }
    delegate?.reloadCell(at: indexPath, with: model)
  }
  
  func replaceModelAndReloadCell(with model: SettingsModel) {
    guard let modelIndex = index(for: model) else { return }
    dataSource[modelIndex] = model
    
    reloadCell(for: dataSource[modelIndex])
  }
}
//MARK: - API
extension SettingsViewModel {
  func replaceParticipant(by newParticipant: Participant) {
    guard participant != newParticipant else { return }
    
    participant = newParticipant
    createDataSource()
  }
  func updateParticipantName(to value: String) {
    guard !participant.name.elementsEqual(value) else { return }
    let newParticipant = Participant.init(name: value, basedOn: participant)
    let newModel = SettingsModel.init(type: .changeParticipantName, participantName: value)
    
    participant = newParticipant
    
    reloadCell(for: newModel)
    delegate?.participantDidChange(to: newParticipant)
    
    Task {
      try? await FirebaseDBManager.shared.updateParticipant(by: participant)
    }
  }
  
  func deleteParticipant() {
    Task {
      try? await FirebaseDBManager.shared.deleteParticipant(by: participant)
    }
  }
}
//MARK: - DataSource API
extension SettingsViewModel {
  func numberOfItemsInSection(_ section: Int) -> Int {
    dataSource.count
  }
  func itemForRow(at indexPath: IndexPath) -> SettingsModel {
    dataSource[indexPath.row]
  }
}
