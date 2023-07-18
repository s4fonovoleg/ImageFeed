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

		KeychainWrapper.standard.removeObject(forKey: TokenName)
		
		let token: String? = KeychainWrapper.standard.string(forKey: TokenName)
		
		if let token {
			fetchProfile(token: token)
		} else {
			present(authViewController, animated: true)
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

//extension SplashViewController {
//	/// Подготовка к переходу к экрану авторизации.
//	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//		if segue.identifier == ShowAuthViewControllerSegueId {
//			guard
//				let navigationController = segue.destination as? UINavigationController,
//				let viewController = navigationController.viewControllers.first as? AuthViewController
//			else {
//				fatalError("Failed to prepare for \(ShowAuthViewControllerSegueId)")
//			}
//
//			viewController.delegate = self
//		} else {
//			super.prepare(for: segue, sender: sender)
//		}
//	}
//}

extension SplashViewController: AuthViewControllerDelegate {
	/// Метод делегата после получения кода авторизации.
	/// - Parameters:
	///   - vc: auth view controller.
	///   - code: код авторизации.
	func authViewController(_ vc: AuthViewController, didAuthenticateWithCode code: String) {
		dismiss(animated: true) { [weak self] in
			guard let self = self else { return }
			
			UIBlockingProgressHUD.show()
			self.fetchAuthToken(code)
		}
	}
	
	/// Получение токена аутентификации.
	/// - Parameters:
	///   - code: код авторизации.
	private func fetchAuthToken(_ code: String) {
		authService.fetchAuthToken(code: code) { [weak self] result in
			guard let self = self else { return }
			
			switch result {
			case .success(let token):
				fetchProfile(token: token)
			case .failure:
				UIBlockingProgressHUD.dismiss()
				break
			}
		}
	}
	
	private func fetchProfile(token: String) {
		profileService.fetchProfile(token) { result in
			UIBlockingProgressHUD.dismiss()

			switch result {
			case .success(let profile):
				ProfileImageService.shared.fetchProfileImageURL(username: profile.username) { _ in }
				self.switchToTabBarController()
				break;
			case .failure(let error):
				print(error.localizedDescription)
				self.showErrorAlert()
				break;
			}
		}
	}
	
	private func showErrorAlert() {
		let alert = UIAlertController(
			title: "Что-то пошло не так(",
			message: "Не удалось войти в систему",
			preferredStyle: .alert)
		let action = UIAlertAction(title: "Ок", style: .default)

		alert.addAction(action)
		present(alert, animated: true)
	}
}
