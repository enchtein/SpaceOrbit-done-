//
//  ShopViewController.swift
//  Space Orbit
//
//  Created by Дмитрий Хероим on 07.01.2025.
//

import UIKit

class ShopViewController: BaseViewController, StoryboardInitializable {
  @IBOutlet weak var bgImageView: UIImageView!
  
  @IBOutlet weak var navPanelContainer: UIView!
  @IBOutlet weak var navPanelContainerHeight: NSLayoutConstraint!
  
  @IBOutlet weak var shopTitleContainer: UIView!
  @IBOutlet weak var shopTitle: UILabel!
  @IBOutlet weak var shopTitleTop: NSLayoutConstraint!
  @IBOutlet weak var shopTitleBottom: NSLayoutConstraint!
  
  @IBOutlet weak var shopTable: UITableView!
  @IBOutlet weak var shotTableOverlayView: UIView!
  @IBOutlet weak var shotTableOverlayViewTop: NSLayoutConstraint!
  @IBOutlet weak var shotTableOverlayViewHeight: NSLayoutConstraint!
  
  private lazy var navPanel = CommonNavPanel.init(type: .navigatable, delegate: self)
  private lazy var viewModel = ShopViewModel(participant: currentParticipant, delegate: self)
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Do any additional setup after loading the view.
    shopTable.register(UINib(nibName: ShopTableViewCell.identifier, bundle: nil), forCellReuseIdentifier: ShopTableViewCell.identifier)
    shopTable.delegate = self
    shopTable.dataSource = self
    
    viewModel.viewDidLoad()
  }
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    
    shotTableOverlayView.setupVGradient(color1: AppColor.linearGradient, color2: AppColor.linearGradient.withAlphaComponent(0.0))
  }
  
  override func addUIComponents() {
    navPanelContainerHeight.isActive = false
    navPanelContainer.addSubview(navPanel)
    navPanel.fillToSuperview()
  }
  override func setupColorTheme() {
    navPanelContainer.backgroundColor = .clear
    shopTable.backgroundColor = .clear
    shotTableOverlayView.backgroundColor = .clear
    
    shopTitle.textColor = AppColor.layerOne
    shopTitleContainer.backgroundColor = .clear
  }
  override func setupFontTheme() {
    shopTitle.font = Constants.shopTitleFont
  }
  override func setupLocalizeTitles() {
    shopTitle.text = ShopTitles.shop.localized
  }
  override func setupIcons() {
    bgImageView.image = AppImage.GameLevelType.low
  }
  override func setupConstraintsConstants() {
    shotTableOverlayViewHeight.constant = Constants.shotTableOverlayViewHeight
    shotTableOverlayViewTop.constant = .zero
    shotTableOverlayView.alpha = .zero
    
    shopTitleTop.constant = Constants.shopTitleVIndent
    shopTitleBottom.constant = Constants.shopTitleVIndent
  }
  override func additionalUISettings() {
    bgImageView.contentMode = .scaleAspectFill
    view.bringSubviewToFront(navPanelContainer)
    view.bringSubviewToFront(shopTitleContainer)
  }
  
  override func currentParticipantSet(_ participant: Participant) {
    viewModel.replaceParticipant(by: participant)
    navPanel.updateBalance(to: participant.coinsScore)
  }
}
//MARK: - UITableViewDelegate
extension ShopViewController: UITableViewDelegate {
  
}
//MARK: - UITableViewDataSource
extension ShopViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    viewModel.numberOfItemsInSection(section)
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    if let cell = tableView.dequeueReusableCell(withIdentifier: ShopTableViewCell.identifier, for: indexPath) as? ShopTableViewCell {
      cell.setupCell(with: viewModel.itemForRow(at: indexPath), delegate: self)
      
      return cell
    } else {
      return UITableViewCell()
    }
  }
}
//MARK: - UIScrollViewDelegate
extension ShopViewController: UIScrollViewDelegate {
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    if scrollView.contentOffset.y <= .zero {
      shotTableOverlayView.alpha = .zero
    } else if shotTableOverlayViewHeight.constant > scrollView.contentOffset.y {
      shotTableOverlayView.alpha = scrollView.contentOffset.y / shotTableOverlayViewHeight.constant
    } else {
      shotTableOverlayView.alpha = 1.0
    }
  }
}
//MARK: - ShopViewModelDelegate
extension ShopViewController: ShopViewModelDelegate {
  func dataSourceDidChange() {
    shopTable.reloadData()
  }
  func reloadCell(at indexPath: IndexPath, with model: ShopModel) {
    guard let cell = shopTable.cellForRow(at: indexPath) as? ShopTableViewCell else { return }
    cell.updateCell(according: model)
  }
  
  func participantDidChange(to value: Participant) {
    AppCoordinator.shared.updateCurrentParticipant(with: value)
  }
  func participantBalanceDidChange(to value: Float) {
    navPanel.updateBalance(to: value)
  }
  
  func showWatchAddsAlert(according model: ShopModel) {
    guard let rocketType = model.rocketType else { return }
    
    //show alert for watch adds
    let closeAction = UIAlertAction(title: ShopTitles.close.localized, style: .cancel)
    let watchAddAction = UIAlertAction(title: ShopTitles.watchAdds.localized, style: .default) { [weak self] _ in
      let watchAddShopModel = self?.viewModel.findWatchAddShopModel()
      //add coins to participant
      self?.viewModel.addWatchAddCoinsToParticipant(from: watchAddShopModel)
    }
    
    let priceStr = getFormatterPriceStr(from: rocketType.price)
    UIAlertController.alert(with: ShopTitles.watchAddsAlertTitle.localized,
                            message: String(format: ShopTitles.watchAddsAlertMsg.localized, priceStr),
                            actions: [closeAction, watchAddAction])
  }
}

//MARK: - ShopTableViewCellDelegate
extension ShopViewController: ShopTableViewCellDelegate {
  func didSelect(cell: ShopTableViewCell) {
    guard let selectedIndexPath = shopTable.indexPath(for: cell) else { return }
    
    let tappedModel = viewModel.itemForRow(at: selectedIndexPath)
    if tappedModel.isWatchAdds {
      viewModel.addWatchAddCoinsToParticipant(from: tappedModel)
    } else if !tappedModel.isPurchased, let rocketType = tappedModel.rocketType {
      if viewModel.balance < rocketType.price {
        showWatchAddsAlert(according: tappedModel)
      } else {
        //show alert for by rocket
        let cancelAction = UIAlertAction(title: ShopTitles.cancel.localized, style: .cancel)
        let buyAction = UIAlertAction(title: ShopTitles.buy.localized, style: .default) { [weak self] _ in
          self?.viewModel.buyRocket(at: tappedModel)
        }
        
        let priceStr = getFormatterPriceStr(from: rocketType.price)
        UIAlertController.alert(with: ShopTitles.buyAlertTitle.localized,
                                message: String(format: ShopTitles.buyAlertMsg.localized, priceStr),
                                actions: [cancelAction, buyAction])
      }
    } else {
      //select rocket
      viewModel.selectRocket(at: tappedModel)
    }
  }
}
//MARK: - CommonNavPanelDelegate
extension ShopViewController: CommonNavPanelDelegate {
  func backButtonAction() {
    popVC()
  }
}
//MARK: - Helpers
private extension ShopViewController {
  func getFormatterPriceStr(from value: Float) -> String {
    let numberFormatter = Constants.getNumberFormatter
    numberFormatter.currencyGroupingSeparator = ","
    return numberFormatter.string(from: NSNumber.init(value: value)) ?? String(value)
  }
}
//MARK: - Constants
fileprivate struct Constants: CommonSettings {
  static var shopTitleFont: UIFont {
    let fontSize = sizeProportion(for: 48.0, minSize: 36.0)
    return AppFont.font(type: .black, size: fontSize)
  }
  static var shopTitleVIndent: CGFloat {
    sizeProportion(for: 24.0)
  }
  
  static var shotTableOverlayViewHeight: CGFloat {
    sizeProportion(for: 75.0)
  }
}
