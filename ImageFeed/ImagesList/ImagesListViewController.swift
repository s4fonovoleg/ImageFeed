import UIKit

extension ImagesListViewController : UITableViewDelegate {
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		
	}
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		let photoName = photosName[indexPath.row]

		guard let image = UIImage(named: photoName) else {
			return 0
		}

		let height = image.size.height
		let width = image.size.width
		
		// let currentCell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath)
		// let cellImageHeight = currentCell.imageView?.image?.size.height
		
		return CGFloat(height)
		
//		guard let image = UIImage(named: photosName[indexPath.row]) else {
//			return 0
//		}
//		let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
//		let imageViewWidth = tableView.bounds.width - imageInsets.left - imageInsets.right
//		let imageWidth = image.size.width
//		let scale = imageViewWidth / imageWidth
//		let cellHeight = image.size.height * scale + imageInsets.top + imageInsets.bottom
//		return cellHeight
	}
}

extension ImagesListViewController : UITableViewDataSource {
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return photosName.count
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

class ImagesListViewController: UIViewController {
	@IBOutlet private var tableView: UITableView!
	
	private let photosName: [String] = Array(0..<20).map{ "\($0)" }
	
	private lazy var dateFormatter: DateFormatter = {
		let formatter = DateFormatter()
		
		formatter.dateStyle = .long
		formatter.timeStyle = .none
		
		return formatter
	}()

	override func viewDidLoad() {
		super.viewDidLoad()
		
		tableView.contentInset = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12)
	}
	
	func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
		let photoName = photosName[indexPath.row]
		
		guard let image = UIImage(named: photoName) else {
			return
		}
		
		let isEven = indexPath.row % 2 == 0
		let likeImage = UIImage(named: isEven ? "GreyLike" : "RedLike")
		
		cell.cellImage.image = image
		cell.dateLabel.text = dateFormatter.string(from: Date())
		cell.likeButton.setImage(likeImage, for: .normal)
	}
}
