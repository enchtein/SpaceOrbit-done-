import UIKit

final class AppCoordinator: NSObject {
  static let shared = AppCoordinator()
  var currentNavigator: UINavigationController?
  
  private(set) var currentParticipant: Participant? {
    didSet {
      Notification.Name.currentPrticipantSet.post()
    }
  }
  
  private override init() { }
  
  func start(with window: UIWindow, completion: @escaping (() -> Void) = {}) {
    completion()
    
    let splashScreenViewController = self.instantiate(.splashScreen)
    currentNavigator = UINavigationController(rootViewController: splashScreenViewController)
    
    currentNavigator?.setNavigationBarHidden(true, animated: true)
    window.rootViewController = currentNavigator
    window.makeKeyAndVisible()
    
    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
        self.activateRoot()
    }
  }
  
  func activateRoot() {
    guard let currentNavigator else { fatalError("currentNavigator - is not initilized") }
    prepair(currentNavigator)
    currentNavigator.setViewControllers([instantiate(.main)], animated: true)
  }
  
  func push(_ controller: AppViewController, animated: Bool = true) {
    let vc = instantiate(controller)
    currentNavigator?.pushViewController(vc, animated: animated)
  }
  func present(_ controller: AppViewController, animated: Bool) {
    let presentingVC = UIApplication.topViewController()
    let vc = instantiate(controller)
    
    presentingVC?.present(vc, animated: animated, completion: nil)
  }
  
  func child(before vc: UIViewController) -> UIViewController? {
    let viewControllers = currentNavigator?.viewControllers ?? []
    
    guard let currentVCIndex = viewControllers.firstIndex(of: vc) else { return nil }
    let prevIndex = viewControllers.index(before: currentVCIndex)
    
    guard viewControllers.indices.contains(prevIndex) else { return nil }
    return viewControllers[prevIndex]
  }
}

//MARK: - Helpers
extension AppCoordinator {
  private func instantiate(_ controller: AppViewController) -> UIViewController {
    switch controller {
    case .splashScreen:
      return SplashScreenViewController.createFromStoryboard()
    case .main:
      return MainViewController.createFromStoryboard()
    case .shop:
      return ShopViewController.createFromStoryboard()
    case .leaderboard:
      return LeaderboardViewController.createFromStoryboard()
    case .settings:
      return SettingsViewController.createFromStoryboard()
    default:
      let vc = UIViewController()
      vc.view.backgroundColor = .green
      return vc
    }
  }
  private func prepair(_ navVC: UINavigationController) {
    navVC.popToRootViewController(animated: true)
    navVC.setNavigationBarHidden(true, animated: true)
  }
}

//MARK: - API
extension AppCoordinator {
  final func updateCurrentParticipant(with info: Participant) {
    currentParticipant = info
  }
  final func getParticipantFromKeychain(completion: (() -> Void)? = nil) {
    let currentParticipantId = KeychainService.loadPassword()
    
    if let currentParticipantId {
      //load info from firebase
      Task {
        let currentParticipant = try? await FirebaseDBManager.shared.getParticipant(by: currentParticipantId)
        await MainActor.run {
          self.currentParticipant = currentParticipant
          completion?()
        }
      }
    } else {
      createNewParticipant()
    }
  }
  final func createNewParticipant() {
    //create new profile
    Task {
      do {
        let allParticipants = try await FirebaseDBManager.shared.getAllParticipants()
        
        let newParticipant = Participant.generateRandom(according: allParticipants)
        
        let createdParticipant = try await FirebaseDBManager.shared.add(participant: newParticipant, oldProfile: nil)
        if let documentId = createdParticipant.id {
          KeychainService.savePassword(token: documentId)
          updateCurrentParticipant(with: createdParticipant)
        }
      } catch {
        print(error.localizedDescription)
      }
    }
  }
}
