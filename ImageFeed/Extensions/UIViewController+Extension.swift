import UIKit

extension UIViewController {
	func showErrorAlert() {
		let alert = UIAlertController(
			title: "Что-то пошло не так(",
			message: "Не удалось войти в систему",
			preferredStyle: .alert)
		let action = UIAlertAction(title: "Ок", style: .default)

		alert.addAction(action)
		present(alert, animated: true)
	}
	
	func showErrorAlert(
		title: String = "Что-то пошло не так(",
		message: String,
		handler: ((UIAlertAction) -> Void)? = nil) {
		let alert = UIAlertController(
			title: title,
			message: message,
			preferredStyle: .alert)
		let action = UIAlertAction(title: "Ок", style: .default, handler: handler)

		alert.addAction(action)
		present(alert, animated: true)
	}
}
