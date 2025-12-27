//
//  TabBarController.swift
//  ImageFeed
//
//  Created by Алена Апарина on 30.11.2025.
//
import UIKit

final class TabBarController: UITabBarController {

    // MARK: - Lifecycle

    override func awakeFromNib() {
        super.awakeFromNib()
        setupViewControllers()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureTabBarAppearance()
    }


    // MARK: - Setup View Controllers

    private func setupViewControllers() {
        let storyboard = UIStoryboard(name: "Main", bundle: .main)

        let imagesListViewController = storyboard.instantiateViewController(
            withIdentifier: "ImagesListViewController"
        )

        let profileViewController = ProfileModuleBuilder.build()
        profileViewController.tabBarItem = UITabBarItem(
            title: "",
            image: UIImage(named: "tab_profile_active"),
            selectedImage: nil
        )

        viewControllers = [
            imagesListViewController,
            profileViewController
        ]
    }


    // MARK: - Tab Bar Appearance

    private func configureTabBarAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.ypBlack
        appearance.shadowColor = .clear

        tabBar.standardAppearance = appearance
        tabBar.scrollEdgeAppearance = appearance
    }
}

