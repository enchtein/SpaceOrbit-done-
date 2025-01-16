//
//  HitCoinCollectionViewCell.swift
//  Space Orbit
//
//  Created by Дмитрий Хероим on 29.12.2024.
//

import UIKit

class HitCoinCollectionViewCell: UICollectionViewCell {
  @IBOutlet weak var contentContainer: UIView!
  
  @IBOutlet weak var hitTitlesContainer: UIView!
  @IBOutlet weak var hitCountLabel: UILabel!
  @IBOutlet weak var hitCoefLabel: UILabel!
  @IBOutlet weak var arrowImageView: UIImageView!
  
  private let dashedLineLayer = CAShapeLayer()
  
  override func layoutSubviews() {
    super.layoutSubviews()
    
    // Задаем путь для пунктирной линии
    let lineIndent = Constants.lineWidth / 2
    let path = UIBezierPath(roundedRect: CGRect(origin: .init(x: lineIndent, y: lineIndent),
                                                size: .init(width: hitTitlesContainer.bounds.width - Constants.lineWidth,
                                                            height: hitTitlesContainer.bounds.height - Constants.lineWidth)),
                            cornerRadius: Constants.hitTitlesContainerRadius)
    dashedLineLayer.path = path.cgPath
  }
  
  func setupCell(with model: HitCoinModel) {
    contentContainer.backgroundColor = .clear
    hitTitlesContainer.layer.borderWidth = Constants.lineWidth / 2
    
    arrowImageView.image = AppImage.Main.hitArrow
    setupDashedBorder()
    hitTitlesContainer.setNeedsLayout()
    hitTitlesContainer.layoutIfNeeded()
    
    setupLabelsSettings()
    setupCellUI(according: model)
  }
  
  func updateCell(with model: HitCoinModel) {
    UIView.animate(withDuration: contentContainer.animationDuration) {
      self.setupCellUI(according: model)
    }
  }
}
//MARK: - UI Helpers
private extension HitCoinCollectionViewCell {
  func setupCellUI(according model: HitCoinModel) {
    hitCountLabel.text = "\(model.coefficient.hit) " + MainTitles.hit.localized
    hitCoefLabel.text = "x\(Constants.getFormattedText(from: model.coefficient.coefficient))"
    
    hitTitlesContainer.layer.borderColor = UIColor.clear.cgColor
    dashedLineLayer.strokeColor = UIColor.clear.cgColor
    contentContainer.alpha = 1.0
    
    let hitCountLabelTextColor: UIColor
    switch model.type {
    case .available:
      hitTitlesContainer.backgroundColor = AppColor.layerTwo
      hitTitlesContainer.layer.borderColor = AppColor.layerTwo.cgColor
      hitCountLabelTextColor = AppColor.layerTwo
    case .hit:
      hitTitlesContainer.backgroundColor = AppColor.accentOne
      dashedLineLayer.strokeColor = AppColor.layerTwo.cgColor // Цвет линии
      hitCountLabelTextColor = AppColor.layerOne
    case .opaque:
      hitTitlesContainer.backgroundColor = AppColor.layerTwo
      hitCountLabelTextColor = AppColor.layerOne
      
      contentContainer.alpha = 0.4
    }
    
    UIView.transition(with: hitCountLabel, duration: Constants.animationDuration) {
      self.hitCountLabel.textColor = hitCountLabelTextColor
    }
  }
  
  func setupDashedBorder() {
    // Настройка радиуса скругления
    hitTitlesContainer.layer.cornerRadius = Constants.hitTitlesContainerRadius
    hitTitlesContainer.clipsToBounds = true // Обеспечивает, чтобы дочерние слои оставались внутри границ
    
    dashedLineLayer.strokeColor = AppColor.layerTwo.cgColor // Цвет линии
    dashedLineLayer.lineWidth = Constants.lineWidth
    dashedLineLayer.fillColor = nil // Не заполняем
    dashedLineLayer.lineDashPattern = [3, 3] // Пунктирная линия: длинные и короткие линии
    
    // Добавляем слой к ячейке
    hitTitlesContainer.layer.addSublayer(dashedLineLayer)
  }
  
  func setupLabelsSettings() {
    hitCountLabel.font = Constants.hitCountLabelFont
    hitCountLabel.textColor = AppColor.layerTwo
    hitCoefLabel.font = Constants.hitCoefLabelFont
    hitCoefLabel.textColor = AppColor.layerOne
  }
}
//MARK: - Constants
fileprivate struct Constants: CommonSettings {
  static let lineWidth: CGFloat = 2.0
  static let hitTitlesContainerRadius: CGFloat = 8.0
  
  static var hitCountLabelFont: UIFont {
    let fontSize = sizeProportion(for: 12.0, minSize: 9.0)
    return AppFont.font(type: .regular, size: fontSize)
  }
  static var hitCoefLabelFont: UIFont {
    let fontSize = sizeProportion(for: 12.0, minSize: 9.0)
    return AppFont.font(type: .bold, size: fontSize)
  }
}
