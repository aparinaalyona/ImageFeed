//
//  SplashViewController.swift
//  ImageFeed
//
//  Created by Алена Апарина on 10.11.2025.
//

import UIKit

final class SplashViewController: UIViewController {
    private let showAuthenticationScreenSegueIdentifier = "ShowAuthenticationScreen"

    private let profileService = ProfileService.shared
    private let storage = OAuth2TokenStorage.shared
    
    private var imageView: UIImageView!

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        view.backgroundColor = .ypBlack
        setupImageView()
        
        if let token = storage.token {
            fetchProfile(token: token)
        } else {
            presentAuthViewController()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNeedsStatusBarAppearanceUpdate()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }

    private func setupImageView() {
        let imageSplashScreenLogo = UIImage(resource: .splashScreenLogo)

        imageView = UIImageView(image: imageSplashScreenLogo)

        imageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(imageView)

        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func presentAuthViewController() {
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        guard let authViewController = storyboard.instantiateViewController(withIdentifier: "AuthViewController") as? AuthViewController else {
            assertionFailure("Не удалось найти AuthViewController по идентификатору")
            return
        }
        authViewController.delegate = self
        authViewController.modalPresentationStyle = .fullScreen
        present(authViewController, animated: true)
    }

    private func switchToTabBarController() {
        guard
            let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
            let window = windowScene.windows.first
        else {
            assertionFailure("Invalid window configuration")
            return
        }
        
        let tabBarController = UIStoryboard(name: "Main", bundle: .main)
            .instantiateViewController(withIdentifier: "TabBarController")
        window.rootViewController = tabBarController
        window.makeKeyAndVisible()
    }
    
    private func fetchProfile(token: String) {
        UIBlockingProgressHUD.show()
        profileService.fetchProfile(token) { [weak self] result in
            guard let self = self else { return }
            UIBlockingProgressHUD.dismiss()

            switch result {
            case .success(let profile):
                ProfileImageService.shared.fetchProfileImageURL(userName: profile.userName) { _ in
                    
                }
                DispatchQueue.main.async {
                    self.switchToTabBarController()
                }
            case .failure(let error):
                print("Ошибка загрузки профиля", error)
                break
            }
        }
    }
}

extension SplashViewController: AuthViewControllerDelegate {
    func didAuthenticate(_ vc: AuthViewController) {
        vc.dismiss(animated: true) { [weak self] in
            guard let self = self else { return }
            guard let token = self.storage.token else { return }
            DispatchQueue.main.async {
                self.fetchProfile(token: token)
                print("TOKEN IN STORAGE:", self.storage.token as Any)
            }
        }
    }
}
