import Foundation

protocol Localizable {
  var tableName: String { get }
  var localized: String { get }
}

extension Localizable where Self: RawRepresentable, Self.RawValue == String {
  var localized: String {
    return rawValue.localized(tableName: tableName)
  }
  
  private static var identifier: String { return String(describing: self) }
  var tableName: String { Self.identifier }
}
