//
//  ProfileViewController.swift
//  ImageFeed
//
//  Created by Artem Krasnov on 22.10.2023.
//

import UIKit
import Kingfisher

final class ProfileViewController: UIViewController {
    private var profileImageServiceObserver: NSObjectProtocol?

    // MARK: - View Life Cycles
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        logoImageView.layer.cornerRadius = logoImageView.frame.size.width / 2
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypBlack
        setupViews()
        setupConstraints()

        if let profile = ProfileService.shared.profile {
            updateProfileDetails(profile: profile)
        }

        profileImageServiceObserver = NotificationCenter.default
            .addObserver(
                forName: ProfileImageService.didChangeNotification,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                guard let self = self else {return}
                self.updateAvatar()
            }
        updateAvatar()
    }

    // MARK: - Private Properties
    private lazy var logoImageView: UIImageView = {
        let logoImageView = UIImageView()
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        logoImageView.clipsToBounds = true
        return logoImageView
    }()

    private lazy var nameLabel: UILabel = {
        let nameLabel = UILabel()
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.textColor = .ypWhite
        nameLabel.font = .boldSystemFont(ofSize: 23)
        return nameLabel
    }()

    private lazy var loginLabel: UILabel = {
        let loginLabel = UILabel()
        loginLabel.translatesAutoresizingMaskIntoConstraints = false
        loginLabel.textColor = .ypGray
        loginLabel.font = .systemFont(ofSize: 13)
        return loginLabel
    }()

    private lazy var descriptionLabel: UILabel = {
        let descriptionLabel = UILabel()
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.textColor = .ypWhite
        descriptionLabel.numberOfLines = 0
        descriptionLabel.font = .systemFont(ofSize: 13)
        return descriptionLabel
    }()

    private lazy var logoutButton: UIButton = {
        let logoutButton = UIButton.systemButton(
            with: UIImage(named: "LogOut") ?? UIImage(),
            target: self,
            action: #selector(didTapLogoutButton)
        )
        logoutButton.translatesAutoresizingMaskIntoConstraints = false
        logoutButton.tintColor = .ypRed
        return logoutButton
    }()

    // MARK: - Private Func
    private func setupViews() {
        view.addSubview(logoImageView)
        view.addSubview(nameLabel)
        view.addSubview(loginLabel)
        view.addSubview(descriptionLabel)
        view.addSubview(logoutButton)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            logoImageView.widthAnchor.constraint(equalToConstant: 70),
            logoImageView.heightAnchor.constraint(equalToConstant: 70),
            logoImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            logoImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),

            logoutButton.widthAnchor.constraint(equalToConstant: 48),
            logoutButton.heightAnchor.constraint(equalToConstant: 48),
            logoutButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -18),
            logoutButton.centerYAnchor.constraint(equalTo: logoImageView.centerYAnchor),

            nameLabel.widthAnchor.constraint(equalToConstant: 700),
            nameLabel.heightAnchor.constraint(equalToConstant: 18),
            nameLabel.topAnchor.constraint(equalTo: logoImageView.bottomAnchor, constant: 8),
            nameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            nameLabel.trailingAnchor.constraint(equalTo: logoutButton.leadingAnchor),

            loginLabel.widthAnchor.constraint(equalToConstant: 400),
            loginLabel.heightAnchor.constraint(equalToConstant: 18),
            loginLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            loginLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            loginLabel.trailingAnchor.constraint(equalTo: logoutButton.leadingAnchor),

            descriptionLabel.widthAnchor.constraint(equalToConstant: 400),
            descriptionLabel.heightAnchor.constraint(equalToConstant: 18),
            descriptionLabel.topAnchor.constraint(equalTo: loginLabel.bottomAnchor, constant: 8),
            descriptionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            descriptionLabel.trailingAnchor.constraint(equalTo: logoutButton.leadingAnchor)
        ])

    }

    private func updateProfileDetails (profile: Profile) {
        nameLabel.text = profile.name
        loginLabel.text = profile.loginName
        descriptionLabel.text = profile.bio
    }

    private func updateAvatar() {
        guard
            let profileImageURL = ProfileImageService.shared.avatarURL,
            let url = URL(string: profileImageURL)
        else { return }
        self.logoImageView.kf.setImage(
            with: url,
            placeholder: UIImage(named: "User")
        )
    }

    @objc
    private func didTapLogoutButton() {
        showAlert()
    }

    private func showAlert() {
        let alert = UIAlertController(
            title: "Пока, Пока!",
            message: "Уверены что хотите выйти?",
            preferredStyle: UIAlertController.Style.alert
        )
        let actionYes = UIAlertAction(
            title: "Да", style: UIAlertAction.Style.default) { [weak self] (_) in
                guard let self = self else { return }
                OAuth2TokenStorage.shared.deleteToken()
                WebViewController.cleanCookie()
                guard let window = UIApplication.shared.windows.first else { fatalError("Invalid Configuration") }
                window.rootViewController = SplashViewController()
        }
        let actionNo = UIAlertAction(
            title: "Нет", style: UIAlertAction.Style.default)

        alert.addAction(actionYes)
        alert.addAction(actionNo)
        self.present(
            alert,
            animated: true,
            completion: {
                UIBlockingProgressHUD.dismiss()
            }
        )
    }
}
