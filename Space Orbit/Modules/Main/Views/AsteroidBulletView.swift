//
//  AsteroidBulletView.swift
//  Space Orbit
//
//  Created by Дмитрий Хероим on 16.12.2024.
//

import UIKit

final class AsteroidBulletView: UIView {
  private lazy var buttetImageView: UIImageView = createButtetImageView()
  private lazy var bulletTrackView: UIView = BulletTrackView()
  var displayLink: CADisplayLink?
  
  private let uuid = UUID()
  var uuidString: String { uuid.uuidString }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    setupUI()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  deinit {
    debugPrint("AsteroidBullet deinit called")
  }
  
  private func setupUI() {
    addSubview(buttetImageView)
    buttetImageView.fillToSuperview()
    
    addSubview(bulletTrackView)
    bulletTrackView.translatesAutoresizingMaskIntoConstraints = false
    bulletTrackView.leadingAnchor.constraint(equalTo: buttetImageView.leadingAnchor).isActive = true
    bulletTrackView.trailingAnchor.constraint(equalTo: buttetImageView.trailingAnchor).isActive = true
    bulletTrackView.bottomAnchor.constraint(equalTo: buttetImageView.centerYAnchor).isActive = true
    bulletTrackView.heightAnchor.constraint(equalTo: buttetImageView.heightAnchor, multiplier: 2.0).isActive = true
    
    bringSubviewToFront(buttetImageView)
  }
  
//  func updateImageAngle(to radians: CGFloat) {
//    buttetImageView.transform = CGAffineTransform(rotationAngle: radians)
//  }
}
//MARK: - UI Helpers
private extension AsteroidBulletView {
  func createButtetImageView() -> UIImageView {
    let imageView = UIImageView()
    imageView.image = AppImage.Main.asteroidBullet
    imageView.contentMode = .scaleAspectFill
    
    return imageView
  }
}
//MARK: - API
extension AsteroidBulletView {
  func setupVisibleTrack(with duration: TimeInterval) {
    UIView.animate(withDuration: duration) {
      self.bulletTrackView.alpha = 1.0
    }
  }
}

//MARK: - BulletTrackView
fileprivate final class BulletTrackView: UIView {
  private lazy var mainView = BulletTrackSubView()
  
  private lazy var leadingSubView = BulletTrackSubView()
  private lazy var leadingViewTop = NSLayoutConstraint.init(item: leadingSubView, attribute: .top, relatedBy: .equal, toItem: mainView, attribute: .top, multiplier: 1.0, constant: 0)
  private lazy var leadingViewLeading = NSLayoutConstraint.init(item: leadingSubView, attribute: .leading, relatedBy: .equal, toItem: mainView, attribute: .leading, multiplier: 1.0, constant: 0)
  
  private lazy var middleSubView = BulletTrackSubView()
  private lazy var middleViewTop = NSLayoutConstraint.init(item: middleSubView, attribute: .top, relatedBy: .equal, toItem: mainView, attribute: .top, multiplier: 1.0, constant: 0)
  
  private lazy var trailingSubView = BulletTrackSubView()
  private lazy var trailingViewTop = NSLayoutConstraint.init(item: trailingSubView, attribute: .top, relatedBy: .equal, toItem: mainView, attribute: .top, multiplier: 1.0, constant: 0)
  private lazy var trailingViewTrailing = NSLayoutConstraint.init(item: trailingSubView, attribute: .trailing, relatedBy: .equal, toItem: mainView, attribute: .trailing, multiplier: 1.0, constant: 0)
  
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    setupUI()
  }
  override func layoutSubviews() {
    super.layoutSubviews()
    
    leadingViewTop.constant = frame.height * 0.15625
    leadingViewLeading.constant = frame.width * 0.125
    
    middleViewTop.constant = frame.height * 0.1875
    
    trailingViewTop.constant = frame.height * 0.15625
    trailingViewTrailing.constant = -frame.width * 0.0625
  }
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func setupUI() {
    mainView.transform = .init(rotationAngle: .pi)
    addSubview(mainView)
    mainView.fillToSuperview()
    
    mainView.addSubview(leadingSubView)
    leadingSubView.translatesAutoresizingMaskIntoConstraints = false
    leadingSubView.widthAnchor.constraint(equalTo: mainView.widthAnchor, multiplier: 0.1875).isActive = true
    leadingSubView.heightAnchor.constraint(equalTo: mainView.heightAnchor, multiplier: 0.5625).isActive = true
    leadingViewTop.isActive = true
    leadingViewLeading.isActive = true
    
    mainView.addSubview(middleSubView)
    middleSubView.translatesAutoresizingMaskIntoConstraints = false
    middleSubView.widthAnchor.constraint(equalTo: mainView.widthAnchor, multiplier: 0.1875).isActive = true
    middleSubView.heightAnchor.constraint(equalTo: mainView.heightAnchor, multiplier: 0.5625).isActive = true
    middleSubView.centerXAnchor.constraint(equalTo: mainView.centerXAnchor).isActive = true
    middleViewTop.isActive = true
    
    mainView.addSubview(trailingSubView)
    trailingSubView.translatesAutoresizingMaskIntoConstraints = false
    trailingSubView.widthAnchor.constraint(equalTo: mainView.widthAnchor, multiplier: 0.1875).isActive = true
    trailingSubView.heightAnchor.constraint(equalTo: mainView.heightAnchor, multiplier: 0.5625).isActive = true
    trailingViewTop.isActive = true
    trailingViewTrailing.isActive = true
    
    leadingSubView.layer.zPosition = 1
    middleSubView.layer.zPosition = 1
    trailingSubView.layer.zPosition = 1
  }
}

//MARK: - BulletTrackSubView
fileprivate final class BulletTrackSubView: UIView {
  private(set) var shapeLayer: CAShapeLayer?
  private var gradientLayer: CAGradientLayer?
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    setupConeShape()
  }
  override func layoutSubviews() {
    super.layoutSubviews()
    
    setupConeShape()
  }
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func setupConeShape() {
    shapeLayer?.removeFromSuperlayer()
    gradientLayer?.removeFromSuperlayer()
    
    let path = UIBezierPath()
    
    let width = bounds.width
    let height = bounds.height
    let bottomSideIndent = (width * 0.3) / 2
    
    let topLeftPoint: CGPoint = .zero
    path.move(to: topLeftPoint)
    let topRightPoint: CGPoint = .init(x: width, y: .zero)
    path.addLine(to: topRightPoint)
    let bottomRightPoint: CGPoint = .init(x: width - bottomSideIndent, y: height)
    path.addLine(to: bottomRightPoint)
    let bottomLeftPoint: CGPoint = .init(x: bottomSideIndent, y: height)
    path.addLine(to: bottomLeftPoint)
    path.close()
    
    // Создаем слой для формы
    let shapeLayer = CAShapeLayer()
    shapeLayer.path = path.cgPath
    shapeLayer.fillColor = UIColor.black.cgColor
    self.shapeLayer = shapeLayer
    layer.addSublayer(shapeLayer)
    
    let gradient = CAGradientLayer()
    gradient.frame = path.bounds
    gradient.colors = [AppColor.bulletTrack.cgColor, AppColor.bulletTrack.withAlphaComponent(0.6062).cgColor, AppColor.bulletTrack.withAlphaComponent(0.2394).cgColor, AppColor.bulletTrack.withAlphaComponent(0.0).cgColor]
    
    let shapeMask = CAShapeLayer()
    shapeMask.path = path.cgPath
    gradient.mask = shapeLayer
    gradientLayer = gradient
    layer.addSublayer(gradient)
  }
}
