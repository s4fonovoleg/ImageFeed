@testable import ImageFeed
import XCTest

final class WebViewPresenterSpy: WebViewPresenterProtocol {
	var viewDidLoadCalled: Bool = false
	var view: ImageFeed.WebViewViewControllerProtocol?
	
	func viewDidLoad() {
		viewDidLoadCalled = true
	}
	
	func didUpdateProgressValue(_ newValue: Double) {
		
	}
	
	func code(from url: URL) -> String? {
		nil
	}
}

final class WebViewViewControllerSpy: WebViewViewControllerProtocol {
	var loadCalled = false
	var presenter: ImageFeed.WebViewPresenterProtocol?
	
	func load(request: URLRequest) {
		loadCalled = true
	}
	
	func setProgressValue(_ newValue: Float) {
		
	}
	
	func setProgressHidden(_ isHidden: Bool) {
		
	}
}

final class WebViewTests: XCTestCase {
	func testViewControllerCallsViewDidLoad() {
		// Given
		let storyboard = UIStoryboard(name: "Main", bundle: nil)
		let webViewController = storyboard.instantiateViewController(identifier: "WebViewViewController") as! WebViewViewController
		let presenter = WebViewPresenterSpy()
		
		webViewController.presenter = presenter
		presenter.view = webViewController
		
		// When
		_ = webViewController.view
		
		// Then
		XCTAssertTrue(presenter.viewDidLoadCalled)
	}
	
	func testPresenterCallsLoadRequest() {
		// Given
		let webViewController = WebViewViewControllerSpy()
		let presenter = WebViewPresenter(authHelper: AuthHelper())
		
		webViewController.presenter = presenter
		presenter.view = webViewController
		
		// When
		presenter.viewDidLoad()
		
		// Then
		XCTAssertTrue(webViewController.loadCalled)
	}
	
	func testProgressVisibleWhenLessThenOne() {
		// Given
		let presenter = WebViewPresenter(authHelper: AuthHelper())
		let progress: Float = 0.6
		
		// When
		let shouldHideProgress = presenter.shouldHideProgress(for: progress)
		
		// Then
		XCTAssertFalse(shouldHideProgress)
	}
	
	func testProgressHiddenWhenOne() {
		// Given
		let presenter = WebViewPresenter(authHelper: AuthHelper())
		let progress: Float = 1
		
		// When
		let shouldHideProgress = presenter.shouldHideProgress(for: progress)
		
		// Then
		XCTAssertTrue(shouldHideProgress)
	}
	
	func testAuthHelperAuthURL() {
		// Given
		let configuration = AuthConfiguration.standart
		let authHelper = AuthHelper(configuration: configuration)
		
		// When
		let url = authHelper.authUrl()
		let urlString = url.absoluteString
		
		// Then
		XCTAssertTrue(urlString.contains(configuration.authURLString))
		XCTAssertTrue(urlString.contains(configuration.accessKey))
		XCTAssertTrue(urlString.contains(configuration.redirectURI))
		XCTAssertTrue(urlString.contains("code"))
		XCTAssertTrue(urlString.contains(configuration.accessScope))
	}
	
	func testCodeFromURL() {
		let authHelper = AuthHelper()
		let codeTestValue = "test code"
		var urlComponents = URLComponents(string: "https://unsplash.com/oauth/authorize/native")
		urlComponents?.queryItems = [URLQueryItem(name: "code", value: codeTestValue)]
		
		let url = urlComponents?.url
		
		guard let url else {
			XCTAssertNotNil(url)
			return
		}
		
		let code = authHelper.code(from: url)
		XCTAssertEqual(code, codeTestValue)
	}
}
