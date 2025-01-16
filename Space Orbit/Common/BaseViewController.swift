import UIKit

class BaseViewController: UIViewController {
  private(set) var isAppeared = false
  private var kbRect: CGRect = .zero
  
  var currentParticipant: Participant {
    AppCoordinator.shared.currentParticipant ?? .mock
  }
  var currentParticipantBalance: Float {
    currentParticipant.coinsScore
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setupBaseUISettings()
    setupUI()
    
    NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    NotificationCenter.default.addObserver(forName: Notification.Name.currentPrticipantSet, object: nil, queue: .main) { [weak self] (_) in
      guard let self = self else { return }
      self.currentParticipantSet(currentParticipant)
    }
  }
  deinit {
    NotificationCenter.default.removeObserver(self)
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    isAppeared = true
  }
  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
    isAppeared = false
  }
  
  private final func setupBaseUISettings() {
    view.backgroundColor = AppColor.backgroundOne
  }
  private final func setupUI() {
    addUIComponents()
    setupColorTheme()
    setupFontTheme()
    setupLocalizeTitles()
    setupIcons()
    setupConstraintsConstants()
    additionalUISettings()
  }
  
  func addUIComponents() {}
  
  func setupColorTheme() {}
  func setupFontTheme() {}
  func setupLocalizeTitles() {}
  func setupIcons() {}
  
  func setupConstraintsConstants() {}
  func additionalUISettings() {}
  
  func currentParticipantSet(_ participant: Participant) { }
  
  final func popVC() {
    navigationController?.popViewController(animated: true)
  }
  final func popToRootVC() {
    navigationController?.popToRootViewController(animated: true)
  }
  
  func kbFrameChange(to kbRect: CGRect) {}
}

//MARK: - keyboard show/hide actions
extension BaseViewController {
  @objc private final func keyboardWillShow(notification: NSNotification) {
    if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
      kbRect = keyboardFrame.cgRectValue
    }
    kbFrameChange(to: kbRect)
  }
  @objc private final func keyboardWillHide(notification: NSNotification) {
    kbRect = .zero
    kbFrameChange(to: kbRect)
  }
}
