import Foundation
import FirebaseFirestore

struct Participant: Identifiable, Codable, Equatable {
  @DocumentID var id: String?
  
  let name: String
  let coinsScore: Float
  let rocketsPurchased: [RocketType]
  let selectedRocket: RocketType
  
  init(from decoder: any Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    
    self._id = try container.decode(DocumentID<String>.self, forKey: .id)
    
    name = try container.decode(String.self, forKey: .name)
    coinsScore = try container.decode(Float.self, forKey: .coinsScore)
    
    let purchasedRockets = try container.decode([Int].self, forKey: .rocketsPurchased).compactMap { RocketType.init(rawValue: $0) }
    rocketsPurchased = purchasedRockets.isEmpty ? [.stellarAce] : purchasedRockets
    
    let rocketSelected = try container.decode(Int.self, forKey: .selectedRocket)
    selectedRocket = RocketType.init(rawValue: rocketSelected) ?? .stellarAce
  }
  func encode(to encoder: any Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    
    if let id {
      try container.encode(id, forKey: .id)
    }
    
    try container.encode(name, forKey: .name)
    try container.encode(coinsScore, forKey: .coinsScore)
    
    try container.encode(rocketsPurchased.map{$0.rawValue}, forKey: .rocketsPurchased)
    try container.encode(selectedRocket.rawValue, forKey: .selectedRocket)
  }
  
  private init(id: String?, name: String, coinsScore: Float, rocketsPurchased: [RocketType], selectedRocket: RocketType) {
    self.id = id
    self.name = name
    self.coinsScore = coinsScore
    self.rocketsPurchased = rocketsPurchased
    self.selectedRocket = selectedRocket
  }
}

//MARK: - Additional init's
extension Participant {
  init(id: String, basedOn model: Self) {
    self.init(id: id,
              name: model.name,
              coinsScore: model.coinsScore,
              rocketsPurchased: model.rocketsPurchased,
              selectedRocket: model.selectedRocket)
  }
  init(coinsScore: Float, basedOn model: Self) {
    self.init(id: model.id,
              name: model.name,
              coinsScore: coinsScore,
              rocketsPurchased: model.rocketsPurchased,
              selectedRocket: model.selectedRocket)
  }
  init(rocketsPurchased: [RocketType], basedOn model: Self) {
    self.init(id: model.id,
              name: model.name,
              coinsScore: model.coinsScore,
              rocketsPurchased: rocketsPurchased,
              selectedRocket: model.selectedRocket)
  }
  init(selectedRocket: RocketType, baseOn model: Self) {
    self.init(id: model.id,
              name: model.name,
              coinsScore: model.coinsScore,
              rocketsPurchased: model.rocketsPurchased,
              selectedRocket: selectedRocket)
  }
  init(name: String, basedOn model: Self) {
    self.init(id: model.id,
              name: name,
              coinsScore: model.coinsScore,
              rocketsPurchased: model.rocketsPurchased,
              selectedRocket: model.selectedRocket)
  }
  
  fileprivate init(name: String) {
    self.init(id: nil, name: name, coinsScore: 1000, rocketsPurchased: [RocketType.defaultRocket], selectedRocket: RocketType.defaultRocket)
  }
  static let mock = Participant(name: "Mock")
}

//MARK: - new Participant creation
extension Participant {
  static func generateRandom(according existParticipants: [Self]) -> Self {
    let allParticipantNames = existParticipants.map { $0.name }
    
    let uniqNewUserName = generateUniqueUsername(according: allParticipantNames)
    return Participant.init(name: uniqNewUserName)
  }
  private static func generateUniqueUsername(according existingUsernames: [String]) -> String {
    let baseUsername = "Player" // Значение по умолчанию
    var uniqueUsername: String
    
    repeat {
      let randomNumber = generateRandomNumber()
      uniqueUsername = baseUsername + randomNumber
    } while existingUsernames.contains(uniqueUsername)
    
    return uniqueUsername
  }
  private static func generateRandomNumber() -> String {
    return String(format: "%05d", Int.random(in: 0...99999)) // Генерируем 5-значное число
  }
}

//MARK: - CodingKeys
fileprivate enum CodingKeys: CodingKey {
  case id
  
  case name
  case coinsScore
  case rocketsPurchased
  case selectedRocket
}
