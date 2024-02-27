//
//  ProfileViewPresenterSpy.swift
//  ImageFeedTests
//
//  Created by Artem Krasnov on 26.02.2024.
//

@testable import ImageFeed
import Foundation

final class ProfileViewPresenterSpy {
    var view: ImageFeed.ProfileViewControllerProtocol?
    var didCallUpdateAvatar: Bool = false

    func showAlert() {

    }

    func updateAvatar() {
        didCallUpdateAvatar = true
    }

    func updateProfileDetails(profile: ImageFeed.Profile) {

    }

    func startObservingProfileImageChanges() {

    }

    func setupGradientAnimation() {

    }

}
