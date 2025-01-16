//
//  RocetType.swift
//  Space Orbit
//
//  Created by Дмитрий Хероим on 13.12.2024.
//

import UIKit

enum RocketType: Int, CaseIterable {
  case stellarAce = 0
  case cosmoRunner
  case fortuneFlyer
  case jackpotCruiser
  case orbiterX
  case luckyComet
  
  static let defaultRocket: RocketType = .stellarAce
  
  var name: String {
    switch self {
    case .stellarAce: "Stellar Ace"
    case .cosmoRunner: "Cosmo Runner"
    case .fortuneFlyer: "Fortune Flyer"
    case .jackpotCruiser: "Jackpot Cruiser"
    case .orbiterX: "Orbiter X"
    case .luckyComet: "Lucky Comet"
    }
  }
  
  var image: UIImage {
    switch self {
    case .stellarAce: AppImage.Rockets.stellarAce
    case .cosmoRunner: AppImage.Rockets.cosmoRunner
    case .fortuneFlyer: AppImage.Rockets.fortuneFlyer
    case .jackpotCruiser: AppImage.Rockets.jackpotCruiser
    case .orbiterX: AppImage.Rockets.orbiterX
    case .luckyComet: AppImage.Rockets.luckyComet
    }
  }
  
  var price: Float {
    switch self {
    case .stellarAce:
        .zero
    case .cosmoRunner:
      10000
    case .fortuneFlyer:
      20000
    case .jackpotCruiser:
      30000
    case .orbiterX:
      40000
    case .luckyComet:
      50000
    }
  }
}
