import UIKit
import ProgressHUD
import Kingfisher
import SwiftKeychainWrapper

extension ImagesListViewController : UITableViewDelegate {
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		performSegue(withIdentifier: ShowSingleImageSegueIdentifier, sender: indexPath)
	}
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		let image = photos[indexPath.row]
		let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
		let imageViewWidth = tableView.bounds.width - imageInsets.left - imageInsets.right
		let imageWidth = image.size.width
		let scale = imageViewWidth / imageWidth
		let cellHeight = image.size.height * scale + imageInsets.top + imageInsets.bottom
		return cellHeight
	}
	func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
		if indexPath.row == photos.count - 1 {
			imagesListService.fetchPhotosNextPage()
		}
	}
}

extension ImagesListViewController : UITableViewDataSource {
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return photos.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath)
		
		guard let imageListCell = cell as? ImagesListCell else {
			return UITableViewCell()
		}
		
		configCell(for: imageListCell, with: indexPath)
		
		return imageListCell
	}
}

extension ImagesListViewController: ImagesListCellDelegate {
	func imageListCellDidTapLike(_ cell: ImagesListCell) {
		guard let indexPath = tableView.indexPath(for: cell) else { return }
		
		let photo = photos[indexPath.row]
		
		UIBlockingProgressHUD.show()
		
		imagesListService.changeLike(photoId: photo.id, isLike: !photo.isLiked) { [weak self] result in
			guard let self else { return }
			
			switch result {
			case .success(_):
				cell.setIsLiked(!photo.isLiked)
				UIBlockingProgressHUD.dismiss()
			case .failure(let error):
				UIBlockingProgressHUD.dismiss()
				print(error.localizedDescription)
				let errorMessage = "Не удалось \(!photo.isLiked ? "поставить" : "убрать") лайк"
				showErrorAlert(message: errorMessage)
			}
		}
	}
}

final class ImagesListViewController: UIViewController {
	@IBOutlet private var tableView: UITableView!
	
	private var imageListServiceObserver: NSObjectProtocol?
	private let ShowSingleImageSegueIdentifier  = "ShowSingleImage"
	private let photosName: [String] = Array(0..<20).map{ "\($0)" }
	
	private let imagesListService = ImagesListService()
	private var photos: [Photo] = []
	
	private lazy var dateFormatter: DateFormatter = {
		let formatter = DateFormatter()
		
		formatter.dateStyle = .long
		formatter.timeStyle = .none
		
		return formatter
	}()

	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == ShowSingleImageSegueIdentifier {
			let viewController = segue.destination as! SingleImageViewController
			let indexPath = sender as! IndexPath
			let photo = photos[indexPath.row]
			let imageUrl = URL(string: photo.largeImageURL)
			
			viewController.imageUrl = imageUrl
		} else {
			super.prepare(for: segue, sender: sender)
		}
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		imageListServiceObserver = NotificationCenter.default
			.addObserver(
				forName: ImagesListService.DidChangeNotification,
				object: nil,
				queue: .main
			) { [weak self] _ in
				guard let self = self else { return }
				self.updateTableViewAnimated()
			}
		imagesListService.fetchPhotosNextPage()
	}
	
	private func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
		let photo = photos[indexPath.row]
		let likeImage = UIImage(named: photo.isLiked ? "RedLike" : "GreyLike")
		let imageUrl = URL(string: photo.thumbImageURL)
		let placeholderImage = UIImage(named: "ImagePlaceholder")

		cell.cellImage.kf.setImage(
			with: imageUrl,
			placeholder: placeholderImage
		) { result in
			switch result {
			case .success(_):
				self.tableView.reloadRows(at: [indexPath], with: .automatic)
			case .failure(let error):
				print(error)
			}
		}
		
		if let createdAt = photo.createdAt {
			cell.dateLabel.text = dateFormatter.string(from: createdAt)
		} else {
			cell.dateLabel.text = String()
		}
		
		cell.cellImage.kf.indicatorType = .activity
		cell.likeButton.setImage(likeImage, for: .normal)
		cell.delegate = self
	}
	
	private func updateTableViewAnimated() {
		let currentAmount = photos.count
		let newAmount = imagesListService.photos.count
		
		photos = imagesListService.photos
		
		guard currentAmount != newAmount else { return }
		
		self.tableView.performBatchUpdates {
			let indexPaths = (currentAmount..<newAmount).map { i in
				IndexPath(row: i, section: 0)
			}
			tableView.insertRows(at: indexPaths, with: .automatic)
		}
	}
}
