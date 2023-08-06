import Foundation

struct Photo: Decodable {
	var id: String
	var size: CGSize
	var createdAt: Date?
	var welcomeDescription: String?
	var thumbImageURL: String
	var largeImageURL: String
	var isLiked: Bool
	
	init(_ photoResult: PhotoResult) {
		let dateFormatter = ISO8601DateFormatter()
		let createdAt = dateFormatter.date(from:photoResult.CreatedAt)
		
		self.id = photoResult.Id
		self.size = CGSize(width: photoResult.Width, height: photoResult.Height)
		self.createdAt = createdAt
		self.welcomeDescription = photoResult.Description
		self.thumbImageURL = photoResult.Urls.Thumb
		self.largeImageURL = photoResult.Urls.Full
		self.isLiked = photoResult.LikedByUser
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
