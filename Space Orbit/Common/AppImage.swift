import UIKit

enum AppImage {
  enum GameLevelType {
    static let low = UIImage(resource: .lowGLTIm)
    static let medium = UIImage(resource: .mediumGLTIm)
    static let high = UIImage(resource: .highGLTIm)
  }
  
  enum Main {
    static let asteroid = UIImage(resource: .asteroidMIm)
    static let asteroidBullet = UIImage(resource: .asteroidBulletMIm)
    static let hitArrow = UIImage(resource: .hitArrowMIm)
  }
  enum Planets {
    static let auricas = UIImage(resource: .auricasMIm)
    static let ignisium = UIImage(resource: .ignisiumMIm)
    
    static let crystallinum = UIImage(resource: .crystallinumMIm)
    static let laxium = UIImage(resource: .laxiumMIm)

    static let jackpotia = UIImage(resource: .jackpotiaMIm)
    static let fortuna = UIImage(resource: .fortunaMIm)
  }
  enum Rockets {
    static let stellarAce = UIImage(resource: .stellarAceRTIm)
    static let cosmoRunner = UIImage(resource: .cosmoRunnerRTIm)
    static let fortuneFlyer = UIImage(resource: .fortuneFlyerRTIm)
    static let jackpotCruiser = UIImage(resource: .jackpotCruiserRTIm)
    static let orbiterX = UIImage(resource: .orbiterXRTIm)
    static let luckyComet = UIImage(resource: .luckyCometRTIm)
  }
  
  enum CommonNavPanel {
    static let menu = UIImage(resource: .menuNPIm)
    static let close = UIImage(resource: .closeNPIm)
    static let shop = UIImage(resource: .shopNPIm)
    static let leaderboard = UIImage(resource: .leaderboardNPIm)
    static let settings = UIImage(resource: .settingsNPIm)
    
    static let back = UIImage(resource: .backNPIm)
    static let pause = UIImage(resource: .pauseNPIm)
    static let coin = UIImage(resource: .coinNPIm)
  }
  
  enum EngGameResultView {
    static let home = UIImage(resource: .homeEGIm)
    static let replay = UIImage(resource: .replayEGIm)
    static let share = UIImage(resource: .shareEGIm)
  }
  
  enum Timing {
    static let home = UIImage(resource: .homeTIm)
    static let play = UIImage(resource: .playTIm)
    static let soundOn = UIImage(resource: .soundOnTIm)
    static let soundOff = UIImage(resource: .soundOffTIm)
  }
  
  enum Shop {
    static let arrow = UIImage(resource: .arrowSHIm)
  }
}
