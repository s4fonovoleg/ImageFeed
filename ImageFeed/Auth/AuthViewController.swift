import UIKit

protocol AuthViewControllerDelegate: AnyObject {
	func authViewController(_ vc: AuthViewController, didAuthenticateWithCode code: String)
}

final class AuthViewController : UIViewController {
	private let showWebViewSegueId = "ShowWebView"
	
	weak var delegate: AuthViewControllerDelegate?
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == showWebViewSegueId {
			guard let webViewViewController = segue.destination as? WebViewViewController else {
				assertionFailure("Failed to prepare for \(showWebViewSegueId)")
				return
			}
			
			let webViewPresenter = WebViewPresenter(authHelper: AuthHelper())
			webViewViewController.presenter = webViewPresenter
			webViewPresenter.view = webViewViewController
			webViewViewController.delegate = self
		} else {
			super.prepare(for: segue, sender: sender)
		}
	}
}

// MARK: - WebViewViewControllerDelegate 
extension AuthViewController: WebViewViewControllerDelegate {
	func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String) {
		delegate?.authViewController(self, didAuthenticateWithCode: code)
	}

	func webViewViewControllerDidCancel(_ vc: WebViewViewController) {
		dismiss(animated: true)
	}
}
