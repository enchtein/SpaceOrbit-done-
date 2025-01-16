//
//  SpaceOrbitType.swift
//  Space Orbit
//
//  Created by Дмитрий Хероим on 12.12.2024.
//

import Foundation

enum SpaceOrbitType: Int {
  case low = 0
  case medium
  case high
  
  var countOfStars: Int {
    switch self {
    case .low: 20
    case .medium: 12
    case .high: 6
    }
  }
  var countOfAsteroids: Int {
    switch self {
    case .low: 0
    case .medium: 4
    case .high: 2
    }
  }
  
  var orbitMovementDuration: TimeInterval {
    switch self {
    case .low: 5.0
    case .medium: 4.0
    case .high: 3.0
    }
  }
}
