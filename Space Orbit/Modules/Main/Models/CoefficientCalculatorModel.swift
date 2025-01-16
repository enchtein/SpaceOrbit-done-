//
//  CoefficientCalculatorModel.swift
//  Space Orbit
//
//  Created by Дмитрий Хероим on 27.12.2024.
//

import Foundation

struct CoefficientCalculatorModel {
  let hit: Int
  var coefficient: Float { calculateCoefficient() }
  
  init(hit: Int) {
    self.hit = hit
  }
  
  private func calculateCoefficient() -> Float {
    let multiplier: Float
    let power: Float
    
    if hit <= 15 {
      multiplier = 0.08
      power = 1.2
    } else if hit <= 23 {
      multiplier = 0.1
      power = 1.3
    } else {
      multiplier = 0.1
      power = 1.25
    }
    
    let res = 1 + (multiplier * pow(Float(hit), power))
    
    return roundf(res * 100) / 100 // round for two digits
  }
}
