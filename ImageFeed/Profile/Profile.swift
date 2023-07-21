import Foundation

struct Profile {
	let username: String
	let name: String
	let loginName: String
	let bio: String
	
	init(_ profileResult: ProfileResult) {
		username = profileResult.username
		name = "\(profileResult.firstName) \(profileResult.lastName)"
		loginName = "@\(profileResult.username)"
		bio = profileResult.bio ?? String()
	}
}
