import UIKit

final class ProfileViewController : UIViewController {
	// MARK: Private properties
	
	private var profileImageView: UIImageView?
	private var logoutButton: UIButton?
	private var nameLabel: UILabel?
	private var loginNameLabel: UILabel?
	private var descriptionLabel: UILabel?
	
	// MARK: Lifecycle
	
	override func viewDidLoad() {
		super.viewDidLoad()

		addProfileImageView()
		addLogoutButton()
		addNameLabel()
		addLoginNameLabel()
		addDescriptionLabel()
	}
	
	// MARK: Profile Image
	
	private func addProfileImageView() {
		let profileImage = UIImage(named: "EmptyProfileImage")
		profileImageView = UIImageView(image: profileImage)
		
		guard let profileImageView else { return }
		
		profileImageView.translatesAutoresizingMaskIntoConstraints = false
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
		guard let profileImageView else { return }

		let logoutImage = UIImage(named: "LogoutImage")
		
		guard let logoutImage else { return }
		
		logoutButton = UIButton.systemButton(
			with: logoutImage,
			target: self,
			action: #selector(logoutButtonTapped))
		
		guard let logoutButton else { return }
		
		logoutButton.translatesAutoresizingMaskIntoConstraints = false
		logoutButton.tintColor = .ypRed
		
		view.addSubview(logoutButton)
		
		NSLayoutConstraint.activate([
			logoutButton.widthAnchor.constraint(equalToConstant: 44),
			logoutButton.heightAnchor.constraint(equalToConstant: 44),
			logoutButton.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor),
			logoutButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16)
		])
	}
	
	@objc private func logoutButtonTapped() {
		
	}
	
	// MARK: Name Label
	
	private func addNameLabel() {
		guard let profileImageView else { return }
		
		nameLabel = UILabel()
		
		guard let nameLabel else { return }
		
		nameLabel.translatesAutoresizingMaskIntoConstraints = false
		nameLabel.text = "Имя пользователя"
		nameLabel.font = .systemFont(ofSize: 23, weight: .semibold)
		nameLabel.textColor = .ypWhite
		
		view.addSubview(nameLabel)
		
		NSLayoutConstraint.activate([
			nameLabel.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 8),
			nameLabel.leadingAnchor.constraint(equalTo: profileImageView.leadingAnchor),
			nameLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: 16)
		])
	}
	
	// MARK: Login Name Label
	
	private func addLoginNameLabel() {
		guard let profileImageView,
			  let nameLabel else { return }
		
		loginNameLabel = UILabel()
		
		guard let loginNameLabel else { return }
		
		loginNameLabel.translatesAutoresizingMaskIntoConstraints = false
		loginNameLabel.text = "@username"
		loginNameLabel.font = .systemFont(ofSize: 13, weight: .regular)
		loginNameLabel.textColor = .ypGray
		
		view.addSubview(loginNameLabel)
		
		NSLayoutConstraint.activate([
			loginNameLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
			loginNameLabel.leadingAnchor.constraint(equalTo: profileImageView.leadingAnchor),
			loginNameLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: 16)
		])
	}
	
	// MARK: Description Label
	
	private func addDescriptionLabel() {
		guard let profileImageView,
			  let loginNameLabel else { return }
		
		descriptionLabel = UILabel()
		
		guard let descriptionLabel else { return }
		
		descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
		descriptionLabel.text = "Hello, Wordl!"
		descriptionLabel.font = .systemFont(ofSize: 13, weight: .regular)
		descriptionLabel.textColor = .ypWhite
		
		view.addSubview(descriptionLabel)
		
		NSLayoutConstraint.activate([
			descriptionLabel.topAnchor.constraint(equalTo: loginNameLabel.bottomAnchor, constant: 8),
			descriptionLabel.leadingAnchor.constraint(equalTo: profileImageView.leadingAnchor),
			descriptionLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: 16)
		])
	}
}
