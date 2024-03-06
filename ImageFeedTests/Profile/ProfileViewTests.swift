//
//  ProfileViewTests.swift
//  ImageFeedTests
//
//  Created by Artem Krasnov on 26.02.2024.
//

@testable import ImageFeed
import XCTest

final class ProfileViewTests: XCTestCase {
    func testPresentLogoutAlert() {
        // given
        let router = RouterSpy()
        let presenter = ProfileViewPresenter()
        presenter.router = router

        // when
        presenter.didLogout()

        // then
        XCTAssertTrue(router.didCallLogout)
    }

    func testStartObservingProfileImageChanges() {
        // given
        let presenter = ProfileViewPresenter()

        // when
        presenter.startObservingProfileImageChanges()

        // then
        XCTAssertNotNil(presenter.profileImageServiceObserver)
    }

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
        XCTAssertNotNil(viewController.nameLabel.text)
        XCTAssertNotNil(viewController.loginLabel.text)
        XCTAssertNotNil(viewController.descriptionLabel.text)
    }
}
