import UIKit
import WebKit

/// Адрес сервиса авторизации.
fileprivate let UnsplashAuthorizeURLString = "https://unsplash.com/oauth/authorize"

protocol WebViewViewControllerDelegate {
	func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String)
	func webViewViewControllerDidCancel(_ vc: WebViewViewController)
}

final class WebViewViewController : UIViewController {
	/// WKWebView авторизации.
	@IBOutlet private var webView: WKWebView!
	
	/// UIProgressView загрузки страницы авторизации.
	@IBOutlet private weak var progressView: UIProgressView!
	
	/// Обработчик нажатия кнопки "<".
	/// - Parameter sender: Объект кнопки.
	@IBAction private func didTapBackButton(_ sender: Any) {
		delegate?.webViewViewControllerDidCancel(self)
	}
	
	/// Делегат обработки авторизации.
	var delegate: WebViewViewControllerDelegate?
	
	private var estimatedProgressObservation: NSKeyValueObservation?
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		estimatedProgressObservation = webView.observe(
			\.estimatedProgress,
			options: [],
			changeHandler: { [weak self] _, _ in
				guard let self = self else { return }
				self.updateProgress()
			})
		updateProgress()
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		webView.navigationDelegate = self
		
		var urlComponents = URLComponents(string: UnsplashAuthorizeURLString)!
		urlComponents.queryItems = [
			URLQueryItem(name: "client_id", value: AccessKey),
			URLQueryItem(name: "redirect_uri", value: RedirectURI),
			URLQueryItem(name: "response_type", value: "code"),
			URLQueryItem(name: "scope", value: AccessScope)
		]
		let url = urlComponents.url!
		let request = URLRequest(url: url)
		webView.load(request)
	}
	
	/// Обновление прогресса в progressView.
	private func updateProgress() {
		progressView.progress = Float(webView.estimatedProgress)
		progressView.isHidden = fabs(webView.estimatedProgress - 1.0) <= 0.0001
	}
}

extension WebViewViewController : WKNavigationDelegate {
	func webView(
		_ webView: WKWebView,
		decidePolicyFor navigationAction: WKNavigationAction,
		decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
	) {
		if let code = code(from: navigationAction) {
			delegate?.webViewViewController(self, didAuthenticateWithCode: code)
			decisionHandler(.cancel)
		} else {
			decisionHandler(.allow)
		}
	}
	
	/// Получение кода авторизации.
	private func code(from navigationAction: WKNavigationAction) -> String? {
		if
			let url = navigationAction.request.url,
			let urlComponents = URLComponents(string: url.absoluteString),
			urlComponents.path == "/oauth/authorize/native",
			let items = urlComponents.queryItems,
			let codeItem = items.first(where: { $0.name == "code" })
		{
			return codeItem.value
		} else {
			return nil
		}
	}
}
