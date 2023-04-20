//
//  ProfileViewController.swift
//  ImageFeed
//
//  Created by Джами on 03.02.2023.
//

import UIKit
import Kingfisher

protocol ProfileViewControllerProtocol: AnyObject {
    var presenter: ProfilePresenterProtocol? {get set}
    
    func updateAvatar()
    func didTapLogOutButton()
//    func alert(title: String, message: String)
    func alert(title: String, message: String, action: ((UIAlertAction) -> ())?)
    func configureViews()
    func setUpGradient()
    func configureConstraints()
    func updateProfileDetails(profile: Profile?)
    func updateRootViewControler()
    
}

final class ProfileViewController : UIViewController & ProfileViewControllerProtocol {
    
    var presenter: ProfilePresenterProtocol?
    private var profileImageServiceObserver: NSObjectProtocol?
    private var authToken = OAuth2TokenStorage.shared
    private let profileService = ProfileService.shared
    private let profileImage = UIImage(named: "avatar")
    
    private lazy var avatarImageView : UIImageView = {
        let imageView = UIImageView(image: profileImage)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var nameLabel : UILabel = {
        let nameLabel = UILabel()
        nameLabel.accessibilityIdentifier = "ProfileNameLabel"
        nameLabel.text = "Екатерина Новикова"
        nameLabel.textColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1.0)
        nameLabel.font = UIFont.boldSystemFont(ofSize: 23)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        return nameLabel
    }()
    
    private lazy var loginNameLabel : UILabel = {
        let loginNameLabel = UILabel()
        loginNameLabel.accessibilityIdentifier = "ProfileLoginNameLabel"
        loginNameLabel.text = "@ekaterina_nov"
        loginNameLabel.textColor = UIColor(red: 174/255, green: 175/255, blue: 180/255, alpha: 1.0)
        loginNameLabel.font = UIFont.systemFont(ofSize: 13)
        loginNameLabel.translatesAutoresizingMaskIntoConstraints = false
        return loginNameLabel
    }()
    
    private lazy var descriptionLabel : UILabel = {
        let descriptionLabel = UILabel()
        descriptionLabel.text = "Hello, world!"
        descriptionLabel.textColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1.0)
        descriptionLabel.font = UIFont.systemFont(ofSize: 13)
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        return descriptionLabel
    }()
    
    private lazy var logoutButton : UIButton = {
        let logoutButton = UIButton.systemButton(with: UIImage(systemName: "ipad.and.arrow.forward")!, target: self, action: #selector(self.didTapLogOutButton))
        logoutButton.accessibilityIdentifier = "ProfileExitButton"
        logoutButton.translatesAutoresizingMaskIntoConstraints = false
        logoutButton.tintColor = UIColor(red: 245/255, green: 107/255, blue: 108/255, alpha: 1.0)
        //logoutButton.addTarget(self, action: #selector(didTapLogOutButton), for: .touchUpInside)
        return logoutButton
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypBlack
        presenter?.viewDidLoad()
    }
    
    // MARK: - UpdateUI
    
     func updateAvatar() {
        guard
            let profileImageURL = ProfileImageService.shared.avatarURL,
            let url = URL(string: profileImageURL) else { return }
        let processor = RoundCornerImageProcessor(cornerRadius: 35)
        avatarImageView.kf.indicatorType = .activity
        avatarImageView.kf.setImage(with: url,
                                    placeholder: UIImage(named: "placeholder.jpeg"),
                                    options: [.processor(processor),.cacheSerializer(FormatIndicatedCacheSerializer.png)])
        let cache = ImageCache.default
        cache.clearDiskCache()
        cache.clearMemoryCache()
        
    }
    
     func configureViews() {
        view.addSubview(avatarImageView)
        view.addSubview(nameLabel)
        view.addSubview(loginNameLabel)
        view.addSubview(descriptionLabel)
        view.addSubview(logoutButton)
    }
    
     func configureConstraints() {
        NSLayoutConstraint.activate([
            avatarImageView.widthAnchor.constraint(equalToConstant: 70),
            avatarImageView.heightAnchor.constraint(equalToConstant: 70),
            avatarImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
            avatarImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            nameLabel.topAnchor.constraint(equalTo: avatarImageView.bottomAnchor, constant: 8),
            nameLabel.leadingAnchor.constraint(equalTo: avatarImageView.leadingAnchor),
            loginNameLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            loginNameLabel.leadingAnchor.constraint(equalTo: avatarImageView.leadingAnchor),
            descriptionLabel.topAnchor.constraint(equalTo: loginNameLabel.bottomAnchor, constant: 8),
            descriptionLabel.leadingAnchor.constraint(equalTo: avatarImageView.leadingAnchor),
            logoutButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -26),
            logoutButton.centerYAnchor.constraint(equalTo: avatarImageView.centerYAnchor)
        ])
    }
    
     func setUpGradient() {
        nameLabel.setUpGradient(frame: CGRect(x: 0, y: 0, width: 230, height: 30), cornerRadius: 15)
        loginNameLabel.setUpGradient(frame: CGRect(x: 0, y: 0, width: 150, height: 20), cornerRadius: 10)
        descriptionLabel.setUpGradient(frame: CGRect(x: 0, y: 0, width: 90, height: 20), cornerRadius: 10)
        avatarImageView.setUpGradient(frame: CGRect(x: 0, y: 0, width: 70, height: 70), cornerRadius: 35)
    }
    
     func removeGradient() {
        nameLabel.removeGradient()
        loginNameLabel.removeGradient()
        descriptionLabel.removeGradient()
        avatarImageView.removeGradient()
    }
    
     func updateProfileDetails(profile: Profile?) {
        guard let profile = profile else {return}
        self.nameLabel.text = profile.name
        self.loginNameLabel.text = profile.loginName
        self.descriptionLabel.text = profile.bio
        removeGradient()
    }
    
    @objc
     func didTapLogOutButton() {
         presenter?.logOut()
    }
    
    func alert(title: String, message: String, action: ((UIAlertAction) -> ())?) {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert)
        let action = UIAlertAction(title: "Да", style: .default, handler: action)
        let cancelAction = UIAlertAction(title: "Нет", style: .cancel, handler: nil)
        alert.addAction(action)
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    
//    func alert(title: String, message: String) {
//        let alert = UIAlertController(
//            title: title, //"Пока, пока!",
//            message: message,// "Уверены что хотите выйти?",
//            preferredStyle: .alert)
//        let action = UIAlertAction(title: "Закрыть", style: .default, handler: nil)
//        alert.addAction(action)
//        self.present(alert, animated: true, completion: nil)
//    }
    
}


//MARK: - Delegate Presenter
extension ProfileViewController {
    func updateRootViewControler() {
        guard let window = UIApplication.shared.windows.first else {fatalError("Invalid Configuration")}
        window.rootViewController = SplashViewController()
        window.makeKeyAndVisible()
    }
}
