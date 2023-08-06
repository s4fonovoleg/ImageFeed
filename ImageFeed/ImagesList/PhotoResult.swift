import Foundation

struct PhotoResult: Decodable {
	let Id: String
	let CreatedAt: String
	let UpdatedAt: String
	let Width: Int
	let Height: Int
	let Color: String
	let BlurHash: String
	let Likes: Int
	let LikedByUser: Bool
	let Description: String?
	let Urls: UrlsResult
	
	private enum CodingKeys: String, CodingKey {
		case Id = "id"
		case CreatedAt = "created_at"
		case UpdatedAt = "updated_at"
		case Width = "width"
		case Height = "height"
		case Color = "color"
		case BlurHash = "blur_hash"
		case Likes = "likes"
		case LikedByUser = "liked_by_user"
		case Description = "description"
		case Urls = "urls"
	}
}
