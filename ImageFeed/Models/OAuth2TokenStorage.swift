import Foundation

final class OAuth2TokenStorage {
	/// Имя токена в хранилище.
	let tokenName = "UnsplashAuthToken"
	
	/// токен аутентификации.
	var token: String {
		get {
			UserDefaults.standard.string(forKey: tokenName) ?? String()
		}
		set {
			UserDefaults.standard.set(newValue, forKey: tokenName)
		}
	}
}
