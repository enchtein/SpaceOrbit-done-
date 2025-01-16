import Foundation
import UIKit

enum SettingType: Int, CaseIterable {
  case changeParticipantName = 0
  case notifications
  case shareApp
  case privacyPolicy
  case termsOfUse
  case deleteProfile
  
  var name: String {
    switch self {
    case .changeParticipantName: SettingsTitles.changeParticipantName.localized
    case .notifications: SettingsTitles.notifications.localized
    case .shareApp: SettingsTitles.shareApp.localized
    case .privacyPolicy: SettingsTitles.privacyPolicy.localized
    case .termsOfUse: SettingsTitles.termsOfUse.localized
    case .deleteProfile: SettingsTitles.deleteProfile.localized
    }
  }
  
  var link: URL? {
    switch self {
    case .changeParticipantName: nil
    case .notifications: URL(string: UIApplication.openSettingsURLString)
    case .shareApp: URL(string: "https://www.google.com/")
    case .privacyPolicy: URL(string: "https://www.google.com/")
    case .termsOfUse: URL(string: "https://www.google.com/")
    case .deleteProfile: nil
    }
  }
}
