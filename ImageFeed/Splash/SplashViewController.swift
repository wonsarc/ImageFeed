//
//  SplashViewController.swift
//  ImageFeed
//
//  Created by Artem Krasnov on 20.01.2024.
//

import UIKit

private let ShowAuthenticationScreenSegueIdentifier = "ShowAuthenticationScreen"

final class SplashViewController: UIViewController {
    // MARK: - View Life Cycles
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        OAuth2TokenStorage().token == "" ? performSegue(withIdentifier: ShowAuthenticationScreenSegueIdentifier, sender: nil) : switchToTabBarController()
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
    func authViewController(_ vc: AuthViewController, didAuthenticateWithCode code: String) {
        OAuth2Service().fetchOAuthToken(code, completion: { [weak self] result in
            DispatchQueue.main.async {
                guard self != nil else { return }
            }
        })
        
        while(OAuth2TokenStorage().token == ""){
        }
        self.switchToTabBarController()
    }
}

extension SplashViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == ShowAuthenticationScreenSegueIdentifier {
            guard
                let navigationController = segue.destination as? UINavigationController,
                let viewController = navigationController.viewControllers[0] as? AuthViewController
            else { fatalError("Failed to prepare for \(ShowAuthenticationScreenSegueIdentifier)") }
            viewController.delegate = self
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
}
