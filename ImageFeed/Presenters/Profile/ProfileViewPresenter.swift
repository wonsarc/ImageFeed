//
//  ProfileViewPresenter.swift
//  ImageFeed
//
//  Created by Artem Krasnov on 26.02.2024.
//

import UIKit

protocol ProfileViewPresenterProtocol {
    var view: ProfileViewControllerProtocol? {get set}
    func logout()
    func updateAvatar()
    func updateProfileDetails(profile: Profile)
    func startObservingProfileImageChanges()
    func setupGradientAnimation()
}

final class ProfileViewPresenter: ProfileViewPresenterProtocol {
    weak var view: ProfileViewControllerProtocol?
    var profileImageServiceObserver: NSObjectProtocol?

    func updateAvatar() {
         guard
             let view = view,
             let avatarURL = ProfileImageService.shared.avatarURL,
             let url = URL(string: avatarURL)
         else { return }

         view.logoImageView.kf.setImage(
             with: url,
             placeholder: UIImage(named: "User")
         )
     }

    func updateProfileDetails(profile: Profile) {
        guard let view = view else { return }
        view.nameLabel.text = profile.name
        view.loginLabel.text = profile.loginName
        view.descriptionLabel.text = profile.bio
    }

    func setupGradientAnimation() {
        guard let view = view else { return }
        ProfileHelper().setupGradientAnimation(view: view)
    }

    func startObservingProfileImageChanges() {
        profileImageServiceObserver = NotificationCenter.default
            .addObserver(
                forName: ProfileImageService.didChangeNotification,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                guard let self = self else {return}
                updateAvatar()
            }
    }

    func logout() {
        OAuth2TokenStorage.shared.deleteToken()
        WebViewController.cleanCookie()
        guard let window = UIApplication.shared.windows.first else {
            fatalError("Invalid Configuration")
        }
        window.rootViewController = SplashViewController()
    }
}
