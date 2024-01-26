//
//  SplashViewController.swift
//  ImageFeed
//
//  Created by Artem Krasnov on 20.01.2024.
//

import UIKit
import ProgressHUD

private let showAuthenticationScreenSegueIdentifier = "ShowAuthenticationScreen"

final class SplashViewController: UIViewController {
    private let profileService = ProfileService.shared

    // MARK: - View Life Cycles
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let token = OAuth2TokenStorage.shared.token
        if token == "" {
            performSegue(withIdentifier: showAuthenticationScreenSegueIdentifier, sender: nil)
        } else {
            fetchProfile(token: token)
        }
    }

    // MARK: - Private Func
    private func switchToTabBarController() {
        guard let window = UIApplication.shared.windows.first else { fatalError("Invalid Configuration") }
        let tabBarController = UIStoryboard(name: "Main", bundle: .main)
            .instantiateViewController(withIdentifier: "TabBarViewController")
        window.rootViewController = tabBarController
    }

    private func fetchProfile(token: String) {
        profileService.fetchProfile(token, completion: { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(_):
                    UIBlockingProgressHUD.dismiss()
                    self?.switchToTabBarController()
                case .failure(_):
                    UIBlockingProgressHUD.dismiss()
                }
            }
        })
    }
}

// MARK: - Extension
extension SplashViewController: AuthViewControllerDelegate {
    func authViewController(_ viewController: AuthViewController, didAuthenticateWithCode code: String) {
        UIBlockingProgressHUD.animate()
        OAuth2Service().fetchOAuthToken(code, completion: { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let token):
                    self?.fetchProfile(token: token)
                case .failure(let error):
                    print(error)
                }
            }
        })
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
