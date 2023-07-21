import UIKit

class AlertHelper {
	static func showErrorAlert(_ vc: UIViewController) {
		let alert = UIAlertController(
			title: "Что-то пошло не так(",
			message: "Не удалось войти в систему",
			preferredStyle: .alert)
		let action = UIAlertAction(title: "Ок", style: .default)

		alert.addAction(action)
		vc.present(alert, animated: true)
	}
}
