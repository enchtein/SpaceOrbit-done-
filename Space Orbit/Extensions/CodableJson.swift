import Foundation

protocol DecodableJson {
  init?(data: Data)
  init?(_ json: String, using encoding: String.Encoding)
  init?(fromURL url: String)
}

extension DecodableJson where Self: Decodable{
  init?(data: Data) {
    guard let me = try? JSONDecoder().decode(Self.self, from: data) else { return nil }
    self = me
  }
}

extension DecodableJson {
  init?(_ json: String, using encoding: String.Encoding = .utf8) {
    guard let data = json.data(using: encoding) else { return nil }
    self.init(data: data)
  }
  
  init?(fromURL url: String) {
    guard let url = URL(string: url), let data = try? Data(contentsOf: url) else { return nil }
    self.init(data: data)
  }
}

protocol EncodableJson {
  var jsonData: Data? { get }
  var json: String? { get }
}

extension EncodableJson where Self: Encodable {
  var jsonData: Data? {
    return try? JSONEncoder().encode(self)
  }
  
  var json: String? {
    guard let data = self.jsonData else { return nil }
    return String(data: data, encoding: .utf8)
  }
}

typealias CodableJson = DecodableJson & EncodableJson

struct JSON {
  static let encoder = JSONEncoder()
}

extension Encodable {
  subscript(key: String) -> Any? {
    return dictionary[key]
  }
  var dictionary: [String: Any] {
    return (try? JSONSerialization.jsonObject(with: JSON.encoder.encode(self))) as? [String: Any] ?? [:]
  }
}

extension Array: CodableJson where Element: Codable {}

extension Array where Element: Any {
  func convertIntoJSONString() -> String? {
    do {
      let jsonData: Data = try JSONSerialization.data(withJSONObject: self, options: [])
      if  let jsonString = NSString(data: jsonData, encoding: String.Encoding.utf8.rawValue) {
        return jsonString as String
      }

    } catch let error as NSError {
      print("Error Array convertIntoJSON - \(error.description)")
    }
    return nil
  }
}

extension Dictionary {
  var jsonStringRepresentation: String? {
    guard let theJSONData = try? JSONSerialization.data(withJSONObject: self, options: [.prettyPrinted]) else {
      return nil
    }
    return String(data: theJSONData, encoding: .ascii)
  }
}

func equals<T>(_ x : T, _ y : T) -> Bool {
  guard x is AnyHashable,
        y is AnyHashable
  else { return false }
  return (x as! AnyHashable) == (y as! AnyHashable)
}
