import UIKit
import ProgressHUD
import Kingfisher
import SwiftKeychainWrapper

protocol ImagesListViewControllerProtocol: AnyObject {
	var presenter: ImagesListViewPresenterProtocol? { get set }
	func updateTableViewAnimated()
}

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
			presenter?.fetchPhotosNextPage()
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
		let isLiked = !photo.isLiked
		
		changeLike(photoId: photo.id, isLike: isLiked) { success in
			if success {
				cell.setIsLiked(isLiked)
			} else {
				let errorMessage = "Не удалось \(isLiked ? "поставить" : "убрать") лайк"
				self.showErrorAlert(message: errorMessage)
			}
		}
	}
	
	func changeLike(photoId: String, isLike: Bool, completion: @escaping (Bool) -> Void) {
		presenter?.changeLike(photoId: photoId, isLike: isLike) { success in
			completion(success)
		}
	}
}

// MARK: ImagesListViewControllerProtocol

final class ImagesListViewController: UIViewController, ImagesListViewControllerProtocol {
	@IBOutlet private var tableView: UITableView!
	
	private let ShowSingleImageSegueIdentifier  = "ShowSingleImage"
	private var photos: [Photo] = []
	private lazy var dateFormatter: DateFormatter = {
		let formatter = DateFormatter()
		
		formatter.dateStyle = .long
		formatter.timeStyle = .none
		
		return formatter
	}()

	var presenter: ImagesListViewPresenterProtocol?
	
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

		presenter?.viewDidLoad()
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
	
	func updateTableViewAnimated() {
		guard let presenter else { return }

		let currentAmount = photos.count
		photos = presenter.getPhotos()
		let newAmount = photos.count

		guard currentAmount != newAmount else { return }
		
		self.tableView.performBatchUpdates {
			let indexPaths = (currentAmount..<newAmount).map { i in
				IndexPath(row: i, section: 0)
			}
			tableView.insertRows(at: indexPaths, with: .automatic)
		}
	}
}
