//
//  TimingSpaceOrbit.swift
//  Space Orbit
//
//  Created by Дмитрий Хероим on 05.01.2025.
//

import UIKit

final class TimingSpaceOrbit: UIView {
  private let baseRotationIndent: CGFloat = -(.pi / 2) //non changable constants
  private let fullCircleRadians: CGFloat = .pi * 2 //non changable constants
  private let outerOrbitSideIndent: CGFloat = .zero
  private var containerRadius: CGFloat { min(self.bounds.width, self.bounds.height) / 2 }
  private var orbitCenter: CGPoint { CGPoint(x: containerRadius, y: containerRadius) }
  
  private var orbitLayer: CAShapeLayer?
  private var orbitObjs: [UIView] = []
  
  private let orbitModel = SpaceOrbitModel.init(countOfStars: SpaceOrbitType.low.countOfStars, countOfAsteroids: SpaceOrbitType.low.countOfAsteroids, orbit: SpaceOrbitType.low)
  private var orbitParametersModel: SpaceOrbitParametersModel {
    SpaceOrbitParametersModel(according: orbitModel,
                              containerRadius: containerRadius,
                              outerOrbitSideIndent: outerOrbitSideIndent,
                              spacingBetweenOrbits: .zero)
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    
    if !isBaseVCAppeared {
      drawOrbitLayer()
    }
  }
  
  private func drawOrbitLayer() {
    orbitLayer?.removeFromSuperlayer()
    orbitObjs.forEach { $0.removeFromSuperview() }
    orbitObjs.removeAll()
    
    let orbitLayer = createOrbitLayer(according: orbitParametersModel)
    
    //1) add layer to view
    layer.addSublayer(orbitLayer)
    self.orbitLayer = orbitLayer
    
    //2) add objects
    drawOrbitObjects(according: orbitParametersModel, and: orbitModel)
  }
  
  private func createOrbitLayer(according params: SpaceOrbitParametersModel) -> CAShapeLayer {
    let layer = CAShapeLayer()
    layer.fillColor = UIColor.clear.cgColor
    layer.strokeColor = AppColor.layerTwo.cgColor
    layer.lineWidth = 1.0
    
    //create path for section
    let path = UIBezierPath()
    path.addArc(withCenter: orbitCenter, radius: params.radius, startAngle: params.startAngle, endAngle: params.endAngle, clockwise: true)
    
    //closing path
    path.close()
    
    layer.path = path.cgPath
    layer.name = String(params.orbit.rawValue)
    
    return layer
  }
  private func drawOrbitObjects(according paramsModel: SpaceOrbitParametersModel, and model: SpaceOrbitModel) {
    let asteroidObjs = Array(repeating: OrbitObjectModel.init(angle: .zero, outerOrbitSideIndent: paramsModel.indent, orbitRadius: paramsModel.radius, type: .asteroid), count: model.countOfAsteroids)
    let starObjs = Array(repeating: OrbitObjectModel.init(angle: .zero, outerOrbitSideIndent: paramsModel.indent, orbitRadius: paramsModel.radius, type: .star), count: model.countOfStars)
    var orbitObjects = asteroidObjs + starObjs
    orbitObjects.shuffle()
    
    let countOfObjects = orbitObjects.count
    let angleStep = fullCircleRadians / CGFloat(countOfObjects)
    
    for index in 0..<countOfObjects {
      let object = orbitObjects[index]
      
      let additionalAngle = angleStep * CGFloat(index)
      let objAngle = paramsModel.startAngle + additionalAngle
      
      let reCreatedObj = OrbitObjectModel.init(angle: objAngle, basedOn: object)
      
      let view: UIView = UIView(frame: .init(origin: .zero, size: reCreatedObj.size))
      view.backgroundColor = AppColor.systemThree
      
      view.center = reCreatedObj.center
      view.cornerRadius = reCreatedObj.cornerRadius
      
      //add rotation
      let startTransformAngle = objAngle - (baseRotationIndent / 2)
      view.transform = CGAffineTransform(rotationAngle: startTransformAngle)
      
      addSubview(view)
      orbitObjs.append(view)
    }
  }
}
