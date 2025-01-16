//
//  AsteroidView.swift
//  Space Orbit
//
//  Created by Дмитрий Хероим on 13.12.2024.
//

import UIKit

final class AsteroidView: UIView {
  private lazy var imageView = createImageView()
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    setupUI()
  }
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func setupUI() {
    addSubview(imageView)
    
    imageView.fillToSuperview(verticalIndents: 5, horizontalIndents: 5)
  }
  
  func updateImageView(to rotationAngle: CGFloat) {
    imageView.transform = CGAffineTransform(rotationAngle: rotationAngle)
  }
}

//MARK: - UI elements crating
private extension AsteroidView {
  func createImageView() -> UIImageView {
    let imageView = UIImageView()
    
    imageView.image = AppImage.Main.asteroid
    imageView.contentMode = .center
    
    return imageView
  }
}
