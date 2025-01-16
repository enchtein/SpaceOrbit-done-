//
//  HitCoinModel.swift
//  Space Orbit
//
//  Created by Дмитрий Хероим on 30.12.2024.
//

struct HitCoinModel: Equatable {
  static func == (lhs: HitCoinModel, rhs: HitCoinModel) -> Bool {
    lhs.type == rhs.type && lhs.coefficient.hit == rhs.coefficient.hit
  }
  
  let type: HitProcessType
  let coefficient: CoefficientCalculatorModel
  
  init(hit: Int, currentHit: Int, hitsCount: Int) {
    self.coefficient = CoefficientCalculatorModel(hit: hit)
    
    let type: HitProcessType
    if currentHit >= hit {
      type = .hit
    } else {
      if hit == currentHit + 1 && hit < hitsCount {
        type = .available
      } else {
        type = .opaque
      }
    }
    self.type = type
  }
  
  enum HitProcessType {
    case available
    case hit
    case opaque
  }
}
