//
//  TimingPresentationController.swift
//  Space Orbit
//
//  Created by Дмитрий Хероим on 04.01.2025.
//

import UIKit

class TimingPresentationController: CommonPresentationController {
  override var dismissByTap: Bool { false }
  
  override var customWidth: CGFloat {
    containerView!.frame.width - (Constants.hIndent * 2)
  }
}
//MARK: - Constants
fileprivate struct Constants {
  static var hIndent: CGFloat { 16.0 }
}
