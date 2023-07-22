import Foundation
import SwiftKeychainWrapper

struct Photo : Decodable {
	let id: String
	let size: CGSize
	let createdAt: Date?
	let welcomeDescription: String?
	let thumbImageURL: String
	let largeImageURL: String
	let isLiked: Bool
}

final class ImagesListService {
	private (set) var photos: [Photo] = []
	
	static let DidChangeNotification = Notification.Name(rawValue: "ImagesListServiceDidChange")
	
	private var lastLoadedPage: Int?
	
	private let perPagePhotosCount = 10
	
	private let orderBy = "latest"
	
	private var task: URLSessionTask?
	
	func fetchPhotosNextPage() {
		if (task != nil) {
			return
		}

		let token = KeychainWrapper.standard.string(forKey: TokenName) ?? String()
		let request = imagesListRequest(token: token)
		let task = object(for: request) { [weak self] result in
			guard let self else { return }
			
			switch result {
			case .success(let body):
				self.photos.append(contentsOf: body)
			case .failure(let error):
				print(error.localizedDescription)
			}
			
			self.task = nil
		}
		
		self.task = task
		task.resume()
	}
	
	private func photosDidChanged() {
		NotificationCenter.default.post(
			name: ImagesListService.DidChangeNotification,
			object: self,
			userInfo: ["photos": photos])
	}
	
	private func getNextPageNumber() -> Int {
		if let lastLoadedPage {
			return lastLoadedPage + 1
		}
		
		return 1
	}
	
	private func object(
		for request: URLRequest,
		completion: @escaping (Result<[Photo], Error>) -> Void
	) -> URLSessionTask {
		let decoder = JSONDecoder()
		
		return URLSession.shared.data(for: request) { result in
			let response = result.flatMap { data -> Result<[Photo], Error> in
				Result { try decoder.decode([Photo].self, from: data) }
			}
			completion(response)
		}
	}
	
	private func imagesListRequest(token: String) -> URLRequest {
		var request = URLRequest.makeHTTPRequest(
			path: "photos"
				+ "?page=\(getNextPageNumber())"
				+ "&&per_page=\(perPagePhotosCount)"
				+ "&&order_by=\(orderBy)",
			httpMethod: "GET",
			baseUrl: DefaultBaseURL)
		request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
		
		return request
	}
}
