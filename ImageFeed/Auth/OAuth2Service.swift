import Foundation
import SwiftKeychainWrapper

/// Сервис авторизации.
final class OAuth2Service {
	/// Синглтон.
	static let shared = OAuth2Service()
	
	/// Сессия.
	private let urlSession = URLSession.shared
	
	private var task: URLSessionTask?
	
	private var lastCode: String?

	/// Хранилище токена.
	private let tokenStorage = OAuth2TokenStorage()
	
	/// Токен.
	private var authToken: String {
		get {
			KeychainWrapper.standard.string(forKey: TokenName) ?? String()
		}
		set {
			KeychainWrapper.standard.set(newValue, forKey: TokenName)
		}
	}
	
	/// Получение токена аутентификации.
	/// - Parameters:
	///   - code: код авторизации.
	///   - completion: метод обработки результата.
	func fetchAuthToken(code: String, completion: @escaping (Result<String, Error>) -> Void) {
		assert(Thread.isMainThread)

		guard lastCode != code else { return }
		
		task?.cancel()
		lastCode = code
		
		let request = authTokenRequest(code: code)
		let task = object(for: request) { [weak self] result in
			guard let self else { return }
			
			switch result {
			case .success(let body):
				let authToken = body.accessToken
				self.authToken = authToken
				
				completion(.success(authToken))
			case .failure(let error):
				self.lastCode = nil
				completion(.failure(error))
			}
			
			self.task = nil
		}
		
		self.task = task
		task.resume()
	}
}

extension OAuth2Service {
	/// Получение токена.
	/// - Parameters:
	///   - request: запрос.
	///   - completion: метод обработки результата.
	private func object(
		for request: URLRequest,
		completion: @escaping (Result<OAuthTokenResponseBody, Error>) -> Void
	) -> URLSessionTask {
		let decoder = JSONDecoder()
		
		return urlSession.data(for: request) { result in
			let response = result.flatMap { data -> Result<OAuthTokenResponseBody, Error> in
				Result { try decoder.decode(OAuthTokenResponseBody.self, from: data) }
			}
			completion(response)
		}
	}
	
	/// Создание запроса на получение токена.
	/// - Parameter code: кодавторизации.
	/// - Returns: запрос.
	private func authTokenRequest(code: String) -> URLRequest {
		let path = "/oauth/token"
			+ "?client_id=\(AccessKey)"
			+ "&&client_secret=\(SecretKey)"
			+ "&&redirect_uri=\(RedirectURI)"
			+ "&&code=\(code)"
			+ "&&grant_type=authorization_code"

		return URLRequest.makeHTTPRequest(
			path: path,
			httpMethod: "POST",
			baseUrl: URL(string: "https://unsplash.com")!)
	}
}
