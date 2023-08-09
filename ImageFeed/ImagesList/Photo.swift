import Foundation

struct Photo: Decodable {
	var id: String
	var size: CGSize
	var createdAt: Date?
	var welcomeDescription: String?
	var thumbImageURL: String
	var largeImageURL: String
	var isLiked: Bool
	
	static let dateFormatter = ISO8601DateFormatter()
	
	init(_ photoResult: PhotoResult) {
		let createdAt = Photo.dateFormatter.date(from:photoResult.createdAt)
		
		self.id = photoResult.id
		self.size = CGSize(width: photoResult.width, height: photoResult.height)
		self.createdAt = createdAt
		self.welcomeDescription = photoResult.description
		self.thumbImageURL = photoResult.urls.thumb
		self.largeImageURL = photoResult.urls.full
		self.isLiked = photoResult.likedByUser
	}
	
	init(id: String,
		 size: CGSize,
		 createdAt: Date?,
		 welcomeDescription: String?,
		 thumbImageURL: String,
		 largeImageURL: String,
		 isLiked: Bool
	) {
		self.id = id
		self.size = size
		self.createdAt = createdAt
		self.welcomeDescription = welcomeDescription
		self.thumbImageURL = thumbImageURL
		self.largeImageURL = largeImageURL
		self.isLiked = isLiked
	}
}
