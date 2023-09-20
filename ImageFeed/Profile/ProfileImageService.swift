import Foundation
import SwiftKeychainWrapper

final class ProfileImageService {
	static let DidChangeNotification = Notification.Name(rawValue: "ProfileImageProviderDidChange")
	
	static let shared = ProfileImageService()

	private let urlSession = URLSession.shared
	
	private var task: URLSessionTask?
	
	private(set) var avatarURL: String?
	
	func fetchProfileImageURL(username: String, _ completion: ((Result<String, Error>) -> Void)? = nil) {
		assert(Thread.isMainThread)
		task?.cancel()

		let token = OAuth2TokenStorage.token
		
		guard !token.isEmpty else { return }
		
		let request = profileImageRequest(token: token, username: username)
		let task = object(for: request) { [weak self] result in
			guard let self else { return }
			
			switch result {
			case .success(let body):
				avatarURL = body.profileImage.small
				
				guard let avatarURL else { break; }
				
				postChangeNotification(avatarURL: avatarURL)
				
				completion?(.success(avatarURL))
			case .failure(let error):
				print(error.localizedDescription)
				completion?(.failure(error))
			}

			self.task = nil
		}
		
		self.task = task
		task.resume()
	}
	
	func postChangeNotification(avatarURL: String) {
		NotificationCenter.default.post(
			name: ProfileImageService.DidChangeNotification,
			object: self,
			userInfo: ["URL": avatarURL])
	}
}

extension ProfileImageService {
	private func object(
		for request: URLRequest,
		completion: @escaping (Result<UserResult, Error>) -> Void
	) -> URLSessionTask {
		let decoder = JSONDecoder()
		
		return urlSession.data(for: request) { result in
			let response = result.flatMap { data -> Result<UserResult, Error> in
				Result { try decoder.decode(UserResult.self, from: data) }
			}
			completion(response)
		}
	}

	private func profileImageRequest(token: String, username: String) -> URLRequest {
		var request = URLRequest.makeHTTPRequest(
			path: "users/\(username)",
			httpMethod: "GET",
			baseUrl: DefaultBaseURL)
		request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
		
		return request
	}
}
