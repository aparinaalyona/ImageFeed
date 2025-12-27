//
//  ProfileModuleBuilder.swift
//  ImageFeed
//
//  Created by Алена Апарина on 27.12.2025.
//
import UIKit

final class ProfileModuleBuilder {
    static func build() -> UIViewController {
        let presenter = ProfilePresenter()
        let viewController = ProfileViewController()
        viewController.configure(presenter)
        return viewController
    }
}

