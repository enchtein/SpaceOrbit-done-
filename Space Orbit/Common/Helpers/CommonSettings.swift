import Foundation

protocol CommonSettings {
  static var animationDuration: TimeInterval { get }
  static var minScaleFactor: CGFloat { get }
  
  static var baseSideIndent: CGFloat { get }
  
  static var targetOpacity: TargetActionsOpacity { get }
  
  static func sizeProportion(for maxSize: CGFloat, minSize: CGFloat) -> CGFloat
  
  static var getNumberFormatter: NumberFormatter { get }
  static func getFormattedText(from value: Float) -> String
}
extension CommonSettings {
  static var animationDuration: TimeInterval { 0.5 }
  static var minScaleFactor: CGFloat { 0.5 }
  
  static var baseSideIndent: CGFloat { 16.0 }
  
  static var targetOpacity: TargetActionsOpacity { TargetActionsOpacity() }
  
  static func sizeProportion(for maxSize: CGFloat, minSize: CGFloat = 0.0) -> CGFloat {
    let sizeProportion = maxSize.sizeProportion
    
    let res: CGFloat
    if minSize > .zero {
      let sizedValue = sizeProportion > maxSize ? maxSize : sizeProportion
      res = sizedValue < minSize ? minSize : sizedValue
    } else {
      res = sizeProportion > maxSize ? maxSize : sizeProportion
    }
    
    return res
  }
  
  static var getNumberFormatter: NumberFormatter {
    let currencyFormatter = NumberFormatter()
    currencyFormatter.numberStyle = .currency
    currencyFormatter.currencySymbol = ""
    currencyFormatter.currencyDecimalSeparator = "."
    currencyFormatter.minimumFractionDigits = 0
    currencyFormatter.maximumFractionDigits = 0
    
    return currencyFormatter
  }
  static func getFormattedText(from value: Float) -> String {
    let formatter = getNumberFormatter
    formatter.minimumFractionDigits = 2
    formatter.maximumFractionDigits = 2
    
    return formatter.string(from: NSNumber.init(value: value)) ?? String(value)
  }
}

//MARK: - TargetActionsOpacity
struct TargetActionsOpacity {
  let base: Float = 1.0
  let highlighted: Float = 0.7
  let disabled: Float = 0.3
}
