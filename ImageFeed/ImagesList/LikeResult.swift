import Foundation

struct LikeResult: Decodable {
	let Photo: PhotoResult
	
	private enum CodingKeys: String, CodingKey {
		case Photo = "photo"
	}
}
