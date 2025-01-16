//
//  LeaderboardTableViewCell.swift
//  Space Orbit
//
//  Created by Дмитрий Хероим on 13.01.2025.
//

import UIKit

class LeaderboardTableViewCell: UITableViewCell {
  @IBOutlet weak var contentContainer: UIView!
  @IBOutlet weak var contentContainerTop: NSLayoutConstraint!
  @IBOutlet weak var roundedRectangle: UIView!
  
  @IBOutlet weak var labelsHStack: UIStackView!
  @IBOutlet weak var labelsHStackTop: NSLayoutConstraint!
  @IBOutlet weak var labelsHStackLeading: NSLayoutConstraint!
  
  @IBOutlet weak var playerName: UILabel!
  @IBOutlet weak var coinsImageView: UIImageView!
  @IBOutlet weak var coinsLabel: UILabel!
  
  @IBOutlet weak var playerPositionLabel: UILabel!
  
  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    
    guard selected else { return }
    contentContainer.springAnimation { [weak self] in
      guard let self else { return }
      
    }
  }
  
  func setupCell(with model: LeaderboardModel) {
    setupUI(according: model)
  }

}
//MARK: - Helpers
private extension LeaderboardTableViewCell {
  func setupUI(according model: LeaderboardModel) {
    setupColorTheme(according: model)
    setupFontTheme()
    setupLocalizeTitles(according: model)
    setupIcons()
    setupConstraintsConstants()
    additionalUISettings()
  }
  func setupColorTheme(according model: LeaderboardModel) {
    [playerName, coinsLabel, playerPositionLabel].forEach {
      $0?.textColor = AppColor.layerOne
    }
    
    contentContainer.backgroundColor = AppColor.layerThree
    
    roundedRectangle.backgroundColor = .clear
    backgroundView?.backgroundColor = .clear
    backgroundColor = .clear
    roundedRectangle.layer.borderColor = model.isCurrentUser ? AppColor.accentOne.cgColor : AppColor.layerTwo.cgColor
    roundedRectangle.layer.borderWidth = 2
  }
  func setupFontTheme() {
    playerName.font = Constants.playerNameFont
    coinsLabel.font = Constants.coinsLabelFont
    playerPositionLabel.font = Constants.playerPositionLabelFont
  }
  func setupLocalizeTitles(according model: LeaderboardModel) {
    playerName.text = model.name
    coinsLabel.text = Constants.getFormattedText(from: model.balance)
    playerPositionLabel.text = model.rateNumber
  }
  func setupIcons() {
    coinsImageView.image = AppImage.CommonNavPanel.coin
  }
  func setupConstraintsConstants() {
    contentContainerTop.constant = Constants.contentContainerTop
    labelsHStackTop.constant = Constants.labelsHStackTop
    labelsHStackLeading.constant = Constants.labelsHStackLeading
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
  
  static var labelsHStackTop: CGFloat {
    sizeProportion(for: 18.0)
  }
  static var labelsHStackLeading: CGFloat {
    sizeProportion(for: 24.0)
  }
  
  static var contentContainerRadius: CGFloat {
    sizeProportion(for: 18.0)
  }
  
  static var playerNameFont: UIFont {
    let fontSize = sizeProportion(for: 16.0, minSize: 12.0)
    return AppFont.font(type: .bold, size: fontSize)
  }
  static var coinsLabelFont: UIFont {
    let fontSize = sizeProportion(for: 16.0, minSize: 12.0)
    return AppFont.font(type: .medium, size: fontSize)
  }
  static var playerPositionLabelFont: UIFont {
    let fontSize = sizeProportion(for: 18.0, minSize: 14.0)
    return AppFont.font(type: .bold, size: fontSize)
  }
}
