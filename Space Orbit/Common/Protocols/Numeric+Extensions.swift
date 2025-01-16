import UIKit

protocol Numeric : Comparable, Equatable {
  init(_ v:Float)
  init(_ v:Double)
  init(_ v:Int)
  init(_ v:UInt)
  init(_ v:Int8)
  init(_ v:UInt8)
  init(_ v:Int16)
  init(_ v:UInt16)
  init(_ v:Int32)
  init(_ v:UInt32)
  init(_ v:Int64)
  init(_ v:UInt64)
  init(_ v:CGFloat)
  
  func _asOther<T:Numeric>() -> T
  
  var sizeProportion: CGFloat {get}
}

extension Numeric {
  init<T:Numeric>(fromNumeric numeric: T) { self = numeric._asOther() }
  
  var sizeProportion: CGFloat {
    calculateSize(with: UIDevice.current.sizeProportion)
  }
  var additionalSizeProportion: CGFloat {
    calculateSize(with: UIDevice.current.additionalSizeProportion)
  }
  var invertedSizeProportion: CGFloat {
    let deviceSizeProportion: CGFloat
    if UIDevice.current.sizeProportion >= 1.0 {
      deviceSizeProportion = UIDevice.current.sizeProportion
    } else {
      deviceSizeProportion = 1.0 + (1.0 - UIDevice.current.sizeProportion)
    }
    return CGFloat(fromNumeric: self) * deviceSizeProportion
  }
  
  private func calculateSize(with proportion: CGFloat) -> CGFloat {
    let cgMaxValue = CGFloat(fromNumeric: self)
    let expectedValue = cgMaxValue * proportion
    
    return expectedValue > cgMaxValue ? cgMaxValue : expectedValue
  }
}

extension Float   : Numeric {func _asOther<T:Numeric>() -> T { return T(self) }}
extension Double  : Numeric {func _asOther<T:Numeric>() -> T { return T(self) }}
extension CGFloat : Numeric {func _asOther<T:Numeric>() -> T { return T(self) }}
extension Int     : Numeric {func _asOther<T:Numeric>() -> T { return T(self) }}
extension Int8    : Numeric {func _asOther<T:Numeric>() -> T { return T(self) }}
extension Int16   : Numeric {func _asOther<T:Numeric>() -> T { return T(self) }}
extension Int32   : Numeric {func _asOther<T:Numeric>() -> T { return T(self) }}
extension Int64   : Numeric {func _asOther<T:Numeric>() -> T { return T(self) }}
extension UInt    : Numeric {func _asOther<T:Numeric>() -> T { return T(self) }}
extension UInt8   : Numeric {func _asOther<T:Numeric>() -> T { return T(self) }}
extension UInt16  : Numeric {func _asOther<T:Numeric>() -> T { return T(self) }}
extension UInt32  : Numeric {func _asOther<T:Numeric>() -> T { return T(self) }}
extension UInt64  : Numeric {func _asOther<T:Numeric>() -> T { return T(self) }}
