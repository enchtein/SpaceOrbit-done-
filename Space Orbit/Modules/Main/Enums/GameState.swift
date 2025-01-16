//
//  GameState.swift
//  Space Orbit
//
//  Created by Дмитрий Хероим on 13.12.2024.
//

enum GameState {
  case pedding
  
  case playing
  case paused
  
  case win
  case crashed
  
  var isOrbitVisible: Bool { self == .playing || self == .paused }
}
