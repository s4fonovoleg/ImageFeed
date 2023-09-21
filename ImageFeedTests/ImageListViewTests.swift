import Foundation
import XCTest
@testable import ImageFeed

final class ImageListViewPresenterSpy: ImagesListViewPresenterProtocol {
	var view: ImageFeed.ImagesListViewControllerProtocol?
	
	var viewDidLoadCalled = false
	var changeLikeCalled = false
	
	func viewDidLoad() {
		viewDidLoadCalled = true
	}
	
	func changeLike(photoId: String, isLike: Bool, completion: @escaping (Bool) -> Void) {
		changeLikeCalled = true
	}
	
	func fetchPhotosNextPage() {
		
	}
	
	func getPhotos() -> [ImageFeed.Photo] {
		return [Photo]()
	}
}

final class ImagesListViewControllerSpy: ImagesListViewControllerProtocol {
	var presenter: ImageFeed.ImagesListViewPresenterProtocol?
	var updateTableViewAnimatedCalled = false
	
	func updateTableViewAnimated() {
		updateTableViewAnimatedCalled = true
	}
}

final class ImageListViewTests: XCTestCase {
	func testViewControllerCallsPresenterViewDidLoad() {
		let storyboard = UIStoryboard(name: "Main", bundle: .main)
		let imagesListViewController = storyboard.instantiateViewController(
			withIdentifier: "ImagesListViewController"
		) as? ImagesListViewController
		let presenter = ImageListViewPresenterSpy()

		imagesListViewController?.presenter = presenter
		presenter.view = imagesListViewController
		
		_ = imagesListViewController?.view
		
		XCTAssertTrue(presenter.viewDidLoadCalled)
	}
	
	func testPresenterAddsObserver() {
		let presenter = ImagesListViewPresenter()

		presenter.viewDidLoad()
		
		XCTAssertNotNil(presenter.imageListServiceObserver)
	}
	
	func testPresenterUpdatesTableView() {
		let imagesListViewController = ImagesListViewControllerSpy()
		let presenter = ImagesListViewPresenter()
		let imagesListService = ImagesListService()
		
		imagesListViewController.presenter = presenter
		presenter.view = imagesListViewController
		
		presenter.viewDidLoad()
		imagesListService.photosDidChanged()
		
		XCTAssertTrue(imagesListViewController.updateTableViewAnimatedCalled)
	}
}
