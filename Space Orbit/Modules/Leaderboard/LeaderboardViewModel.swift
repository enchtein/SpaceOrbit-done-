//
//  LeaderboardViewModel.swift
//  Space Orbit
//
//  Created by Дмитрий Хероим on 13.01.2025.
//

import Foundation

protocol LeaderboardViewModelDelegate: AnyObject {
  func dataSourceDidChange()
  
  func participantBalanceDidChange(to value: Float)
}

@MainActor
final class LeaderboardViewModel {
  private weak var delegate: LeaderboardViewModelDelegate?
  
  private var participant: Participant = .mock
  var balance: Float { participant.coinsScore }
  private var dataSource = [LeaderboardModel]()
  
  private var allParticipants = [Participant]()
  
  init(participant: Participant, delegate: LeaderboardViewModelDelegate?) {
    self.participant = participant
    self.delegate = delegate
  }
  
  func viewDidLoad() {
    fetchAllUsers()
    
    delegate?.participantBalanceDidChange(to: participant.coinsScore)
  }
}
//MARK: - API
extension LeaderboardViewModel {
  func replaceParticipant(by newParticipant: Participant) {
    participant = newParticipant
    reCreateDataSourceAndReload()
  }
}
//MARK: - Network layer
private extension LeaderboardViewModel {
  func fetchAllUsers() {
    Task {
      do {
        let allParticipants = try await FirebaseDBManager.shared.getAllParticipants()
        self.allParticipants = allParticipants.sorted { $0.coinsScore > $1.coinsScore }
        reCreateDataSourceAndReload()
      } catch {
        debugPrint(error.localizedDescription)
      }
    }
  }
}
//MARK: - Helpers
private extension LeaderboardViewModel {
  func reCreateDataSourceAndReload() {
    dataSource.removeAll()
    
    var firstHunredUsers = Array(allParticipants.prefix(100))
    if !firstHunredUsers.contains(participant) {
      firstHunredUsers.append(participant)
    }
    firstHunredUsers.sort { $0.coinsScore > $1.coinsScore }
    
    var newDataSource = [LeaderboardModel]()
    for (index, user) in firstHunredUsers.enumerated() {
      let number = index + 1
      let rateNamber: String
      if number <= 100 {
        rateNamber = String(number)
      } else {
        rateNamber = String(number) + "+"
      }
      
      let isCurrent = user == participant
      let model = LeaderboardModel.init(name: user.name, balance: user.coinsScore, isCurrentUser: isCurrent, rateNumber: rateNamber)
      newDataSource.append(model)
    }
    
    dataSource = newDataSource
    delegate?.dataSourceDidChange()
  }
}
//MARK: - DataSource API
extension LeaderboardViewModel {
  func numberOfItemsInSection(_ section: Int) -> Int {
    dataSource.count
  }
  func itemForRow(at indexPath: IndexPath) -> LeaderboardModel {
    dataSource[indexPath.row]
  }
}

struct LeaderboardModel {
  let name: String
  let balance: Float
  let isCurrentUser: Bool
  let rateNumber: String
}
