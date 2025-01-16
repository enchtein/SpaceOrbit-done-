//
//  LeaderboardViewController.swift
//  Space Orbit
//
//  Created by Дмитрий Хероим on 13.01.2025.
//

import UIKit

class LeaderboardViewController: BaseViewController, StoryboardInitializable {
  @IBOutlet weak var bgImageView: UIImageView!
  
  @IBOutlet weak var navPanelContainer: UIView!
  @IBOutlet weak var navPanelContainerHeight: NSLayoutConstraint!
  
  @IBOutlet weak var leaderboardTitleContainer: UIView!
  @IBOutlet weak var leaderboardTitle: UILabel!
  @IBOutlet weak var leaderboardTitleTop: NSLayoutConstraint!
  
  @IBOutlet weak var leaderboardTable: UITableView!
  @IBOutlet weak var leaderboardOverlayView: UIView!
  @IBOutlet weak var leaderboardOverlayViewTop: NSLayoutConstraint!
  @IBOutlet weak var leaderboardOverlayViewHeight: NSLayoutConstraint!
  
  private lazy var navPanel = CommonNavPanel.init(type: .navigatable, delegate: self)
  private lazy var viewModel = LeaderboardViewModel(participant: currentParticipant, delegate: self)
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Do any additional setup after loading the view.
    leaderboardTable.register(UINib(nibName: LeaderboardTableViewCell.identifier, bundle: nil), forCellReuseIdentifier: LeaderboardTableViewCell.identifier)
    leaderboardTable.delegate = self
    leaderboardTable.dataSource = self
    
    viewModel.viewDidLoad()
  }
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    
    leaderboardOverlayView.setupVGradient(color1: AppColor.linearGradient, color2: AppColor.linearGradient.withAlphaComponent(0.0))
  }
  
  override func addUIComponents() {
    navPanelContainerHeight.isActive = false
    navPanelContainer.addSubview(navPanel)
    navPanel.fillToSuperview()
  }
  override func setupColorTheme() {
    navPanelContainer.backgroundColor = .clear
    leaderboardTable.backgroundColor = .clear
    leaderboardOverlayView.backgroundColor = .clear
    
    leaderboardTitle.textColor = AppColor.layerOne
    leaderboardTitleContainer.backgroundColor = .clear
  }
  override func setupFontTheme() {
    leaderboardTitle.font = Constants.leaderboardTitleFont
  }
  override func setupLocalizeTitles() {
    leaderboardTitle.text = LeaderboardTitles.leaderboard.localized
  }

  override func setupIcons() {
    bgImageView.image = AppImage.GameLevelType.low
  }
  override func setupConstraintsConstants() {
    leaderboardOverlayViewHeight.constant = Constants.leaderboardTableOverlayViewHeight
    leaderboardOverlayViewTop.constant = .zero
    leaderboardOverlayView.alpha = .zero
    
    leaderboardTitleTop.constant = Constants.leaderboardTitleVIndent
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
extension LeaderboardViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: false)
  }
}
//MARK: - UITableViewDataSource
extension LeaderboardViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    viewModel.numberOfItemsInSection(section)
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    if let cell = tableView.dequeueReusableCell(withIdentifier: LeaderboardTableViewCell.identifier, for: indexPath) as? LeaderboardTableViewCell {
      cell.setupCell(with: viewModel.itemForRow(at: indexPath))
      
      return cell
    } else {
      return UITableViewCell()
    }
  }
}
//MARK: - UIScrollViewDelegate
extension LeaderboardViewController: UIScrollViewDelegate {
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    if scrollView.contentOffset.y <= .zero {
      leaderboardOverlayView.alpha = .zero
    } else if leaderboardOverlayViewHeight.constant > scrollView.contentOffset.y {
      leaderboardOverlayView.alpha = scrollView.contentOffset.y / leaderboardOverlayViewHeight.constant
    } else {
      leaderboardOverlayView.alpha = 1.0
    }
  }
}
//MARK: - LeaderboardViewModelDelegate
extension LeaderboardViewController: LeaderboardViewModelDelegate {
  func dataSourceDidChange() {
    leaderboardTable.reloadData()
  }
  
  func participantBalanceDidChange(to value: Float) {
    navPanel.updateBalance(to: value)
  }
}
//MARK: - CommonNavPanelDelegate
extension LeaderboardViewController: CommonNavPanelDelegate {
  func backButtonAction() {
    popVC()
  }
}
//MARK: - Constants
fileprivate struct Constants: CommonSettings {
  static var leaderboardTitleFont: UIFont {
    let fontSize = sizeProportion(for: 48.0, minSize: 36.0)
    return AppFont.font(type: .black, size: fontSize)
  }
  static var leaderboardTitleVIndent: CGFloat {
    sizeProportion(for: 24.0)
  }
  
  static var leaderboardTableOverlayViewHeight: CGFloat {
    sizeProportion(for: 75.0)
  }
}
