//
//  ShopModel.swift
//  Space Orbit
//
//  Created by Дмитрий Хероим on 10.01.2025.
//

struct ShopModel {
  var isWatchAdds: Bool { rocketType == nil }
  let watchAddsPrice: Float
  
  let rocketType: RocketType?
  let isSelected: Bool
  let isPurchased: Bool
  
  private init(watchAddsPrice: Float, rocketType: RocketType?, isSelected: Bool, isPurchased: Bool) {
    self.watchAddsPrice = watchAddsPrice
    self.rocketType = rocketType
    self.isSelected = isSelected
    self.isPurchased = isPurchased
  }
}
//MARK: - Additional init's
extension ShopModel {
  init(watchAddsPrice: Float) {
    self.init(watchAddsPrice: watchAddsPrice, rocketType: nil, isSelected: false, isPurchased: false)
  }
  init(rocketType: RocketType, isSelected: Bool, isPurchased: Bool) {
    self.init(watchAddsPrice: .zero, rocketType: rocketType, isSelected: isSelected, isPurchased: isPurchased)
  }
  init(isSelected: Bool, basedOn model: Self) {
    self.init(watchAddsPrice: model.watchAddsPrice,
              rocketType: model.rocketType,
              isSelected: isSelected,
              isPurchased: model.isPurchased)
  }
  init(isPurchased: Bool, basedOn model: Self) {
    self.init(watchAddsPrice: model.watchAddsPrice,
              rocketType: model.rocketType,
              isSelected: model.isSelected,
              isPurchased: isPurchased)
  }
}
