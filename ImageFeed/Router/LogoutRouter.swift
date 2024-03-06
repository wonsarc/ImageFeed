//
//  LogoutRouter.swift
//  ImageFeed
//
//  Created by Artem Krasnov on 05.03.2024.
//

import UIKit

protocol LogoutRouterProtocol {
    var view: ProfileViewControllerProtocol? { get set }
    func logout()
}

final class LogoutRouter: LogoutRouterProtocol {
    weak var view: ProfileViewControllerProtocol?

    func logout() {
        OAuth2TokenStorage.shared.deleteToken()
        WebViewController.cleanCookie()
        guard let window = UIApplication.shared.windows.first else {
            fatalError("Invalid Configuration")
        }
        window.rootViewController = SplashViewController()
    }
}
