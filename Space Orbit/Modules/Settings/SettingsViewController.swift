//
//  SettingsViewController.swift
//  Space Orbit
//
//  Created by Дмитрий Хероим on 12.01.2025.
//

import UIKit

class SettingsViewController: BaseViewController, StoryboardInitializable {
  @IBOutlet weak var bgImageView: UIImageView!
  
  @IBOutlet weak var navPanelContainer: UIView!
  @IBOutlet weak var navPanelContainerHeight: NSLayoutConstraint!
  
  @IBOutlet weak var settingsTitleContainer: UIView!
  @IBOutlet weak var settingsTitle: UILabel!
  @IBOutlet weak var settingsTitleTop: NSLayoutConstraint!
  @IBOutlet weak var settingsTitleBottom: NSLayoutConstraint!
  
  @IBOutlet weak var settingsTable: UITableView!
  
  private lazy var navPanel = CommonNavPanel.init(type: .navigatable, delegate: self)
  private lazy var viewModel = SettingsViewModel(participant: currentParticipant, delegate: self)
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Do any additional setup after loading the view.
    settingsTable.register(UINib(nibName: SettingsTableViewCell.identifier, bundle: nil), forCellReuseIdentifier: SettingsTableViewCell.identifier)
    settingsTable.delegate = self
    settingsTable.dataSource = self
    
    viewModel.viewDidLoad()
  }
  
  override func addUIComponents() {
    navPanelContainerHeight.isActive = false
    navPanelContainer.addSubview(navPanel)
    navPanel.fillToSuperview()
  }
  override func setupColorTheme() {
    navPanelContainer.backgroundColor = .clear
    settingsTable.backgroundColor = .clear
    
    settingsTitle.textColor = AppColor.layerOne
    settingsTitleContainer.backgroundColor = .clear
  }
  override func setupFontTheme() {
    settingsTitle.font = Constants.settingsTitleFont
  }
  override func setupLocalizeTitles() {
    settingsTitle.text = SettingsTitles.settings.localized
  }
  override func setupIcons() {
    bgImageView.image = AppImage.GameLevelType.low
  }
  override func setupConstraintsConstants() {
    settingsTitleTop.constant = Constants.settingsTitleVIndent
    settingsTitleBottom.constant = Constants.settingsTitleVIndent
  }
  override func additionalUISettings() {
    bgImageView.contentMode = .scaleAspectFill
  }
  
  override func currentParticipantSet(_ participant: Participant) {
    viewModel.replaceParticipant(by: participant)
    navPanel.updateBalance(to: participant.coinsScore)
  }
}
//MARK: - UITableViewDelegate
extension SettingsViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: false)
  }
}
//MARK: - UITableViewDataSource
extension SettingsViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    viewModel.numberOfItemsInSection(section)
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    if let cell = tableView.dequeueReusableCell(withIdentifier: SettingsTableViewCell.identifier, for: indexPath) as? SettingsTableViewCell {
      cell.setupCell(with: viewModel.itemForRow(at: indexPath), delegate: self)
      
      return cell
    } else {
      return UITableViewCell()
    }
  }
  func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
    let view = UIView()
    
    let verLabel = UILabel()
    verLabel.textAlignment = .center
    verLabel.text = appVersionText()
    verLabel.font = Constants.verLabelFont
    verLabel.textColor = AppColor.layerTwo
    
    view.addSubview(verLabel)
    verLabel.fillToSuperview(verticalIndents: Constants.verLabelVIndent)
    
    return view
  }
}
//MARK: - SettingsTableViewCellDelegate
extension SettingsViewController: SettingsTableViewCellDelegate {
  func didSelect(cell: SettingsTableViewCell) {
    guard let indexPath = settingsTable.indexPath(for: cell) else { return }
    
    let cellType = viewModel.itemForRow(at: indexPath).type
    
    if let link = cellType.link, UIApplication.shared.canOpenURL(link) {
      UIApplication.shared.open(link)
    } else {
      
    }
    switch cellType {
    case .changeParticipantName:
      showChangeNameAlert()
    case .notifications, .shareApp, .privacyPolicy, .termsOfUse:
      openURL(for: cellType)
    case .deleteProfile:
      showDeleteProfileAlert()
    }
    
    func openURL(for type: SettingType) {
      guard let link = type.link else { return }
      if UIApplication.shared.canOpenURL(link) {
        UIApplication.shared.open(link)
      }
    }
  }
}
//MARK: - UI Helpers
private extension SettingsViewController {
  func showChangeNameAlert() {
    let cancelAction = UIAlertAction(title: SettingsTitles.cancel.localized, style: .cancel)

    
    let alert = UIAlertController.generate(with: SettingsTitles.editUserName.localized, message: SettingsTitles.editUserNameMsg.localized, actions: [cancelAction])
    alert.addTextField { [weak self] tf in
      tf.placeholder = SettingsTitles.enterName.localized
      tf.text = self?.currentParticipant.name ?? ""
    }
    
    let saveAction = UIAlertAction(title: SettingsTitles.save.localized, style: .default) { [weak self] _ in
      guard let self else { return }
      let tf = alert.textFields![0]
      let currentText = tf.text ?? ""
      
      guard !currentText.isEmpty else { return }
      self.viewModel.updateParticipantName(to: currentText)
    }
    
    alert.addAction(saveAction)
    present(alert, animated: true)
  }
  func showDeleteProfileAlert() {
    let cancelAction = UIAlertAction(title: SettingsTitles.cancel.localized, style: .cancel)
    let deleteAction = UIAlertAction(title: SettingsTitles.delete.localized, style: .destructive) { [weak self] _ in
      guard let self else { return }
      self.viewModel.deleteParticipant()
      AppCoordinator.shared.createNewParticipant()
    }
    
    UIAlertController.alert(with: SettingsTitles.deleteProfile.localized, message: SettingsTitles.deleteProfileMsg.localized, actions: [cancelAction, deleteAction])
  }
  
  private func appVersionText() -> String {
    let verNum: String
    if let bundleVer = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
      verNum = bundleVer
    } else {
      verNum = "1.0.0"
    }
    
    return SettingsTitles.verApp.localized + " " + verNum
  }
}
//MARK: - SettingsViewModelDelegate
extension SettingsViewController: SettingsViewModelDelegate {
  func dataSourceDidChange() {
    settingsTable.reloadData()
  }
  func reloadCell(at indexPath: IndexPath, with model: SettingsModel) {
    guard let cell = settingsTable.cellForRow(at: indexPath) as? SettingsTableViewCell else { return }
    cell.updateCell(according: model)
  }
  
  func participantDidChange(to value: Participant) {
    AppCoordinator.shared.updateCurrentParticipant(with: value)
  }
  
  func participantBalanceDidChange(to value: Float) {
    navPanel.updateBalance(to: value)
  }
}
//MARK: - CommonNavPanelDelegate
extension SettingsViewController: CommonNavPanelDelegate {
  func backButtonAction() {
    popVC()
  }
}
//MARK: - Constants
fileprivate struct Constants: CommonSettings {
  static var settingsTitleFont: UIFont {
    let fontSize = sizeProportion(for: 48.0, minSize: 36.0)
    return AppFont.font(type: .black, size: fontSize)
  }
  static var settingsTitleVIndent: CGFloat {
    sizeProportion(for: 24.0)
  }
  
  static var verLabelFont: UIFont {
    let fontSize = sizeProportion(for: 14.0, minSize: 10.0)
    return AppFont.font(type: .regular, size: fontSize)
  }
  static var verLabelVIndent: CGFloat {
    sizeProportion(for: 6.0)
  }
}
