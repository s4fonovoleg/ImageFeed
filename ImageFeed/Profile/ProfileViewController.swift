import UIKit
import WebKit
import Kingfisher
import SwiftKeychainWrapper

final class ProfileViewController : UIViewController {
	private let profileService = ProfileService.shared
	
	private var profileImageServiceObserver: NSObjectProtocol?
	
	// MARK: Private view properties
	
	private lazy var profileImageView: UIImageView = {
		let profileImage = UIImage(named: "EmptyProfileImage")
		let profileImageView = UIImageView(image: profileImage)

		profileImageView.translatesAutoresizingMaskIntoConstraints = false

		return profileImageView
	}()

	private lazy var logoutButton: UIButton = {
		let logoutImage = UIImage(named: "LogoutImage")
		
		let logoutButton = UIButton.systemButton(
			with: logoutImage ?? UIImage(),
			target: self,
			action: #selector(logoutButtonTapped))

		logoutButton.translatesAutoresizingMaskIntoConstraints = false
		logoutButton.tintColor = .ypRed

		return logoutButton
	}()

	private lazy var nameLabel: UILabel = {
		let nameLabel = UILabel()

		nameLabel.translatesAutoresizingMaskIntoConstraints = false
		nameLabel.text = "Имя пользователя"
		nameLabel.font = .systemFont(ofSize: 23, weight: .bold)
		nameLabel.textColor = .ypWhite
		
		return nameLabel
	}()

	private lazy var loginNameLabel: UILabel = {
		let loginNameLabel = UILabel()

		loginNameLabel.translatesAutoresizingMaskIntoConstraints = false
		loginNameLabel.text = "@username"
		loginNameLabel.font = .systemFont(ofSize: 13, weight: .regular)
		loginNameLabel.textColor = .ypGray
		
		return loginNameLabel
	}()

	private lazy var descriptionLabel: UILabel = {
		let descriptionLabel = UILabel()
		
		descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
		descriptionLabel.text = "Hello, Wordl!"
		descriptionLabel.font = .systemFont(ofSize: 13, weight: .regular)
		descriptionLabel.textColor = .ypWhite
		
		return descriptionLabel
	}()
	
	// MARK: Lifecycle
	
	override func viewDidLoad() {
		super.viewDidLoad()

		view.backgroundColor = .ypBlack
		
		addProfileImageView()
		addLogoutButton()
		addNameLabel()
		addLoginNameLabel()
		addDescriptionLabel()
		updateProfileDetails()
		
		addProfileImageServiceObserver()
		updateAvatar()
	}
	
	// MARK: Profile Image
	
	private func addProfileImageView() {
		view.addSubview(profileImageView)
		
		NSLayoutConstraint.activate([
			profileImageView.widthAnchor.constraint(equalToConstant: 70),
			profileImageView.heightAnchor.constraint(equalToConstant: 70),
			profileImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
			profileImageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16)
		])
	}
	
	// MARK: Logout Button
	
	private func addLogoutButton() {
		view.addSubview(logoutButton)
		
		NSLayoutConstraint.activate([
			logoutButton.widthAnchor.constraint(equalToConstant: 44),
			logoutButton.heightAnchor.constraint(equalToConstant: 44),
			logoutButton.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor),
			logoutButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16)
		])
	}
	
	@objc private func logoutButtonTapped() {
		let alert = UIAlertController(
			title: "Пока, пока!",
			message: "Уверены что хотите выйти?",
			preferredStyle: .alert)
		let logoutAction = UIAlertAction(title: "Да", style: .default) { _ in
			self.logout()
		}
		let cancelAction = UIAlertAction(title: "Нет", style: .default)

		alert.addAction(logoutAction)
		alert.addAction(cancelAction)
		alert.preferredAction = cancelAction
		
		present(alert, animated: true)
	}
	
	private func logout() {
		OAuth2TokenStorage.removeToken()

		HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
		WKWebsiteDataStore.default().fetchDataRecords(
			ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
			records.forEach { record in
				WKWebsiteDataStore.default().removeData(
					ofTypes: record.dataTypes,
					for: [record],
					completionHandler: {})
			}
		}
		
		switchSplashViewController()
	}
	
	private func switchSplashViewController() {
		guard let window = UIApplication.shared.windows.first else {
			assertionFailure("Invalid Configuration")
			return;
		}
		
		let splashController = SplashViewController()
		
		window.rootViewController = splashController
	}
	
	// MARK: Name Label
	
	private func addNameLabel() {
		view.addSubview(nameLabel)
		
		NSLayoutConstraint.activate([
			nameLabel.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 8),
			nameLabel.leadingAnchor.constraint(equalTo: profileImageView.leadingAnchor),
			nameLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: 16)
		])
	}
	
	// MARK: Login Name Label
	
	private func addLoginNameLabel() {
		view.addSubview(loginNameLabel)
		
		NSLayoutConstraint.activate([
			loginNameLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
			loginNameLabel.leadingAnchor.constraint(equalTo: profileImageView.leadingAnchor),
			loginNameLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: 16)
		])
	}
	
	// MARK: Description Label
	
	private func addDescriptionLabel() {
		view.addSubview(descriptionLabel)
		
		NSLayoutConstraint.activate([
			descriptionLabel.topAnchor.constraint(equalTo: loginNameLabel.bottomAnchor, constant: 8),
			descriptionLabel.leadingAnchor.constraint(equalTo: profileImageView.leadingAnchor),
			descriptionLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: 16)
		])
	}
	
	private func addProfileImageServiceObserver() {
		profileImageServiceObserver = NotificationCenter.default
			.addObserver(
				forName: ProfileImageService.DidChangeNotification,
				object: nil,
				queue: .main
			) { [weak self] _ in
				guard let self = self else { return }
				self.updateAvatar()
			}
	}
	
	private func updateProfileDetails() {
		guard let profile = profileService.profile else { return }
		
		self.nameLabel.text = profile.name
		self.loginNameLabel.text = profile.loginName
		self.descriptionLabel.text = profile.bio
	}
	
	private func updateAvatar() {
		guard
			let profileImageURL = ProfileImageService.shared.avatarURL,
			let url = URL(string: profileImageURL)
		else { return }
		
		profileImageView.kf.setImage(with: url)
	}
}
