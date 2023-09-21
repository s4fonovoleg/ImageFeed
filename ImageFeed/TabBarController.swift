import UIKit

final class TabBarController: UITabBarController {
	private let showImagesListSegueId = "ShowImagesList"
	
	override func awakeFromNib() {
		super.awakeFromNib()
		
		let storyboard = UIStoryboard(name: "Main", bundle: .main)
		let imagesListViewController = storyboard.instantiateViewController(
			withIdentifier: "ImagesListViewController"
		) as? ImagesListViewController
		
		guard let imagesListViewController else {
			assertionFailure("Falied to instantiate ImagesListViewController")
			return
		}
		
		let webViewPresenter = ImagesListViewPresenter()
		imagesListViewController.presenter = webViewPresenter
		webViewPresenter.view = imagesListViewController
		
		let profileViewController = ProfileViewController()
		let profileViewPresenter = ProfileViewPresenter()

		profileViewController.presenter = profileViewPresenter
		profileViewPresenter.view = profileViewController
		profileViewController.tabBarItem = UITabBarItem(
			title: nil,
			image: UIImage(named: "tab_profile_active"),
			selectedImage: nil)
		
		self.viewControllers = [imagesListViewController, profileViewController]
	}
}
