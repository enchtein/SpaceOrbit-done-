//
//  SettingsTableViewCell.swift
//  Space Orbit
//
//  Created by Дмитрий Хероим on 12.01.2025.
//

import UIKit

protocol SettingsTableViewCellDelegate: AnyObject {
  func didSelect(cell: SettingsTableViewCell)
}
class SettingsTableViewCell: UITableViewCell {
  @IBOutlet weak var contentContainer: UIView!
  @IBOutlet weak var contentContainerTop: NSLayoutConstraint!
  @IBOutlet weak var roundedRectangle: UIView!
  
  @IBOutlet weak var settingTitle: UILabel!
  @IBOutlet weak var participantNameLabel: UILabel!
  
  @IBOutlet weak var arrowImageView: UIImageView!
  @IBOutlet weak var arrowImageViewHeight: NSLayoutConstraint!
  
  private weak var delegate: SettingsTableViewCellDelegate?
  
  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    
    // Configure the view for the selected state
    guard selected else { return }
    contentContainer.springAnimation { [weak self] in
      guard let self else { return }
      self.delegate?.didSelect(cell: self)
    }
  }
  
  func setupCell(with model: SettingsModel, delegate: SettingsTableViewCellDelegate?) {
    self.delegate = delegate
    
    setupUI(according: model)
    participantNameLabel.isHidden = model.type != .changeParticipantName
  }
  func updateCell(according model: SettingsModel) {
    setupUI(according: model)
  }
}
//MARK: - Helpers
private extension SettingsTableViewCell {
  func setupUI(according model: SettingsModel) {
    setupColorTheme(according: model)
    setupFontTheme(according: model)
    setupLocalizeTitles(according: model)
    setupIcons()
    setupConstraintsConstants()
    additionalUISettings()
  }
  func setupColorTheme(according model: SettingsModel) {
    settingTitle.textColor = model.type == .deleteProfile ? AppColor.accentOne : AppColor.layerOne
    participantNameLabel.textColor = AppColor.layerTwo
    
    contentContainer.backgroundColor = AppColor.layerThree
    
    roundedRectangle.backgroundColor = .clear
    backgroundView?.backgroundColor = .clear
    backgroundColor = .clear
    roundedRectangle.layer.borderColor = AppColor.layerTwo.cgColor
    roundedRectangle.layer.borderWidth = 2
  }
  func setupFontTheme(according model: SettingsModel) {
    settingTitle.font = Constants.settingTitleFont
    participantNameLabel.font = Constants.participantNameLabelFont
  }
  func setupLocalizeTitles(according model: SettingsModel) {
    settingTitle.text = model.type.name
    
    UIView.transition(with: participantNameLabel, duration: contentContainer.animationDuration, options: .transitionCrossDissolve) {
      self.participantNameLabel.text = model.participantName
    }
  }
  func setupIcons() {
    arrowImageView.image = AppImage.Shop.arrow
  }
  func setupConstraintsConstants() {
    contentContainerTop.constant = Constants.contentContainerTop
    arrowImageViewHeight.constant = Constants.arrowImageViewHeight
  }
  func additionalUISettings() {
    roundedRectangle.roundCorners(.allCorners, radius: Constants.contentContainerRadius)
  }
}
//MARK: - Constants
fileprivate struct Constants: CommonSettings {
  static var contentContainerTop: CGFloat {
    sizeProportion(for: 6.0)
  }
  static var contentContainerRadius: CGFloat {
    sizeProportion(for: 18.0)
  }
  static var arrowImageViewHeight: CGFloat {
    sizeProportion(for: 32.0)
  }
  
  static var settingTitleFont: UIFont {
    let fontSize = sizeProportion(for: 16.0)
    return AppFont.font(type: .bold, size: fontSize)
  }
  
  static var participantNameLabelFont: UIFont {
    let fontSize = sizeProportion(for: 16.0)
    return AppFont.font(type: .medium, size: fontSize)
  }
}
