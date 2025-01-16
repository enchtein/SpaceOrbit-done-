import Foundation

extension UserDefaults {
  enum CodingKeys {
    static let isTurtorialAlreadyAppeared = "isTurtorialAlreadyAppeared"
    static let isGameSoundOff = "isGameSoundOff"
  }
  
  var isTurtorialAlreadyAppeared: Bool {
    get { return bool(forKey: CodingKeys.isTurtorialAlreadyAppeared) }
    set { set(newValue, forKey: CodingKeys.isTurtorialAlreadyAppeared) }
  }
  var isGameSoundOff: Bool {
    get { return bool(forKey: CodingKeys.isGameSoundOff) }
    set { set(newValue, forKey: CodingKeys.isGameSoundOff) }
  }
}
