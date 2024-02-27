//
//  ProfileViewTests.swift
//  ImageFeedTests
//
//  Created by Artem Krasnov on 26.02.2024.
//

@testable import ImageFeed
import XCTest

final class ProfileViewTests: XCTestCase {
    func testUpdateProfileDetails() {
        // given
        let viewController = ProfileViewControllerSpy()
        let presenter = ProfileViewPresenter()

        viewController.presenter = presenter
        presenter.view = viewController

        let newProfile = Profile(
            username: "testUserName",
            name: "testName",
            loginName: "testLoginName",
            bio: "testBio"
        )

        // when
        presenter.updateProfileDetails(profile: newProfile)

        // then
        XCTAssertEqual(viewController.nameLabel.text, newProfile.name)
        XCTAssertEqual(viewController.loginLabel.text, newProfile.loginName)
        XCTAssertEqual(viewController.descriptionLabel.text, newProfile.bio)
    }

    func testPresentLogoutAlert() {
        // Given
        let viewController = ProfileViewControllerSpy()
        let presenter = ProfileViewPresenter()
        presenter.view = viewController

        // When
        presenter.presentLogoutAlert()

        // Then
        XCTAssertTrue(viewController.presentCalled)
    }

    func testStartObservingProfileImageChanges() {
        // Given
        let presenter = ProfileViewPresenter()

        // When
        presenter.startObservingProfileImageChanges()

        // Then
        XCTAssertNotNil(presenter.profileImageServiceObserver)
    }
}
