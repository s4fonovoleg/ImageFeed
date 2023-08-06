import Foundation
import SwiftKeychainWrapper

final class OAuth2TokenStorage {
	static var token: String {
		get {
			KeychainWrapper.standard.string(forKey: TokenName) ?? String()
		}
		set {
			KeychainWrapper.standard.set(newValue, forKey: TokenName)
		}
	}
}
