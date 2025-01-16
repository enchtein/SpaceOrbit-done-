//
//  SpaceOrbitBulletsManager.swift
//  Space Orbit
//
//  Created by Дмитрий Хероим on 16.12.2024.
//

import UIKit

protocol SpaceOrbitBulletsManagerDelegate: AnyObject {
  func bulletPositionDidChange(bullet: AsteroidBulletView, to value: CGPoint)
}
class SpaceOrbitBulletsManager {
  private var bulletLinks: [CADisplayLink] = []
  private var bullets: [AsteroidBulletView] = []
  
  weak var delegate: SpaceOrbitBulletsManagerDelegate?
  
  private func addBullet(_ bullet: AsteroidBulletView) {
    // Start display link to observe changes
    let bulletLink = CADisplayLink(target: self, selector: #selector(bulletPositionDidChange))
    bulletLink.add(to: .main, forMode: .default)
    
    //Set storring parameters
    bulletLinks.append(bulletLink)
    bullets.append(bullet)
    bullet.displayLink = bulletLink
  }
  
  @objc private func bulletPositionDidChange(sender: CADisplayLink) {
    let bullet = bullets.first { $0.displayLink === sender }
    guard let bullet else { return }
    guard let presentationLayer = bullet.layer.presentation() else { return }
    let bulletPosition = presentationLayer.position
    
    delegate?.bulletPositionDidChange(bullet: bullet, to: bulletPosition)
  }
  
  private func removeBullet(with bulletUUIDString: String) {
    let bulletsToRemove = bullets.filter { $0.uuidString.elementsEqual(bulletUUIDString) }
    bulletsToRemove.forEach { $0.alpha = .zero } // set non visible
    
    let displayLinksToRemove = bulletsToRemove.compactMap { $0.displayLink }
    
    //remove all animations
    bulletsToRemove.forEach {
      $0.layer.removeAllAnimations()
    }
    
    //invalidate DisplayLink
    displayLinksToRemove.forEach {
      $0.invalidate()
    }
    //remove DisplayLink
    displayLinksToRemove.forEach { linkToRemove in
      bulletLinks.removeAll { $0 === linkToRemove }
    }
    
    //remove from superview
    bulletsToRemove.forEach {
      $0.removeFromSuperview()
    }
    //remove from array
    bulletsToRemove.forEach { viewToRemove in
      bullets.removeAll { $0 === viewToRemove }
    }
  }
  
}
//MARK: - API
extension SpaceOrbitBulletsManager {
  func getShot(animationDelegate: SpaceOrbit, bullet: AsteroidBulletView, to position: CGPoint, with animationDuration: TimeInterval, cfTimeInterval: CFTimeInterval) {
    let halfAnimationDuration = animationDuration / 2
    
    //bullet position
    let positionKeyType = AnimationKeys.bulletPosition
    let animation = CABasicAnimation(keyPath: positionKeyType.caBasicAnimationKey)
    animation.toValue = position
    animation.duration = animationDuration
    
    animation.delegate = animationDelegate
    animation.setValue(bullet.uuidString, forKey: positionKeyType.rawValue)
    bullet.layer.add(animation, forKey: positionKeyType.rawValue)
    
    //bullet opacity
    let opacityKeyType = AnimationKeys.bulletOpacity
    let opacityAnimation = CABasicAnimation(keyPath: opacityKeyType.caBasicAnimationKey)
    opacityAnimation.fromValue = 1
    opacityAnimation.toValue = 0
    opacityAnimation.beginTime = cfTimeInterval + halfAnimationDuration
    opacityAnimation.duration = halfAnimationDuration
    opacityAnimation.fillMode = .forwards //save .zero opaciy at end of animation
    opacityAnimation.isRemovedOnCompletion = false //save .zero opaciy at end of animation
    
    opacityAnimation.delegate = animationDelegate
    opacityAnimation.setValue(bullet.uuidString, forKey: opacityKeyType.rawValue)
    bullet.layer.add(opacityAnimation, forKey: opacityKeyType.rawValue)
    
    //append bullet and create DisplayLink
    addBullet(bullet)
    bullet.setupVisibleTrack(with: animationDuration / 4)
  }
  
  func animationDidStop(_ animation: CAAnimation) {
    AnimationKeys.allCases.forEach {
      if let bulletUUIDString = animation.value(forKey: $0.rawValue) as? String {
        removeBullet(with: bulletUUIDString)
      }
    }
  }
  
  func remove(_ bullet: AsteroidBulletView) {
    removeBullet(with: bullet.uuidString)
  }
  func removeAll() {
    bullets.forEach { removeBullet(with: $0.uuidString) }
  }
}
//MARK: - AnimationKeys
private extension SpaceOrbitBulletsManager {
  enum AnimationKeys: String, CaseIterable {
    case bulletPosition = "bullet_position"
    case bulletOpacity = "bullet_opacity"
    
    var caBasicAnimationKey: String {
      switch self {
      case .bulletPosition: "position"
      case .bulletOpacity: "opacity"
      }
    }
  }
}
