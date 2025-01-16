//
//  MainPageViewController.swift
//  Space Orbit
//
//  Created by Дмитрий Хероим on 25.12.2024.
//

import UIKit

class MainPageViewController: UIPageViewController {
  private let pagesDataSource = PlanetType.allCases
  private var currentPageType = PlanetType.auricas
  private var currentPageIndex: Int { currentPageType.rawValue }
  var gameState: GameState = .pedding
  
  var mainVC: MainViewController? { parent as? MainViewController }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Do any additional setup after loading the view.
    let viewController = pageContentController(.zero)
    let viewControllers = [viewController]
    
    setViewControllers(viewControllers,
                       direction: .forward,
                       animated: false,
                       completion: nil)
    
    view.backgroundColor = .clear
    dataSource = self
    delegate = self
  }
}
//MARK: - UIPageViewControllerDataSource
extension MainPageViewController: UIPageViewControllerDataSource {
  func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
    guard let step = planetType(of: viewController) else { return nil }
    let stepIndex = pagesDataSource.firstIndex(of: step) ?? .zero
    let prevPageIndex = stepIndex - 1
    
    guard pagesDataSource.indices.contains(prevPageIndex) else { return nil }
    return pageContentController(prevPageIndex)
  }
  
  func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
    guard let step = planetType(of: viewController) else { return nil }
    let stepIndex = pagesDataSource.firstIndex(of: step) ?? .zero
    let nextPageIndex = stepIndex + 1
    
    guard pagesDataSource.indices.contains(nextPageIndex) else { return nil }
    return pageContentController(nextPageIndex)
  }
  
  func presentationCount(for pageViewController: UIPageViewController) -> Int {
    return pagesDataSource.count
  }
}
//MARK: - UIPageViewControllerDelegate
extension MainPageViewController: UIPageViewControllerDelegate {
  func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
    guard let currentPage = getCurrentGamePageVC() else { return }
    pageControlDidChange(to: currentPage.planetType)
    resetGame(for: previousViewControllers)
  }
}
//MARK: - DataSource Helpers
private extension MainPageViewController {
  func getCurrentGamePageVC() -> GamePageController? {
    viewControllers?.first as? GamePageController
  }
  func pageContentController(_ index: Int) -> GamePageController {
    let planetType = pagesDataSource[index]
    
    let vc = GamePageController.createFromStoryboard()
    vc.planetType = planetType
    
    return vc
  }
  
  func planetType(of vc: UIViewController?) -> PlanetType? {
    guard let vc = vc as? GamePageController else { return nil }
    return vc.planetType
  }
  func pageControlDidChange(to planetType: PlanetType) {
    guard currentPageType != planetType else { return }
    currentPageType = planetType
    
    mainVC?.pageControlDidChange(to: planetType)
  }
  func resetGame(for previousViewControllers: [UIViewController]) {
    previousViewControllers.compactMap { $0 as? GamePageController }.forEach {
      $0.updateGameState(.pedding)
    }
  }
}
//MARK: - API
extension MainPageViewController {
  func forceUpdateGameStateToWin() {
    guard let currentPage = getCurrentGamePageVC() else { return }
    currentPage.forceUpdateGameStateToWin()
  }
  func updateGameState(_ gameState: GameState) {
    guard let currentPage = getCurrentGamePageVC() else { return }
    self.gameState = gameState
    updatePaggingScrollAvailability()
    
    currentPage.updateGameState(gameState)
  }
  func outerUpdateGameState(_ gameState: GameState) {
    mainVC?.outerUpdateGameState(gameState)
    updateGameState(gameState)
  }
  
  func updateHitCoinsCount(to value: Int) {
    mainVC?.updateHitCoinsCount(to: value)
  }
}
//MARK: - UI Helpers
extension MainPageViewController {
  func updatePaggingScrollAvailability() {
    for subview in view.subviews {
      if let scroll = subview as? UIScrollView {
        scroll.isScrollEnabled = !gameState.isOrbitVisible
      }
    }
  }
}
