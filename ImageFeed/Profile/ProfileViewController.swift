import UIKit
import WebKit
import Kingfisher
import SwiftKeychainWrapper

protocol ProfileViewControllerProtocol: AnyObject {
	var presenter: ProfileViewPresenterProtocol? { get set }
	func updateAvatar()
}

final class ProfileViewController : UIViewController, ProfileViewControllerProtocol {
	var profileService = ProfileService.shared
	var presenter: ProfileViewPresenterProtocol?
	
	// MARK: Private view properties
	
	lazy var profileImageView: UIImageView = {
		let profileImage = UIImage(named: "EmptyProfileImage")
		let profileImageView = UIImageView(image: profileImage)

		profileImageView.translatesAutoresizingMaskIntoConstraints = false

		return profileImageView
	}()

	lazy var logoutButton: UIButton = {
		let logoutImage = UIImage(named: "LogoutImage")
		
		let logoutButton = UIButton.systemButton(
			with: logoutImage ?? UIImage(),
			target: self,
			action: #selector(logoutButtonTapped))

		logoutButton.translatesAutoresizingMaskIntoConstraints = false
		logoutButton.tintColor = .ypRed
		logoutButton.accessibilityIdentifier = "LogoutButton"
		
		return logoutButton
	}()

	lazy var nameLabel: UILabel = {
		let nameLabel = UILabel()

		nameLabel.translatesAutoresizingMaskIntoConstraints = false
		nameLabel.text = "Имя пользователя"
		nameLabel.font = .systemFont(ofSize: 23, weight: .bold)
		nameLabel.textColor = .ypWhite
		
		return nameLabel
	}()

	lazy var loginNameLabel: UILabel = {
		let loginNameLabel = UILabel()

		loginNameLabel.translatesAutoresizingMaskIntoConstraints = false
		loginNameLabel.text = "@username"
		loginNameLabel.font = .systemFont(ofSize: 13, weight: .regular)
		loginNameLabel.textColor = .ypGray
		
		return loginNameLabel
	}()

	lazy var descriptionLabel: UILabel = {
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
		
		presenter?.viewDidLoad()
		view.backgroundColor = .ypBlack
		
		addProfileImageView()
		addLogoutButton()
		addNameLabel()
		addLoginNameLabel()
		addDescriptionLabel()
		updateProfileDetails()
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
			self.presenter?.logout()
		}
		let cancelAction = UIAlertAction(title: "Нет", style: .default)

		alert.addAction(logoutAction)
		alert.addAction(cancelAction)
		alert.preferredAction = cancelAction
		
		present(alert, animated: true)
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
	
	private func updateProfileDetails() {
		guard let profile = profileService.profile else { return }
		
		self.nameLabel.text = profile.name
		self.loginNameLabel.text = profile.loginName
		self.descriptionLabel.text = profile.bio
	}
	
	func updateAvatar() {
		guard
			let profileImageURL = ProfileImageService.shared.avatarURL,
			let url = URL(string: profileImageURL)
		else { return }
		
		profileImageView.kf.setImage(with: url)
	}
}
