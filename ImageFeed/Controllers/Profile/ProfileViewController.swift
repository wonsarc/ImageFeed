//
//  ProfileViewController.swift
//  ImageFeed
//
//  Created by Artem Krasnov on 22.10.2023.
//

import UIKit
import Kingfisher

protocol ProfileViewControllerProtocol: AnyObject {
    var presenter: ProfileViewPresenterProtocol? { get set }
    var logoImageView: UIImageView { get set }
    var nameLabel: UILabel { get set }
    var loginLabel: UILabel { get set }
    var descriptionLabel: UILabel { get set }
    var animationLayers: Set<CALayer> { get set }
    func present(_ viewControllerToPresent: UIViewController, animated: Bool, completion: (() -> Void)?)
    func updateProfileDetails(profile: Profile)
    func updateAvatar()
}

final class ProfileViewController: UIViewController, ProfileViewControllerProtocol {
    var presenter: ProfileViewPresenterProtocol?
    var animationLayers = Set<CALayer>()

    // MARK: - View Life Cycles
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        logoImageView.layer.cornerRadius = logoImageView.frame.size.width / 2
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        let profileViewPresenter = ProfileViewPresenter()
        self.presenter = profileViewPresenter
        profileViewPresenter.view = self

        view.backgroundColor = .ypBlack
        setupViews()
        setupConstraints()
        presenter?.setupGradientAnimation()

        if let profile = ProfileService.shared.profile {
            updateProfileDetails(profile: profile)
        }

        presenter?.startObservingProfileImageChanges()
        animationLayers.forEach { $0.removeFromSuperlayer() }
        updateAvatar()
    }

    // MARK: - Private Properties
    lazy var logoImageView: UIImageView = {
        let logoImageView = UIImageView()
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        logoImageView.clipsToBounds = true
        return logoImageView
    }()

    lazy var nameLabel: UILabel = {
        let nameLabel = UILabel()
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.textColor = .ypWhite
        nameLabel.font = .boldSystemFont(ofSize: 23)
        return nameLabel
    }()

    lazy var loginLabel: UILabel = {
        let loginLabel = UILabel()
        loginLabel.translatesAutoresizingMaskIntoConstraints = false
        loginLabel.textColor = .ypGray
        loginLabel.font = .systemFont(ofSize: 13)
        return loginLabel
    }()

    lazy var descriptionLabel: UILabel = {
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
        logoutButton.accessibilityIdentifier = "LogoutButton"
        logoutButton.tintColor = .ypRed
        return logoutButton
    }()

    // MARK: - Public Func
    func updateProfileDetails(profile: Profile) {
        nameLabel.text = profile.name
        loginLabel.text = profile.loginName
        descriptionLabel.text = profile.bio
    }

    func updateAvatar() {
        guard
            let avatarURL = ProfileImageService.shared.avatarURL
        else { return }

        ImageLoader().loadImage(on: avatarURL, completion: { result in
            switch result {
            case.success(let image):
                self.logoImageView.image = image
            case .failure(let error):
                print("Ошибка при загрузке изображения: \(error)")
            }
        })
    }

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

    @objc
    private func didTapLogoutButton() {
        let alert = ProfileHelper().createLogoutAlert {
            self.presenter?.didLogout()
        }
        present(alert, animated: true, completion: nil)
    }
}
