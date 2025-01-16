//
//  SpaceOrbitParametersModel.swift
//  Space Orbit
//
//  Created by Дмитрий Хероим on 13.12.2024.
//

import Foundation

struct SpaceOrbitParametersModel {
  let startAngle: CGFloat = .zero
  let endAngle: CGFloat = (CGFloat.pi * 2)
  
  let radius: CGFloat
  
  let orbit: SpaceOrbitType
  let indent: CGFloat
  
  init(according model: SpaceOrbitModel, containerRadius: CGFloat, outerOrbitSideIndent: CGFloat, spacingBetweenOrbits: CGFloat) {
    let indent = (CGFloat(model.orbitTag) * spacingBetweenOrbits) + outerOrbitSideIndent
    self.indent = indent
    radius = containerRadius - indent
    orbit = model.orbit
  }
}
