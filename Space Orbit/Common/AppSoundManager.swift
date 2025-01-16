import AVFoundation

fileprivate var player: AVAudioPlayer?

final class AppSoundManager {
  static let shared = AppSoundManager()
  private init() { }
  
  private func playSound(for type: SoundType) {
    guard !UserDefaults.standard.isGameSoundOff else { return }
    
    let fileName = type.fileName
    let fileExtension = type.fileExtension
    
    guard let url = Bundle.main.url(forResource: fileName, withExtension: fileExtension) else { return }
    
    do {
      player = try AVAudioPlayer(contentsOf: url)
      player?.play()
    } catch {
#if DEBUG
      print(error.localizedDescription)
#endif
    }
  }
  
  private func stopPlaying() {
    player?.stop()
  }
}
//MARK: - API
extension AppSoundManager {
  func lose() {
    stopPlaying()
    playSound(for: .gameOver)
  }
  func missleTurn() {
    playSound(for: .missleTurn)
  }
  func orbitalTransition() {
    playSound(for: .orbitalTransition)
  }
  func win() {
    playSound(for: .outBet)
  }
  func point() {
    playSound(for: .point)
  }
  func startGame() {
    playSound(for: .startGame)
  }
  func tapButton() {
    playSound(for: .tapButton)
  }
}

//MARK: - SoundType
fileprivate enum SoundType {
  case gameOver
  case missleTurn
  case orbitalTransition
  case outBet
  case point
  case startGame
  case tapButton
  
  var fileName: String {
    switch self {
    case .gameOver: "Game Over"
    case .missleTurn: "missile turn"
    case .orbitalTransition: "Orbital transition"
    case .outBet: "Out Bet"
    case .point: "point"
    case .startGame: "Start Game"
    case .tapButton: "Tap Button"
    }
  }
  var fileExtension: String { "mp3" }
}
