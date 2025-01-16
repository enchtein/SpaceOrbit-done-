import UIKit
import Lottie

final class SplashScreenViewController: BaseViewController, StoryboardInitializable {
  @IBOutlet weak var rectangleView: UIView!
  @IBOutlet weak var animationView: LottieAnimationView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Do any additional setup after loading the view.
  }
  
  override func setupColorTheme() {
    rectangleView.backgroundColor = AppColor.accentOne
    animationView.backgroundColor = .clear
  }
  override func additionalUISettings() {
    rectangleView.cornerRadius = Constants.logoViewRadius
    
    animationView.loopMode = .loop
    animationView.play()
  }
}
fileprivate struct Constants {
  static var logoViewRadius: CGFloat {
    let maxRadius = 30.0
    return maxRadius.sizeProportion
  }
}
