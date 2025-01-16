import Foundation

// Constant Identifiers
fileprivate let userAccount = "AuthenticatedUser"
fileprivate let accessGroup = "SecuritySerivice"


/**
 *  User defined keys for new entry
 *  Note: add new keys for new secure item and use them in load and save methods
 */

fileprivate let passwordKey = "KeyForPassword"

// Arguments for the keychain queries
fileprivate let kSecClassValue = NSString(format: kSecClass)
fileprivate let kSecAttrAccountValue = NSString(format: kSecAttrAccount)
fileprivate let kSecValueDataValue = NSString(format: kSecValueData)
fileprivate let kSecClassGenericPasswordValue = NSString(format: kSecClassGenericPassword)
fileprivate let kSecAttrServiceValue = NSString(format: kSecAttrService)
fileprivate let kSecMatchLimitValue = NSString(format: kSecMatchLimit)
fileprivate let kSecReturnDataValue = NSString(format: kSecReturnData)
fileprivate let kSecMatchLimitOneValue = NSString(format: kSecMatchLimitOne)

public final class KeychainService: NSObject {
  
  /**
   * Exposed methods to perform save and load queries.
   */
  
  public class func savePassword(token: String) {
    self.save(service: passwordKey, data: token as NSString)
  }
  
  public class func loadPassword() -> String? {
    return self.load(service: passwordKey)
  }
  
  /**
   * Internal methods for querying the keychain.
   */
  
  private class func save(service: String, data: NSString) {
    let dataFromString: Data = data.data(using: NSUTF8StringEncoding, allowLossyConversion: false)!
    
    // Instantiate a new default keychain query
    let keychainQuery: NSMutableDictionary = NSMutableDictionary(objects: [kSecClassGenericPasswordValue, service, userAccount, dataFromString], forKeys: [kSecClassValue, kSecAttrServiceValue, kSecAttrAccountValue, kSecValueDataValue])
    
    // Delete any existing items
    SecItemDelete(keychainQuery as CFDictionary)
    
    // Add the new keychain item
    SecItemAdd(keychainQuery as CFDictionary, nil)
  }
  
  private class func load(service: String) -> String? {
    // Instantiate a new default keychain query
    // Tell the query to return a result
    // Limit our results to one item
    let keychainQuery: NSMutableDictionary = NSMutableDictionary(objects: [kSecClassGenericPasswordValue, service, userAccount, kCFBooleanTrue!, kSecMatchLimitOneValue], forKeys: [kSecClassValue, kSecAttrServiceValue, kSecAttrAccountValue, kSecReturnDataValue, kSecMatchLimitValue])
    
    var dataTypeRef :AnyObject?
    
    // Search for the keychain items
    let status: OSStatus = SecItemCopyMatching(keychainQuery, &dataTypeRef)
    var contentsOfKeychain: NSString? = nil
    
    if status == errSecSuccess {
      if let retrievedData = dataTypeRef as? NSData {
        contentsOfKeychain = NSString(data: retrievedData as Data, encoding: NSUTF8StringEncoding)
      }
    } else {
#if DEBUG
      print("Nothing was retrieved from the keychain. Status code \(status)")
#endif
    }
    
    return contentsOfKeychain as? String
  }
}
