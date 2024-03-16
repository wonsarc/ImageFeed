//
//  ProfileViewPresenter.swift
//  ImageFeed
//
//  Created by Artem Krasnov on 26.02.2024.
//

import Foundation

protocol ProfileViewPresenterProtocol {
    var view: ProfileViewControllerProtocol? {get set}

    func startObservingProfileImageChanges()
    func setupGradientAnimation()
    func didLogout()
    func downloadAvatar(_ avatarURL: String, completion: @escaping ResultImageError)
}

final class ProfileViewPresenter: ProfileViewPresenterProtocol {

    // MARK: - Public Properties

    weak var view: ProfileViewControllerProtocol?
    var profileImageServiceObserver: NSObjectProtocol?
    var router: ProfileViewRouterProtocol = ProfileViewRouter()

    // MARK: - Public Methods

    func setupGradientAnimation() {
        guard let view = view else { return }
        ProfileService().setupGradientAnimation(view: view)
    }

    func startObservingProfileImageChanges() {
        profileImageServiceObserver = NotificationCenter.default
            .addObserver(
                forName: ProfileImageService.didChangeNotification,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                guard let self = self else {return}
                view?.updateAvatar()
            }
    }

    func didLogout() {
        router.logout()
    }

    func downloadAvatar(_ avatarURL: String, completion: @escaping ResultImageError) {
        ImageDownloadService().downloadImage(on: avatarURL, completion: completion)
    }
}
