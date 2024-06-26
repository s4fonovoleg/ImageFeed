import Foundation

/// Ключ доступа приложения.
let AccessKey = "8LO8vISb3jUjwLFhpKo0gR49eAf3aVlNPbQkqJREHfc"

/// Секретный ключ приложения.
let SecretKey = "32GVY8kcfQP1f7uQA8W1XZcIVrnLlnxUNFiriU5K4hI"

/// URI при успешной авторизации.
let RedirectURI = "urn:ietf:wg:oauth:2.0:oob"

/// Контекст доступа.
let AccessScope = "public+read_user+write_likes"

/// Название токена.
let TokenName = "UnsplashAuthToken"

/// Адрес API Unsplash.
let DefaultBaseURL = URL(string: "https://api.unsplash.com/")!

/// Адрес сервиса авторизации.
fileprivate let AuthorizeURLString = "https://unsplash.com/oauth/authorize"

struct AuthConfiguration {
	let accessKey: String
	let secretKey: String
	let redirectURI: String
	let accessScope: String
	let defaultBaseURL: URL
	let authURLString: String
	
	static var standart: AuthConfiguration {
		return AuthConfiguration(
			accessKey: AccessKey,
			secretKey: SecretKey,
			redirectURI: RedirectURI,
			accessScope: AccessScope,
			defaultBaseURL: DefaultBaseURL,
			authURLString: AuthorizeURLString)
	}
}
