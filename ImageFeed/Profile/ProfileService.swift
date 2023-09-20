import Foundation

final class ProfileService {
	static let shared = ProfileService()
	
	private let urlSession = URLSession.shared
	
	private var task: URLSessionTask?
	
	var profile: Profile?
	
	func fetchProfile(_ token: String, completion: @escaping (Result<Profile, Error>) -> Void) {
		assert(Thread.isMainThread)
		task?.cancel()
	
		let request = profileRequest(token: token)
		let task = object(for: request) { [weak self] result in
			guard let self else { return }
			
			switch result {
			case .success(let body):
				profile = Profile(body)
				
				guard let profile else { break; }
				
				completion(.success(profile))
			case .failure(let error):
				completion(.failure(error))
			}

			self.task = nil
		}
		
		self.task = task
		task.resume()
	}
}

extension ProfileService {
	private func object(
		for request: URLRequest,
		completion: @escaping (Result<ProfileResult, Error>) -> Void
	) -> URLSessionTask {
		let decoder = JSONDecoder()
		
		return urlSession.data(for: request) { result in
			let response = result.flatMap { data -> Result<ProfileResult, Error> in
				Result { try decoder.decode(ProfileResult.self, from: data) }
			}
			DispatchQueue.main.async {
				completion(response)
			}
		}
	}

	private func profileRequest(token: String) -> URLRequest {
		var request = URLRequest.makeHTTPRequest(
			path: "me",
			httpMethod: "GET",
			baseUrl: DefaultBaseURL)
		request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
		
		return request
	}
}

