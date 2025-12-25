//
//  ProfileViewController.swift
//  ImageFeed
//
//  Created by Алена Апарина on 16.10.2025.
//
import Kingfisher
import UIKit

protocol ProfilePresenterProtocol: AnyObject {
    var view: ProfileViewControllerProtocol? { get set }
    func viewDidLoad()
    func logout()
}
protocol ProfileViewControllerProtocol: AnyObject { }

final class ProfileViewController: UIViewController, ProfileViewControllerProtocol {
    private var presenter: ProfilePresenterProtocol!
    func configure(_ presenter: ProfilePresenterProtocol) {
        self.presenter = presenter
        presenter.view = self
    }
    private let tokenStorage = OAuth2TokenStorage.shared
    
    private var nameLabel: UILabel?
    private var loginNameLabel: UILabel?
    private var descriptionLabel: UILabel?
    private var avatarImageView: UIImageView?
    
    private var profileImageServiceObserver: NSObjectProtocol?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypBlack
        setupUI()
        presenter.viewDidLoad()

        if let profile = ProfileService.shared.profile {
            updateProfileDetails(profile: profile)
        }
        profileImageServiceObserver = NotificationCenter.default
            .addObserver(
                forName: ProfileImageService.didChangeNotification,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                guard let self = self else { return }
                self.updateAvatar()
            }
        updateAvatar()
    }
    
    private func updateAvatar() {
        guard
            let urlString = ProfileImageService.shared.avatarURL,
            let url = URL(string: urlString),
            let imageView = avatarImageView
        else { return }

        imageView.kf.setImage(with: url)
    }

    private func updateProfileDetails(profile: Profile) {
        nameLabel?.text = profile.name.isEmpty
            ? "Имя не указано"
            : profile.name
        loginNameLabel?.text = profile.loginName.isEmpty
            ? "@неизвестный_пользователь"
            : profile.loginName
        descriptionLabel?.text = (profile.bio?.isEmpty ?? true)
            ? "Профиль не заполнен"
            : profile.bio
    }

    private func logout() {
        OAuth2TokenStorage.shared.clearToken()

        HTTPCookieStorage.shared.removeCookies(since: .distantPast)

        guard let window = UIApplication.shared.windows.first else {
            assertionFailure("Ошибка: окно не найдено")
            return
        }

        let splashViewController = SplashViewController()
        window.rootViewController = splashViewController
        window.makeKeyAndVisible()

        UIView.transition(
            with: window,
            duration: 0.3,
            options: .transitionCrossDissolve,
            animations: nil
        )
    }

    private func setupUI() {
        let profileImage = UIImage(resource: .profile)
        
        let imageView = UIImageView(image: profileImage)
        imageView.layer.cornerRadius = 35
        imageView.clipsToBounds = true
        imageView.tintColor = .gray
        imageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(imageView)
        self.avatarImageView = imageView
        imageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20).isActive = true
        imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 70).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 70).isActive = true
        
        let nameLabel = UILabel()
        nameLabel.text = ""
        nameLabel.font = UIFont(name: "SFProText-Bold", size: 23)
        nameLabel.textColor = .white
        
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(nameLabel)
        nameLabel.leadingAnchor.constraint(equalTo: imageView.leadingAnchor).isActive = true
        nameLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 20).isActive = true
        self.nameLabel = nameLabel
        
        let loginNameLabel = UILabel()
        loginNameLabel.text = ""
        loginNameLabel.textColor = .ypGray
        loginNameLabel.font = UIFont(name: "SFProText-Regular", size: 13)
        
        loginNameLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(loginNameLabel)
        loginNameLabel.leadingAnchor.constraint(equalTo: imageView.leadingAnchor).isActive = true
        loginNameLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 5).isActive = true
        self.loginNameLabel = loginNameLabel
        
        let descriptionLabel = UILabel()
        descriptionLabel.text = ""
        descriptionLabel.font = UIFont(name: "SFProText-Regular", size: 13)
        descriptionLabel.textColor = .white
        
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(descriptionLabel)
        descriptionLabel.leadingAnchor.constraint(equalTo: imageView.leadingAnchor).isActive = true
        descriptionLabel.topAnchor.constraint(equalTo: loginNameLabel.bottomAnchor, constant: 5).isActive = true
        self.descriptionLabel = descriptionLabel
        
        let logoutButton = UIButton.systemButton(
            with: UIImage(resource: .exit),
            target: self,
            action: #selector(Self.didTapButton)
        )
        logoutButton.tintColor = UIColor(
            red: 0xF5/255.0,
            green: 0x6B/255.0,
            blue: 0x6C/255.0,
            alpha: 1.0
        )
        logoutButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(logoutButton)
        logoutButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20).isActive = true
        logoutButton.centerYAnchor.constraint(equalTo: imageView.centerYAnchor).isActive = true
        logoutButton.accessibilityIdentifier = "logoutButton"
    }
    
    @objc
    func didTapButton() {
        let alert = UIAlertController(
            title: "Пока-пока!",
            message: "Вы уверены, что хотите выйти?",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "НЕТ", style: .cancel))

        alert.addAction(UIAlertAction(title: "ДА", style: .destructive) { [weak self] _ in
            self?.logout()
        })

        present(alert, animated: true)
    }
}
