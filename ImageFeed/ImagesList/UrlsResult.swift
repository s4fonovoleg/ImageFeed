import Foundation

struct UrlsResult: Decodable {
	let Raw: String
	let Full: String
	let Regular: String
	let Small: String
	let Thumb: String

	private enum CodingKeys: String, CodingKey {
		case Raw = "raw"
		case Full = "full"
		case Regular = "regular"
		case Small = "small"
		case Thumb = "thumb"
	}
}
