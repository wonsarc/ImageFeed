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
