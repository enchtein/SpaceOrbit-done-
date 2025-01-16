//
//  RocketView.swift
//  Space Orbit
//
//  Created by Дмитрий Хероим on 13.12.2024.
//

import UIKit

final class RocketView: UIView {
  private lazy var imageView = createImageView()
  var currentOrbit: SpaceOrbitType?
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    setupUI()
  }
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func setupUI() {
    addSubview(imageView)
    
    imageView.fillToSuperview()
  }
  
  func updateImageView(to rotationAngle: CGFloat) {
    imageView.transform = CGAffineTransform(rotationAngle: rotationAngle)
  }
}

//MARK: - UI elements crating
private extension RocketView {
  func createImageView() -> UIImageView {
    let imageView = UIImageView()
    
    let selectedRocket = AppCoordinator.shared.currentParticipant?.selectedRocket ?? RocketType.cosmoRunner
    imageView.image = selectedRocket.image
    imageView.contentMode = .scaleAspectFill
    
    return imageView
  }
}
//MARK: - API
extension RocketView {
  func updateRocketImage(to selectedRocket: RocketType) {
    imageView.image = selectedRocket.image
  }
}
