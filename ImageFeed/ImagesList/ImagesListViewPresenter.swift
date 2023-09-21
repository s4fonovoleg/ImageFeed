import Foundation

protocol ImagesListViewPresenterProtocol {
	var view: ImagesListViewControllerProtocol? { get set }
	func viewDidLoad()
	func changeLike(photoId: String, isLike: Bool, completion: @escaping (Bool) -> Void)
	func fetchPhotosNextPage()
	func getPhotos() -> [Photo]
}

final class ImagesListViewPresenter: ImagesListViewPresenterProtocol {
	private let imagesListService = ImagesListService()
	private(set) var imageListServiceObserver: NSObjectProtocol?
	weak var view: ImagesListViewControllerProtocol?
	
	func viewDidLoad() {
		imageListServiceObserver = NotificationCenter.default
			.addObserver(
				forName: ImagesListService.didChangeNotification,
				object: nil,
				queue: .main
			) { [weak self] _ in
				guard let self = self else { return }
				view?.updateTableViewAnimated()
			}
		fetchPhotosNextPage()
	}
	
	func changeLike(photoId: String, isLike: Bool, completion: @escaping (Bool)-> Void) {
		UIBlockingProgressHUD.show()
		
		imagesListService.changeLike(photoId: photoId, isLike: isLike) { [weak self] result in
			guard self != nil else { return }

			UIBlockingProgressHUD.dismiss()
			
			switch result {
			case .success(_):
				completion(true)
			case .failure(let error):
				print(error.localizedDescription)
				completion(false)
			}
		}
	}
	
	func fetchPhotosNextPage() {
		imagesListService.fetchPhotosNextPage()
	}
	
	func getPhotos() -> [Photo] {
		return imagesListService.photos
	}
}
