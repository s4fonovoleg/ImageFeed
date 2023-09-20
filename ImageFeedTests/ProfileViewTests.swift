@testable import ImageFeed
import XCTest
import SwiftKeychainWrapper

final class ProfileViewPresenterSpy: ProfileViewPresenterProtocol {
	var profileImageServiceObserver: NSObjectProtocol?
	
	var view: ImageFeed.ProfileViewControllerProtocol?

	var viewDidLoadCalled = false
	var logoutCalled = false
	
	func logout() {
		logoutCalled = true
	}
	
	func addProfileImageServiceObserver() {
		
	}
	
	func viewDidLoad() {
		viewDidLoadCalled = true
	}
}

final class ProfileViewControllerSpy: ProfileViewControllerProtocol {
	var presenter: ImageFeed.ProfileViewPresenterProtocol?
	
	var updateAvatarCalled = false
	
	func updateAvatar() {
		updateAvatarCalled = true
	}
}

final class ProfileViewTests: XCTestCase {
	func testViewControllerAddsSubviews() {
		let viewController = ProfileViewController()
		
		_ = viewController.view
		
		XCTAssertTrue(viewController.view.subviews.contains(viewController.profileImageView))
		XCTAssertTrue(viewController.view.subviews.contains(viewController.logoutButton))
		XCTAssertTrue(viewController.view.subviews.contains(viewController.nameLabel))
		XCTAssertTrue(viewController.view.subviews.contains(viewController.loginNameLabel))
		XCTAssertTrue(viewController.view.subviews.contains(viewController.descriptionLabel))
	}
	
	func testAddProfileImageServiceObserverCalled() {
		let viewController = ProfileViewController()
		let presenter = ProfileViewPresenterSpy()
		viewController.presenter = presenter
		
		_ = viewController.view
		
		XCTAssertTrue(presenter.viewDidLoadCalled)
	}
	
	func testProfileViewControllerUpdatesProfileInfo() {
		let viewController = ProfileViewController()
		let profileService = ProfileService()
		let profile = Profile(username: "testUsername", name: "testName", loginName: "testLoginName", bio: "testBio")
		
		viewController.profileService = profileService
		profileService.profile = profile
		_ = viewController.view
		
		XCTAssertEqual(viewController.nameLabel.text, profile.name)
		XCTAssertEqual(viewController.loginNameLabel.text, profile.loginName)
		XCTAssertEqual(viewController.descriptionLabel.text, profile.bio)
	}
	
	func testProfileViewUpdatesAvatar() {
		let viewController = ProfileViewControllerSpy()
		let profileImageService = ProfileImageService()
		let presenter = ProfileViewPresenter()
		
		viewController.presenter = presenter
		presenter.view = viewController
		presenter.addProfileImageServiceObserver()
		profileImageService.postChangeNotification(avatarURL: "testUrl")
		
		XCTAssertTrue(viewController.updateAvatarCalled)
	}
	
	func testPresenterRemovesToken() {
		let presenter = ProfileViewPresenter()

		OAuth2TokenStorage.token = "testToken"
		presenter.logout()
		
		XCTAssertFalse(KeychainWrapper.standard.hasValue(forKey: TokenName))
	}
}
