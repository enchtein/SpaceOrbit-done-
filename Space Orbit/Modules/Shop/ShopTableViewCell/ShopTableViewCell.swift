//
//  ShopTableViewCell.swift
//  Space Orbit
//
//  Created by Дмитрий Хероим on 09.01.2025.
//

import UIKit

protocol ShopTableViewCellDelegate: AnyObject {
  func didSelect(cell: ShopTableViewCell)
}
class ShopTableViewCell: UITableViewCell {
  @IBOutlet weak var contentContainer: UIView!
  @IBOutlet weak var contentContainerTop: NSLayoutConstraint!
  @IBOutlet weak var roundedRectangle: UIView!
  
  @IBOutlet weak var rocketImageView: UIImageView!
  @IBOutlet weak var rocketImageViewWidth: NSLayoutConstraint!
  
  @IBOutlet weak var labelsVStack: UIStackView!
  @IBOutlet weak var labelsVStackTop: NSLayoutConstraint!
  @IBOutlet weak var labelsVStackLeading: NSLayoutConstraint!
  @IBOutlet weak var rocketLabel: UILabel!
  @IBOutlet weak var arrowImageView: UIImageView!
  @IBOutlet weak var arrowImageViewHeight: NSLayoutConstraint!
  
  @IBOutlet weak var rocketStatusHStack: UIStackView!
  @IBOutlet weak var rocketCoinImageView: UIImageView!
  @IBOutlet weak var rocketStatusLabel: UILabel!
  
  private weak var delegate: ShopTableViewCellDelegate?
  
  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    
    guard selected else { return }
    contentContainer.springAnimation { [weak self] in
      guard let self else { return }
      self.delegate?.didSelect(cell: self)
    }
  }
  
  func setupCell(with model: ShopModel, delegate: ShopTableViewCellDelegate?) {
    self.delegate = delegate
    
    setupUI(according: model)
    
    rocketCoinImageView.isHidden = model.isPurchased
    arrowImageView.isHidden = !model.isWatchAdds
    
    rocketImageView.isHidden = model.rocketType == nil
    rocketImageView.image = model.rocketType?.image
    rocketImageView.transform = .identity
    rocketImageView.transform = .init(rotationAngle: (.pi / 4))
  }
}
//MARK: - API
extension ShopTableViewCell {
  func updateCell(according model: ShopModel) {
    setupUI(according: model)
    
    if model.isPurchased {
      rocketCoinImageView.hideAnimated(in: rocketStatusHStack)
    } else {
      rocketCoinImageView.showAnimated(in: rocketStatusHStack)
    }
    
    arrowImageView.isHidden = !model.isWatchAdds
    
    rocketImageView.isHidden = model.rocketType == nil
    rocketImageView.image = model.rocketType?.image
    rocketImageView.transform = .identity
    rocketImageView.transform = .init(rotationAngle: (.pi / 4))
    
    layoutIfNeeded()
  }
}
//MARK: - Helpers
private extension ShopTableViewCell {
  func setupUI(according model: ShopModel) {
    setupColorTheme(according: model)
    setupFontTheme(according: model)
    setupLocalizeTitles(according: model)
    setupIcons()
    setupConstraintsConstants()
    additionalUISettings()
  }
  func setupColorTheme(according model: ShopModel) {
    rocketLabel.textColor = AppColor.layerOne
    
    let rocketStatusLabelColor: UIColor
    if model.isWatchAdds {
      rocketStatusLabelColor = AppColor.layerOne
    } else if model.isSelected {
      rocketStatusLabelColor = AppColor.accentTwo
    } else if model.isPurchased {
      rocketStatusLabelColor = AppColor.layerTwo
    } else {
      rocketStatusLabelColor = AppColor.layerOne
    }
    UIView.transition(with: rocketStatusLabel, duration: contentContainer.animationDuration, options: .transitionCrossDissolve) {
      self.rocketStatusLabel.textColor = rocketStatusLabelColor
    }
    
    contentContainer.backgroundColor = AppColor.layerThree
    
    roundedRectangle.backgroundColor = .clear
    backgroundView?.backgroundColor = .clear
    backgroundColor = .clear
    roundedRectangle.layer.borderColor = model.isWatchAdds ? AppColor.accentOne.cgColor : AppColor.layerTwo.cgColor
    roundedRectangle.layer.borderWidth = 2
  }
  func setupFontTheme(according model: ShopModel) {
    if model.isWatchAdds {
      rocketLabel.font = Constants.rocketLabelWatchAddsFont
    } else {
      rocketLabel.font = Constants.rocketLabelRocketFont
    }
    
    rocketStatusLabel.font = Constants.rocketStatusLabelFont
  }
  func setupLocalizeTitles(according model: ShopModel) {
    let rocketType = model.rocketType ?? RocketType.defaultRocket
    
    if model.isWatchAdds {
      rocketLabel.text = ShopTableViewCellTitles.watchAdds.localized
    } else {
      rocketLabel.text = rocketType.name
    }
    
    if model.isSelected {
      rocketStatusLabel.text = ShopTableViewCellTitles.active.localized
    } else if model.isPurchased {
      rocketStatusLabel.text = ShopTableViewCellTitles.purchased.localized
    } else {
      let value = model.isWatchAdds ? model.watchAddsPrice : rocketType.price
      let formatedStr = Constants.getNumberFormatter.string(from: NSNumber.init(value: value)) ?? String(value)
      
      rocketStatusLabel.text = model.isWatchAdds ? "+" + formatedStr : formatedStr
    }
  }
  func setupIcons() {
    rocketCoinImageView.image = AppImage.CommonNavPanel.coin
    arrowImageView.image = AppImage.Shop.arrow
  }
  func setupConstraintsConstants() {
    contentContainerTop.constant = Constants.contentContainerTop
    rocketImageViewWidth.constant = Constants.rocketImageViewWidth
    labelsVStackTop.constant = Constants.labelsVStackTop
    labelsVStackLeading.constant = Constants.labelsVStackLeading
    arrowImageViewHeight.constant = Constants.arrowImageViewHeight
  }
  func additionalUISettings() {
    roundedRectangle.roundCorners(.allCorners, radius: Constants.contentContainerRadius)
    contentView.clipsToBounds = false
    
    contentContainer.bringSubviewToFront(rocketImageView)
  }
}
//MARK: - Constants
fileprivate struct Constants: CommonSettings {
  static var contentContainerTop: CGFloat {
    sizeProportion(for: 22.0)
  }
  
  static var rocketImageViewWidth: CGFloat {
    sizeProportion(for: 140)
  }
  
  static var labelsVStackTop: CGFloat {
    sizeProportion(for: 18.5)
  }
  static var labelsVStackLeading: CGFloat {
    sizeProportion(for: 24.0)
  }
  
  static var contentContainerRadius: CGFloat {
    sizeProportion(for: 18.0)
  }
  
  static var arrowImageViewHeight: CGFloat {
    sizeProportion(for: 32.0)
  }
  
  static var rocketLabelWatchAddsFont: UIFont {
    let fontSize = sizeProportion(for: 16.0)
    return AppFont.font(type: .bold, size: fontSize)
  }
  static var rocketLabelRocketFont: UIFont {
    let fontSize = sizeProportion(for: 18.0)
    return AppFont.font(type: .bold, size: fontSize)
  }
  static var rocketStatusLabelFont: UIFont {
    let fontSize = sizeProportion(for: 16.0)
    return AppFont.font(type: .medium, size: fontSize)
  }
}
