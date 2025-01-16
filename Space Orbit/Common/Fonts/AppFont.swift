import UIKit

enum FontType {
  case black
  case bold
  case medium
  case regular
  
  fileprivate var type: String {
    switch self {
    case .black: "BeVietnamPro-Black" //900
    case .bold: "BeVietnamPro-Bold" //700
    case .medium: "BeVietnamPro-Medium" //500
    case .regular: "BeVietnamPro-Regular" //400
    }
  }
}

struct AppFont {
  static func font(type: FontType, size: CGFloat) -> UIFont {
    UIFont(name: type.type, size: CGFloat(size)) ?? UIFont.systemFont(ofSize: CGFloat(size))
  }
  static func font(type: FontType, size: Int) -> UIFont {
    font(type: type, size: CGFloat(size))
  }
}
