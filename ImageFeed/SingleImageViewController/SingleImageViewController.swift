import UIKit
import Kingfisher

final class SingleImageViewController: UIViewController {
	@IBOutlet private weak var imageView: UIImageView!
	@IBOutlet private weak var scrollView: UIScrollView!

	var imageUrl: URL?
	
	var image: UIImage! {
		didSet {
			guard isViewLoaded else { return }
			imageView.image = image
			rescaleAndCenterImageInScrollView(image: image)
		}
	}

	@IBAction private func didTapBackButton() {
		dismiss(animated: true)
	}

	@IBAction private func didTapShareButton() {
		guard let image = image else { return }
		let activityViewController = UIActivityViewController(activityItems: [image], applicationActivities: nil)
		
		present(activityViewController, animated: true)
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()

		scrollView.minimumZoomScale = 0.1
		scrollView.maximumZoomScale = 3.25
		
		loadImage()
	}
	
	private func loadImage() {
		UIBlockingProgressHUD.show()
		imageView.kf.setImage(
			with: imageUrl
		) { result in
			UIBlockingProgressHUD.dismiss()
			switch result {
			case .success(_):
				if let image = self.imageView.image {
					self.rescaleAndCenterImageInScrollView(image: image)
				}
			case .failure(let error):
				print(error)

				self.showLoadingError() { action in
					if (action.style == .cancel) {
						self.dismiss(animated: true)
					} else {
						self.loadImage()
					}
				}
			}
		}
	}
	
	private func showLoadingError(handler: @escaping (UIAlertAction) -> Void) {
		let alert = UIAlertController(
			title: "Что-то пошло не так. Попробовать ещё раз?",
			message: nil,
			preferredStyle: .alert)
		let repeatAction = UIAlertAction(title: "Повторить", style: .default, handler: handler)
		let cancelAction = UIAlertAction(title: "Не надо", style: .cancel, handler: handler)

		alert.addAction(repeatAction)
		alert.addAction(cancelAction)
		present(alert, animated: true)
	}
	
	private func rescaleAndCenterImageInScrollView(image: UIImage) {
		let minZoomScale = scrollView.minimumZoomScale
		let maxZoomScale = scrollView.maximumZoomScale

		view.layoutIfNeeded()

		let visibleRectSize = scrollView.bounds.size
		let imageSize = image.size
		let hScale = visibleRectSize.width / imageSize.width
		let vScale = visibleRectSize.height / imageSize.height
		let zoomedScale = min(maxZoomScale, max(minZoomScale, max(hScale, vScale)))
		let fitScale = min(maxZoomScale, max(minZoomScale, min(hScale, vScale)))

		scrollView.setZoomScale(zoomedScale, animated: false)
		scrollView.layoutIfNeeded()

		let newContentSize = scrollView.contentSize

		let x = (newContentSize.width - visibleRectSize.width)// / 2
		let y = (newContentSize.height - visibleRectSize.height)// / 2

		scrollView.setContentOffset(CGPoint(x: x, y: y), animated: false)
	}
	
	func scrollViewDidZoom(_ scrollView: UIScrollView) {
		let imageViewSize = imageView.frame.size
		let scrollViewSize = scrollView.bounds.size
		
		let verticalPadding = imageViewSize.height < scrollViewSize.height ? (scrollViewSize.height - imageViewSize.height) / 2 : 0
		let horizontalPadding = imageViewSize.width < scrollViewSize.width ? (scrollViewSize.width - imageViewSize.width) / 2 : 0
		
		scrollView.contentInset = UIEdgeInsets(top: verticalPadding, left: horizontalPadding, bottom: verticalPadding, right: horizontalPadding)
	}
}

extension SingleImageViewController: UIScrollViewDelegate {
	func viewForZooming(in scrollView: UIScrollView) -> UIView? {
		imageView
	}
}
