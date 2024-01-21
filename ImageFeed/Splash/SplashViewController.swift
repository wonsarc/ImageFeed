//
//  SplashViewController.swift
//  ImageFeed
//
//  Created by Artem Krasnov on 20.01.2024.
//

import UIKit

private let showAuthenticationScreenSegueIdentifier = "ShowAuthenticationScreen"

final class SplashViewController: UIViewController {
    // MARK: - View Life Cycles
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if OAuth2TokenStorage().token == "" {
            performSegue(withIdentifier: showAuthenticationScreenSegueIdentifier, sender: nil)
        } else {
            switchToTabBarController()
        }
    }

    // MARK: - Private Func
    private func switchToTabBarController() {
        guard let window = UIApplication.shared.windows.first else { fatalError("Invalid Configuration") }
        let tabBarController = UIStoryboard(name: "Main", bundle: .main)
            .instantiateViewController(withIdentifier: "TabBarViewController")
        window.rootViewController = tabBarController
    }
}

// MARK: - Extension
extension SplashViewController: AuthViewControllerDelegate {
    func authViewController(_ viewController: AuthViewController, didAuthenticateWithCode code: String) {
        OAuth2Service().fetchOAuthToken(code, completion: { [weak self] _ in
            DispatchQueue.main.async {
                guard self != nil else { return }
            }
        })
        while(OAuth2TokenStorage().token == "") {
        }
        self.switchToTabBarController()
    }
}

extension SplashViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showAuthenticationScreenSegueIdentifier {
            guard
                let navigationController = segue.destination as? UINavigationController,
                let viewController = navigationController.viewControllers[0] as? AuthViewController
            else { fatalError("Failed to prepare for \(showAuthenticationScreenSegueIdentifier)") }
            viewController.delegate = self
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
}
