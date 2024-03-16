//
//  ProfileService.swift
//  ImageFeed
//
//  Created by Artem Krasnov on 24.01.2024.
//

import UIKit

protocol ProfileServiceProtocol {
    func setupGradientAnimation(view: ProfileViewControllerProtocol)
    func createLogoutAlert(completion: @escaping () -> Void) -> UIAlertController
    func fetchProfile(_ token: String, completion: @escaping (Result<Profile, Error>) -> Void)
}

final class ProfileService: ProfileServiceProtocol {
    private let profileMeURL = URL(string: "\(AuthConfiguration.standard.defaultBaseURL)/me")!
    static let shared = ProfileService()

    private var lastToken: String?
    private var task: URLSessionTask?
    private let urlSession = URLSession.shared
    private(set) var profile: Profile?

//    private init() { }

    func fetchProfile(_ token: String, completion: @escaping (Result<Profile, Error>) -> Void) {
        assert(Thread.isMainThread)
        if lastToken == token {return}
        task?.cancel()
        lastToken = token

        let request = NetworkClient().createRequestWithBearerAuth(
            url: profileMeURL,
            httpMethod: .GET,
            token: token
        )

        task = urlSession.objectTask(for: request,
                                     completion: { [weak self] (result: Result<ProfileResult,
                                                                Error>) in
            guard let self = self else { return }
            switch result {
            case .success(let body):
                let currentProfile = Profile(
                    username: body.username,
                    name: "\(body.firstName ?? "") \(body.lastName ?? "")",
                    loginName: "@\(body.username ?? "")",
                    bio: body.bio
                )
                self.profile = currentProfile
                completion(.success(currentProfile))
            case .failure(let error):
                completion(.failure(error))
            }
        })
        task?.resume()
    }

    func setupGradientAnimation(view: ProfileViewControllerProtocol) {
        let gradientAnimationHelper = GradientAnimationHelper()
        let animation = gradientAnimationHelper.animation

        let logoImageViewGradient = gradientAnimationHelper.addGradient(
            size: CGSize(width: 70, height: 70),
            cornerRadius: 35,
            view: view.logoImageView
        )
        logoImageViewGradient.add(animation, forKey: "locationsChange")
        view.animationLayers.insert(logoImageViewGradient)

        let nameLabelGradient = gradientAnimationHelper.addGradient(
            size: CGSize(width: 250, height: 18),
            cornerRadius: 10,
            view: view.nameLabel
        )
        nameLabelGradient.add(animation, forKey: "locationsChange")
        view.animationLayers.insert(nameLabelGradient)

        let loginLabelGradient = gradientAnimationHelper.addGradient(
            size: CGSize(width: 200, height: 18),
            cornerRadius: 10,
            view: view.loginLabel
        )
        loginLabelGradient.add(animation, forKey: "locationsChange")
        view.animationLayers.insert(loginLabelGradient)

        let descriptionLabelGradient = gradientAnimationHelper.addGradient(
            size: CGSize(width: 150, height: 18),
            cornerRadius: 10,
            view: view.descriptionLabel
        )
        descriptionLabelGradient.add(animation, forKey: "locationsChange")
        view.animationLayers.insert(descriptionLabelGradient)
    }

    func createLogoutAlert(completion: @escaping () -> Void) -> UIAlertController {
        let logoutConfirmationAlert = UIAlertController(
            title: NSLocalizedString("profile_alert.title", comment: ""),
            message: NSLocalizedString("profile_alert.message", comment: ""),
            preferredStyle: .alert
        )

        let confirmAction = UIAlertAction(
            title: NSLocalizedString("profile_alert.action", comment: ""),
            style: .default) { _ in
                completion()
            }
        let cancelAction = UIAlertAction(
            title: NSLocalizedString("profile_alert.cancel", comment: ""),
            style: .cancel)

        logoutConfirmationAlert.addAction(confirmAction)
        logoutConfirmationAlert.addAction(cancelAction)

        return logoutConfirmationAlert
    }
}
