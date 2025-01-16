import Foundation

extension String {
  func localized(bundle:Bundle = .main , tableName: String = "Localization") -> String {
    return bundle.localizedString(forKey: self, value: "*\(self)*", table: tableName)
  }
}
