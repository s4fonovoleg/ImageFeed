import Foundation
import SwiftKeychainWrapper

final class ImagesListService {
	private (set) var photos: [Photo] = []
	
	static let DidChangeNotification = Notification.Name(rawValue: "ImagesListServiceDidChange")
	
	private var lastLoadedPage = 1
	
	private let perPagePhotosCount = 10
	
	private let orderBy = "latest"
	
	private var task: URLSessionTask?
	
	private let token: String
	
	init() {
		token = OAuth2TokenStorage.token
	}
	
	func fetchPhotosNextPage() {
		if (task != nil) {
			return
		}

		let request = imagesListRequest(token: token)
		let task = object(for: request) { [weak self] result in
			guard let self else { return }
			
			switch result {
			case .success(let body):
				for photo in body {
					photos.append(Photo(photo))
				}
				lastLoadedPage += 1
				photosDidChanged()
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
	
	private func object(
		for request: URLRequest,
		completion: @escaping (Result<[PhotoResult], Error>) -> Void
	) -> URLSessionTask {
		let decoder = JSONDecoder()
		
		return URLSession.shared.data(for: request) { result in
			let response = result.flatMap { data -> Result<[PhotoResult], Error> in
				Result { try decoder.decode([PhotoResult].self, from: data) }
			}
			completion(response)
		}
	}
	
	private func likeObject(
		for request: URLRequest,
		completion: @escaping (Result<LikeResult, Error>) -> Void
	) -> URLSessionTask {
		let decoder = JSONDecoder()

		return URLSession.shared.data(for: request) { result in
			let response = result.flatMap { data -> Result<LikeResult, Error> in
				Result { try decoder.decode(LikeResult.self, from: data) }
			}
			completion(response)
		}
	}
	
	private func imagesListRequest(token: String) -> URLRequest {
		let path = "photos"
					+ "?page=\(lastLoadedPage)"
					+ "&&per_page=\(perPagePhotosCount)"
					+ "&&order_by=\(orderBy)"
		var request = URLRequest.makeHTTPRequest(
			path: path,
			httpMethod: "GET",
			baseUrl: DefaultBaseURL)
		request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
		
		return request
	}
	
	func changeLike(photoId: String, isLike: Bool, _ completion: @escaping (Result<LikeResult, Error>) -> Void) {
		let request = likeRequest(token: token, isLike: isLike, photoId: photoId)
		
		let task = likeObject(for: request) { [weak self] result in
			guard let self else { return }

			switch result {
			case .success(_):
				DispatchQueue.main.async {
					self.setIsLiked(photoId: photoId, isLiked: isLike)
				}
			case .failure(let error):
				print(error.localizedDescription)
			}
			completion(result)
		}
	}
	
	func likeRequest(token: String, isLike: Bool, photoId: String) -> URLRequest {
		var request = URLRequest.makeHTTPRequest(
			path: "photos/\(photoId)/like",
			httpMethod: isLike ? "POST" : "DELETE",
			baseUrl: DefaultBaseURL)
		request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
		
		return request
	}
	
	private func setIsLiked(photoId: String, isLiked: Bool) {
		guard let index = self.photos.firstIndex(where: {$0.id == photoId}) else { return }
		
		let photo = photos[index]
		let newPhoto = Photo(
			id: photo.id,
			size: photo.size,
			createdAt: photo.createdAt,
			welcomeDescription: photo.welcomeDescription,
			thumbImageURL: photo.thumbImageURL,
			largeImageURL: photo.largeImageURL,
			isLiked: !photo.isLiked
		)
		
		self.photos[index] = newPhoto
//		self.photos = self.photos.withReplaced(itemAt: index, newValue: newPhoto)
	}
}
