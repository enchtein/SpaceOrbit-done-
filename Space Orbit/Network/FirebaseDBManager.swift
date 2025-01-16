import Foundation
import FirebaseFirestore
import FirebaseStorage

final class FirebaseDBManager {
  static let shared = FirebaseDBManager()
  private let db = Firestore.firestore()
  private let imageStorage = Storage.storage().reference()
  
  private init() {}
  
  //for Profile API
  private var participantsCR: CollectionReference { db.collection(CollectionAction.participants.actionName) }
}
//MARK: - Profile API
extension FirebaseDBManager {
  func add(participant: Participant, oldProfile: Participant?) async throws -> Participant {
    let docRef = try await participantsCR.addDocument(data: participant.dictionary)
    try? await deleteParticipant(by: oldProfile)
    return Participant(id: docRef.documentID, basedOn: participant)
  }
  func updateParticipant(by model: Participant) async throws {
    let id = try getValidParticipantId(from: model.id)
    
    let docRef = participantsCR.document(id)
    try await docRef.updateData(model.dictionary)
  }
  func getParticipant(by id: String?) async throws -> Participant {
    let id = try getValidParticipantId(from: id)
    
    let docRef = participantsCR.document(id)
    let document = try await docRef.getDocument()
    return try document.data(as: Participant.self)
  }
  
  func getAllParticipants() async throws -> [Participant] {
    let document = try await participantsCR.getDocuments()
    let docArray = document.documents
    
    let res = docArray.compactMap { try? $0.data(as: Participant.self) }
    return res
  }
  
  func deleteParticipant(by model: Participant?) async throws {
    let model = try getValidParticipant(from: model)
    let id = try getValidParticipantId(from: model.id)
    
    let docRef = participantsCR.document(id)
    try await docRef.delete()
  }
}
//MARK: - CollectionAction
fileprivate enum CollectionAction {
  case participants
  
  var actionName: String {
    switch self {
    case .participants: "Participants"
    }
  }
}
//MARK: - ErrorHandling processing
extension FirebaseDBManager {
  private func getValidParticipant(from model: Participant?) throws -> Participant {
    guard let model else { throw ErrorHandling.participantIsNil }
    return model
  }
  private func getValidParticipantId(from id: String?) throws -> String {
    guard let id else { throw ErrorHandling.participantIdIsNil }
    return id
  }
}
////MARK: - enum ErrorHandling
enum ErrorHandling: Error {
  case participantIsNil
  case participantIdIsNil
}
