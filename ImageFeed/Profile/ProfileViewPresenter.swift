import Foundation
import WebKit

protocol ProfileViewPresenterProtocol {
	var view: ProfileViewControllerProtocol? { get set }
	var profileImageServiceObserver: NSObjectProtocol? { get set }
	func logout()
	func addProfileImageServiceObserver()
	func viewDidLoad()
}

final class ProfileViewPresenter: ProfileViewPresenterProtocol {
	var profileImageServiceObserver: NSObjectProtocol?
	weak var view: ProfileViewControllerProtocol?
	
	func viewDidLoad() {
		addProfileImageServiceObserver()
	}
	
	func addProfileImageServiceObserver() {
		profileImageServiceObserver = NotificationCenter.default
			.addObserver(
				forName: ProfileImageService.DidChangeNotification,
				object: nil,
				queue: .main
			) { [weak self] _ in
				guard let self = self else { return }
				view?.updateAvatar()
			}
	}
	
	func logout() {
		OAuth2TokenStorage.removeToken()

		HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
		WKWebsiteDataStore.default().fetchDataRecords(
			ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
			records.forEach { record in
				WKWebsiteDataStore.default().removeData(
					ofTypes: record.dataTypes,
					for: [record],
					completionHandler: {})
			}
		}
		
		switchToSplashViewController()
	}
	
	private func switchToSplashViewController() {
		guard let window = UIApplication.shared.windows.first else {
			assertionFailure("Invalid Configuration")
			return;
		}
		
		let splashController = SplashViewController()
		
		window.rootViewController = splashController
	}
}
