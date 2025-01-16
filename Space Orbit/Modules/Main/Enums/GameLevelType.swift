import UIKit

enum GameLevelType {
  case low
  case medium
  case high
  
  var image: UIImage {
    switch self {
    case .low: AppImage.GameLevelType.low
    case .medium: AppImage.GameLevelType.medium
    case .high: AppImage.GameLevelType.high
    }
  }
  
  var orbits: [SpaceOrbitType] {
    switch self {
    case .low: [.low]
    case .medium: [.low, .medium]
    case .high: [.low, .medium, .high]
    }
  }
  
  var name: String {
    switch self {
    case .low: GameLevelTypeTitles.low.localized
    case .medium: GameLevelTypeTitles.medium.localized
    case .high: GameLevelTypeTitles.high.localized
    }
  }
  var color: UIColor {
    switch self {
    case .low: AppColor.accentTwo
    case .medium: AppColor.systemThree
    case .high: AppColor.accentOne
    }
  }
}
