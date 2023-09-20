import XCTest

final class ImageFeedUITests: XCTestCase {
	private let app = XCUIApplication()
		
	override func setUpWithError() throws {
		continueAfterFailure = false
		
		app.launch()
	}
	
	func testAuth() throws {
		let authButton = app.buttons["Authenticate"]
		XCTAssertTrue(authButton.waitForExistence(timeout: 5))
		authButton.tap()
		
		let webView = app.webViews["UnsplashWebView"]
		
		XCTAssertTrue(webView.waitForExistence(timeout: 20))
		
		let login = "s4fonovoleg@yandex.ru"
		let password = "black&192*"
		let loginTextField = webView.descendants(matching: .textField).element
		let passwordTextField = webView.descendants(matching: .secureTextField).element
		
		XCTAssertTrue(passwordTextField.waitForExistence(timeout: 5))
		XCTAssertTrue(passwordTextField.waitForExistence(timeout: 5))

		loginTextField.tap()
		loginTextField.typeText(login)
		hideKeyboard()
		
		passwordTextField.tap()
		passwordTextField.typeText(password)
		hideKeyboard()
		
		webView.buttons["Login"].tap()

		// print(app.debugDescription)

		let tablesQuery = app.tables
		let cell = tablesQuery.children(matching: .cell).element(boundBy: 0)

		XCTAssertTrue(cell.waitForExistence(timeout: 10))
	}
	
	func testFeed() throws {
		let tablesQuery = app.tables
		var cell = tablesQuery.children(matching: .cell).element(boundBy: 0)

		XCTAssertTrue(cell.waitForExistence(timeout: 5))
		app.swipeUp()
		sleep(3)
		app.swipeDown()
		sleep(3)
		
		cell = tablesQuery.children(matching: .cell).element(boundBy: 0)
		XCTAssertTrue(cell.waitForExistence(timeout: 5))

		// cell.buttons["LikeButton"].tap() <- такой вариант работает нестабильно
		// кнопку находит но тапнуть может через раз (запуская без изменений одни и те же тесты несколько раз подряд)
		cell.buttons.firstMatch.tap()
		sleep(3)
		// сell.buttons["LikeButton"].tap()
		cell.buttons.firstMatch.tap()
		sleep(3)
		cell.tap()
		
		let image = app.scrollViews.images.element(boundBy: 0)
		XCTAssertTrue(image.waitForExistence(timeout: 20))
		image.pinch(withScale: 3, velocity: 1)
		image.pinch(withScale: 0.5, velocity: -1)
		
		let backButton = app.buttons["BackwardButton"]
		XCTAssertTrue(backButton.waitForExistence(timeout: 5))
		backButton.tap()
		XCTAssertTrue(tablesQuery.children(matching: .cell).element(boundBy: 1).waitForExistence(timeout: 5))
	}
	
	func testProfile() throws {
		let tablesQuery = app.tables
		let cell = tablesQuery.children(matching: .cell).element(boundBy: 0)
		XCTAssertTrue(cell.waitForExistence(timeout: 5))
		
		app.tabBars.buttons.element(boundBy: 1).tap()
		XCTAssertTrue(app.staticTexts["Oleg Safonov"].exists)
		XCTAssertTrue(app.staticTexts["@esp4"].exists)
		XCTAssertTrue(app.staticTexts["Creating stuff"].exists)
		
		let logoutButton = app.buttons["LogoutButton"]
		XCTAssertTrue(logoutButton.waitForExistence(timeout: 5))
		logoutButton.tap()
		
		app.alerts["Пока, пока!"].scrollViews.otherElements.buttons["Да"].tap()
		
		let authButton = app.buttons["Authenticate"]
		XCTAssertTrue(authButton.waitForExistence(timeout: 5))
	}
	
	private func hideKeyboard() {
		if app.keyboards.element(boundBy: 0).exists {
			app.toolbars.buttons["Done"].tap()
		}
	}
}
