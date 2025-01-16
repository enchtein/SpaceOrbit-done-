//
//  SpaceOrbitModel.swift
//  Space Orbit
//
//  Created by Дмитрий Хероим on 13.12.2024.
//

struct SpaceOrbitModel {
  let countOfStars: Int
  let countOfAsteroids: Int
  
  let orbit: SpaceOrbitType
  var orbitTag: Int { orbit.rawValue } //0 - lagest, 1 - medium, 2 - smallest
  
  init(countOfStars: Int, countOfAsteroids: Int, orbit: SpaceOrbitType) {
    self.countOfStars = countOfStars
    self.countOfAsteroids = countOfAsteroids
    self.orbit = orbit
  }
}
