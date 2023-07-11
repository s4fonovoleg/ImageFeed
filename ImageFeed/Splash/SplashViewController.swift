import UIKit

final class SplashViewController: UIViewController {
	/// Id сегвея к экрану авторизации.
	let ShowAuthViewControllerSegueId = "ShowAuthViewController"
	
	/// Сервис аутентификации.
	private let authService = OAuth2Service()
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)

		let token = OAuth2TokenStorage().token
		
		if token.isEmpty {
			performSegue(withIdentifier: ShowAuthViewControllerSegueId, sender: nil)
		} else {
			switchToTabBarController()
		}
	}
	
	/// Переход к авторизации.
	private func switchToTabBarController() {
		guard let window = UIApplication.shared.windows.first else { fatalError("Invalid Configuration") }
		
		let tabBarController = UIStoryboard(name: "Main", bundle: .main)
			.instantiateViewController(withIdentifier: "TabBarViewController")
		   
		window.rootViewController = tabBarController
	}
}

extension SplashViewController {
	/// Подготовка к переходу к экрану авторизации.
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == ShowAuthViewControllerSegueId {
			guard
				let navigationController = segue.destination as? UINavigationController,
				let viewController = navigationController.viewControllers.first as? AuthViewController
			else {
				fatalError("Failed to prepare for \(ShowAuthViewControllerSegueId)")
			}

			viewController.delegate = self
		} else {
			super.prepare(for: segue, sender: sender)
		}
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
			case .success:
				self.switchToTabBarController()
			case .failure:
				
				break
			}
		}
	}
}
