import UIKit
import Kingfisher

protocol ImagesListCellDelegate: AnyObject {
	func imageListCellDidTapLike(_ cell: ImagesListCell)
}

final class ImagesListCell: UITableViewCell {
	@IBOutlet weak var cellImage: UIImageView!
	@IBOutlet weak var dateLabel: UILabel!
	@IBOutlet weak var likeButton: UIButton!

	static let reuseIdentifier = "ImagesListCell"
	private let imagesListService = ImagesListService()
	weak var delegate: ImagesListCellDelegate?

	@IBAction func likeButtonClicked(_ sender: Any) {
		delegate?.imageListCellDidTapLike(self)
	}

	override func prepareForReuse() {
		super.prepareForReuse()
		
		cellImage.kf.cancelDownloadTask()
	}
	
	func setIsLiked(_ isLiked: Bool) {
		let newLikeImage = UIImage(named: isLiked ? "RedLike" : "GreyLike")

		self.likeButton.setImage(newLikeImage, for: .normal)
	}
}
