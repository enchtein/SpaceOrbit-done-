//
//  OrbitObjectType.swift
//  Space Orbit
//
//  Created by Дмитрий Хероим on 13.12.2024.
//

import Foundation

enum OrbitObjectType {
  case star
  case asteroid
  
  var sideSize: CGFloat {
    switch self {
    case .star: 8.0
    case .asteroid: 27.0
    }
  }
}
