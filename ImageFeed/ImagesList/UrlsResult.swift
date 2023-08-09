import Foundation

struct UrlsResult: Decodable {
	let raw: String
	let full: String
	let regular: String
	let small: String
	let thumb: String

	private enum CodingKeys: String, CodingKey {
		case raw = "raw"
		case full = "full"
		case regular = "regular"
		case small = "small"
		case thumb = "thumb"
	}
}
