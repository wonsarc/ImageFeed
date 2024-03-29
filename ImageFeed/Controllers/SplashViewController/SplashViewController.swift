//
//  SplashViewController.swift
//  ImageFeed
//
//  Created by Artem Krasnov on 20.01.2024.
//

import UIKit
import ProgressHUD

final class SplashViewController: UIViewController {

    // MARK: - Private Properties

    private let showAuthenticationScreenSegueIdentifier = "ShowAuthenticationScreen"
    private let profileService = ProfileService.shared
    private let profileImageService = ProfileImageService.shared
    private let oauth2Service = OAuth2Service.shared

    private lazy var logoImageView: UIImageView = {
        let logoImageView = UIImageView()
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        logoImageView.image = UIImage(named: "LogoOfUnsplash")
        return logoImageView
    }()

    // MARK: - Overrides Methods

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypBlack
        setupViews()
        setupConstraints()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard UIBlockingProgressHUD.isShowing == false else { return }
        let token = OAuth2TokenStorage.shared.token
        if token == "" {
            transitionToAuthViewController()
        } else {
            fetchProfile(token: token)
        }
    }

    // MARK: - Private Methods

    private func switchToTabBarController() {
        guard let window = UIApplication.shared.windows.first else { fatalError("Invalid Configuration") }
        let tabBarController = UIStoryboard(name: "Main", bundle: .main)
            .instantiateViewController(withIdentifier: "TabBarViewController")
        window.rootViewController = tabBarController
    }

    private func fetchProfile(token: String) {
        profileService.fetchProfile(token, completion: { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success:
                    UIBlockingProgressHUD.dismiss()
                    self.switchToTabBarController()
                case .failure:
                    self.showAlert()
                }
            }
        })

        profileImageService.fetchProfileImageURL(username: profileService
            .profile?.username ?? "", { [weak self] result in
                guard let self = self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success:
                    break
                case .failure:
                    self.showAlert()
                }
            }
        })
    }

    private func fetchOAuthToken(_ code: String) {
     oauth2Service.fetchOAuthToken(code) { [weak self] result in
         guard let self = self else { return }
         DispatchQueue.main.async {
             switch result {
             case .success(let token):
                 self.fetchProfile(token: token)
             case .failure:
                 self.showAlert()
             }
         }
     }
 }

    private func showAlert() {
        let alert = UIAlertController(
            title: NSLocalizedString("splash_alert.title", comment: ""),
            message: NSLocalizedString("splash_alert.message", comment: ""),
            preferredStyle: UIAlertController.Style.alert
        )

        let action = UIAlertAction(
            title: "OK", style: UIAlertAction.Style.default) { [weak self] (_) in
                guard let self = self else { return }
                self.transitionToAuthViewController()
        }
        alert.addAction(action)
        self.present(
            alert,
            animated: true,
            completion: {
                UIBlockingProgressHUD.dismiss()
            }
        )
    }
}

// MARK: - AuthViewControllerDelegate

extension SplashViewController: AuthViewControllerDelegate {
    func authViewController(_ viewController: AuthViewController, didAuthenticateWithCode code: String) {
        dismiss(animated: true) { [weak self] in
            guard let self = self else { return }
            self.fetchOAuthToken(code)
        }
    }
}

extension SplashViewController {
    func transitionToAuthViewController () {
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        let authViewController = storyboard
            .instantiateViewController(withIdentifier: "AuthViewController") as? AuthViewController
        guard let authViewController = authViewController else {return}
        authViewController.delegate = self
        authViewController.modalPresentationStyle = .fullScreen
        self.present(
            authViewController,
            animated: true,
            completion: nil)
    }
}

extension SplashViewController {
    private func setupViews() {
        view.addSubview(logoImageView)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            logoImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
}
