import UIKit

final class SingleImageViewController: UIViewController {
	@IBOutlet weak var imageView: UIImageView!
	
	@IBOutlet weak var scrollView: UIScrollView!

	var image: UIImage! {
		didSet {
			guard isViewLoaded else { return }
			imageView.image = image
			rescaleAndCenterImageInScrollView(image: image)
		}
	}

	@IBAction func didTapBackButton() {
		dismiss(animated: true)
	}

	@IBAction func didTapShareButton() {
		guard let image = image else { return }
		let activityViewController = UIActivityViewController(activityItems: [image], applicationActivities: nil)
		
		present(activityViewController, animated: true)
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		imageView.image = image
		
		scrollView.minimumZoomScale = 0.1
		scrollView.maximumZoomScale = 1.25
		
		if (image == nil) { return }
		
		rescaleAndCenterImageInScrollView(image: image)
	}
	
	private func rescaleAndCenterImageInScrollView(image: UIImage) {
		let minZoomScale = scrollView.minimumZoomScale
		let maxZoomScale = scrollView.maximumZoomScale

		view.layoutIfNeeded()

		let visibleRectSize = scrollView.bounds.size
		let imageSize = image.size
		let hScale = visibleRectSize.width / imageSize.width
		let vScale = visibleRectSize.height / imageSize.height
		let scale = min(maxZoomScale, max(minZoomScale, max(hScale, vScale)))

		scrollView.setZoomScale(scale, animated: false)
		scrollView.layoutIfNeeded()

		let newContentSize = scrollView.contentSize
		let x = (newContentSize.width - visibleRectSize.width) / 2
		let y = (newContentSize.height - visibleRectSize.height) / 2

		scrollView.setContentOffset(CGPoint(x: x, y: y), animated: false)
	}
}

extension SingleImageViewController: UIScrollViewDelegate {
	func viewForZooming(in scrollView: UIScrollView) -> UIView? {
		imageView
	}
}
