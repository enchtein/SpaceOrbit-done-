//
//  BetAmountCollectionViewCell.swift
//  Space Orbit
//
//  Created by Дмитрий Хероим on 28.12.2024.
//

import UIKit

class BetAmountCollectionViewCell: UICollectionViewCell {
  @IBOutlet weak var contentContainer: UIView!
  @IBOutlet weak var betAmountLabel: UILabel!
  
  func setupCell(with type: BetAmountType, isAvailable: Bool) {
    betAmountLabel.text = type.title
    
    setupFontTheme()
    setupColorTheme()
    additionalUISettings()
    
    
    contentContainer.alpha = isAvailable ? 1.0 : 0.5
  }
  
  func updateSelectedState(to isSelected: Bool) {
    UIView.animate(withDuration: Constants.animationDuration) {
      self.contentContainer.backgroundColor = isSelected ? AppColor.layerOne : .clear
    }
    UIView.transition(with: betAmountLabel, duration: Constants.animationDuration, options: .transitionCrossDissolve) {
      self.betAmountLabel.textColor = isSelected ? AppColor.backgroundOne : AppColor.layerOne
    }
  }
}
//MARK: - UI Helpers
private extension BetAmountCollectionViewCell {
  func setupFontTheme() {
    betAmountLabel.font = Constants.betAmountLabelFont
  }
  func setupColorTheme() {
    betAmountLabel.textColor = AppColor.layerOne
    contentContainer.backgroundColor = .clear
    contentContainer.layer.borderColor = AppColor.layerTwo.cgColor
  }
  func additionalUISettings() {
    contentContainer.layer.borderWidth = Constants.contentContainerBorderWidth
    contentContainer.cornerRadius = Constants.contentContainerRadius
  }
}
//MARK: - Constants
fileprivate struct Constants: CommonSettings {
  static var betAmountLabelFont: UIFont {
    let fontSize = sizeProportion(for: 12.0, minSize: 9.0)
    return AppFont.font(type: .bold, size: fontSize)
  }
  
  static let contentContainerBorderWidth: CGFloat = 2.0
  static var contentContainerRadius: CGFloat {
    return sizeProportion(for: 8.0)
  }
}
