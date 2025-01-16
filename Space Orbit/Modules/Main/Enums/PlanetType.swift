//
//  PlanetType.swift
//  Space Orbit
//
//  Created by Дмитрий Хероим on 13.12.2024.
//

import UIKit

enum PlanetType: Int, CaseIterable {
  case auricas
  case ignisium
  
  case crystallinum
  case laxium

  case jackpotia
  case fortuna
  
  var gameLvl: GameLevelType {
    switch self {
    case .auricas, .ignisium: .low
    case .crystallinum, .laxium: .medium
    case .jackpotia, .fortuna: .high
    }
  }
  
  var image: UIImage {
    switch self {
    case .auricas: AppImage.Planets.auricas
    case .ignisium: AppImage.Planets.ignisium
    case .crystallinum: AppImage.Planets.crystallinum
    case .laxium: AppImage.Planets.laxium
    case .jackpotia: AppImage.Planets.jackpotia
    case .fortuna: AppImage.Planets.fortuna
    }
  }
  
  var name: String {
    switch self {
    case .auricas: "Auricas"
    case .ignisium: "Ignisium"
    case .crystallinum: "Crystallinum"
    case .laxium: "Laxium"
    case .jackpotia: "Jackpotia"
    case .fortuna: "Fortuna"
    }
  }
}
