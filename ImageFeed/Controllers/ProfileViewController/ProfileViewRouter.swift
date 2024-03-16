//
//  ProfileViewRouter.swift
//  ImageFeed
//
//  Created by Artem Krasnov on 05.03.2024.
//

import UIKit

protocol ProfileViewRouterProtocol {
    var view: ProfileViewControllerProtocol? { get set }

    func logout()
}

final class ProfileViewRouter: ProfileViewRouterProtocol {

    // MARK: - Public Properties

    weak var view: ProfileViewControllerProtocol?

    // MARK: - Public Methods

    func logout() {
        OAuth2TokenStorage.shared.deleteToken()
        WebViewController.cleanCookie()
        guard let window = UIApplication.shared.windows.first else {
            fatalError("Invalid Configuration")
        }
        window.rootViewController = SplashViewController()
    }
}
