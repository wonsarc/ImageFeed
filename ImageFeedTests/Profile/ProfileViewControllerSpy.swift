//
//  ProfileViewControllerSpy.swift
//  ImageFeedTests
//
//  Created by Artem Krasnov on 26.02.2024.
//

@testable import ImageFeed
import UIKit

final class ProfileViewControllerSpy: UIViewController, ProfileViewControllerProtocol {
    var presenter: ImageFeed.ProfileViewPresenterProtocol?
    var presentCalled = false
    var logoImageView: UIImageView = UIImageView()
    var nameLabel: UILabel = UILabel()
    var loginLabel: UILabel = UILabel()
    var descriptionLabel: UILabel = UILabel()
    var animationLayers: Set<CALayer> = []

    override func present(_ viewControllerToPresent: UIViewController, animated: Bool, completion: (() -> Void)?) {
        presentCalled = true
    }

    func updateProfileDetails(profile: ImageFeed.Profile) {
    }
}
