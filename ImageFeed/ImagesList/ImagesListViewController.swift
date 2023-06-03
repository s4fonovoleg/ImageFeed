import UIKit

extension ImagesListViewController : UITableViewDelegate {
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		performSegue(withIdentifier: ShowSingleImageSegueIdentifier, sender: indexPath)
	}
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		guard let image = UIImage(named: photosName[indexPath.row]) else {
			return 0
		}
		let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
		let imageViewWidth = tableView.bounds.width - imageInsets.left - imageInsets.right
		let imageWidth = image.size.width
		let scale = imageViewWidth / imageWidth
		let cellHeight = image.size.height * scale + imageInsets.top + imageInsets.bottom
		return cellHeight
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

final class ImagesListViewController: UIViewController {
	@IBOutlet private var tableView: UITableView!
	
	private let ShowSingleImageSegueIdentifier  = "ShowSingleImage"
	private let photosName: [String] = Array(0..<20).map{ "\($0)" }
	
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
			let image = UIImage(named: photosName[indexPath.row])
			
			viewController.image = image
		} else {
			super.prepare(for: segue, sender: sender)
		}
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
	}
	
	private func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
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
