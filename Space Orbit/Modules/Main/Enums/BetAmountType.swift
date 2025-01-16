//
//  BetAmountType.swift
//  Space Orbit
//
//  Created by Дмитрий Хероим on 28.12.2024.
//

enum BetAmountType: Int, CaseIterable {
  case min = 1
  case first = 50
  case second = 100
  case third = 200
  case fourght = 500
  case max = 1000
  
  case defaultTen = 10
  
  static var editableTypes: [BetAmountType] {
    [.min, .first, .second, .third, .fourght, .max]
  }
  
  var title: String {
    switch self {
    case .min: BetAmountTypeTitles.min.localized
    case .first: String(self.rawValue)
    case .second: String(self.rawValue)
    case .third: String(self.rawValue)
    case .fourght: String(self.rawValue)
    case .max: BetAmountTypeTitles.max.localized
      
    case .defaultTen: "Default ten"
    }
  }
}
