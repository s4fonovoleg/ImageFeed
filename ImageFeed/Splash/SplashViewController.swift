import UIKit
import ProgressHUD
import SwiftKeychainWrapper

final class SplashViewController: UIViewController {
	private lazy var splashImageView: UIImageView = {
		let splashImage = UIImage(named: "Vector")
		let splashImageView = UIImageView(image: splashImage)

		splashImageView.translatesAutoresizingMaskIntoConstraints = false

		return splashImageView
	}()
	
	private lazy var authViewController: AuthViewController = {
		let storyboard = UIStoryboard(name: "Main", bundle: .main)
		let authViewController = storyboard.instantiateViewController(
			withIdentifier: "AuthViewController"
		) as? AuthViewController
		
		guard let authViewController else { return AuthViewController() }
		
		authViewController.modalPresentationStyle = .fullScreen
		authViewController.delegate = self

		return authViewController
	}()

	let ShowAuthViewControllerSegueId = "ShowAuthViewController"
	
	private let authService = OAuth2Service()
	
	private let profileService = ProfileService.shared
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)

		let token = OAuth2TokenStorage.token

		if token.isEmpty {
			present(authViewController, animated: true)
		} else {
			fetchProfile(token: token)
		}
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		view.backgroundColor = .ypBlack
		
		addSplashLogo()
	}
	
	/// Переход к авторизации.
	private func switchToTabBarController() {
		guard let window = UIApplication.shared.windows.first else { fatalError("Invalid Configuration") }
		
		let tabBarController = UIStoryboard(name: "Main", bundle: .main)
			.instantiateViewController(withIdentifier: "TabBarViewController")
		   
		window.rootViewController = tabBarController
	}
	
	private func addSplashLogo() {
		view.addSubview(splashImageView)
		
		NSLayoutConstraint.activate([
			splashImageView.widthAnchor.constraint(equalToConstant: 75),
			splashImageView.heightAnchor.constraint(equalToConstant: 77),
			splashImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
			splashImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
		])
	}
}

extension SplashViewController: AuthViewControllerDelegate {
	/// Метод делегата после получения кода авторизации.
	/// - Parameters:
	///   - vc: auth view controller.
	///   - code: код авторизации.
	func authViewController(_ vc: AuthViewController, didAuthenticateWithCode code: String) {
		dismiss(animated: true) { [weak self] in
			guard let self = self else { return }
			
			UIBlockingProgressHUD.show()
			self.fetchAuthToken(vc, code)
			
		}
	}
	
	/// Получение токена аутентификации.
	/// - Parameters:
	///   - code: код авторизации.
	private func fetchAuthToken(_ vc: AuthViewController, _ code: String) {
		authService.fetchAuthToken(code: code) { [weak self] result in
			guard let self = self else { return }
			
			switch result {
			case .success(let token):
				fetchProfile(token: token)
			case .failure:
				UIBlockingProgressHUD.dismiss()
				vc.showErrorAlert()
				break
			}
		}
	}
	
	private func fetchProfile(token: String) {
		profileService.fetchProfile(token) { [weak self] result in
			guard let self else { return }

			UIBlockingProgressHUD.dismiss()

			switch result {
			case .success(let profile):
				ProfileImageService.shared.fetchProfileImageURL(username: profile.username)
				self.switchToTabBarController()
				break;
			case .failure(let error):
				print(error.localizedDescription)
				self.showErrorAlert()
				break;
			}
		}
	}
}
