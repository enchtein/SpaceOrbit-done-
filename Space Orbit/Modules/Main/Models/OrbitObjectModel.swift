//
//  OrbitObjectModel.swift
//  Space Orbit
//
//  Created by Дмитрий Хероим on 13.12.2024.
//

import Foundation

struct OrbitObjectModel {
  private let angle: CGFloat
  private let orbitRadius: CGFloat
  private let additionalIndent: CGFloat
  
  private var sideSize: CGFloat { type.sideSize }
  var size: CGSize { .init(width: sideSize, height: sideSize) }
  var center: CGPoint {
    let xPosition = (orbitRadius + (cos(angle) * orbitRadius)) + additionalIndent
    let yPosition = (orbitRadius + (sin(angle) * orbitRadius)) + additionalIndent
    return .init(x: xPosition, y: yPosition)
  }
  var cornerRadius: CGFloat { sideSize / 4 }
  
  let type: OrbitObjectType
  
  init(angle: CGFloat, outerOrbitSideIndent: CGFloat, orbitRadius: CGFloat, type: OrbitObjectType) {
    self.angle = angle
    self.additionalIndent = outerOrbitSideIndent
    self.orbitRadius = orbitRadius
    
    self.type = type
  }
  init(angle: CGFloat, basedOn model: Self) {
    self.init(angle: angle, outerOrbitSideIndent: model.additionalIndent, orbitRadius: model.orbitRadius, type: model.type)
  }
}
