//
//  ImageFeedUITests.swift
//  ImageFeedUITests
//
//  Created by Artem Krasnov on 03.03.2024.
//

import XCTest

final class ImageFeedUITests: XCTestCase {
    private let app = XCUIApplication()

    override func setUp() {
        super.setUp()
        app.launchArguments.append("testMode")
        continueAfterFailure = false
    }

    private func launch() {
        app.launch()
    }

    private func launchWithReset() {
        app.launchArguments.append("--Reset")
        app.launch()
    }

    func testAuth() throws {
        launchWithReset()

        let testEmail = "use test e-mail"
        let testPassword = "use test password"

        // click authenticate button
        app.buttons["Authenticate"].tap()

        // check isUnsplashWebView
        let webView = app.webViews["UnsplashWebView"]
        XCTAssertTrue(webView.waitForExistence(timeout: 5))

        // input text login
        let loginTextField = webView.descendants(matching: .textField).element
        XCTAssertTrue(loginTextField.waitForExistence(timeout: 5))

        loginTextField.tap()
        loginTextField.typeText(testEmail)

        // input text password
        let passwordTextField = webView.descendants(matching: .secureTextField).element
        XCTAssertTrue(loginTextField.waitForExistence(timeout: 5))

        passwordTextField.tap()
        passwordTextField.typeText(testPassword)

        // click web login
        let loginButton = webView.buttons["Login"]
        loginButton.tap()

        // check success authorize
        let tablesQuery = app.tables
        let cell = tablesQuery.children(matching: .cell).element(boundBy: 0)

        XCTAssertTrue(
            cell.waitForExistence(timeout: 5),
            "The first table cell did not appear within 5 seconds"
        )
    }

    func testFeed() throws {
        launch()

        // find cell
        let tableView = app.tables
        let hud = app.windows["UIBlockingProgressHUD"]
        let cell = tableView.descendants(matching: .cell).element(boundBy: 0)
        cell.swipeUp()

        // click like button and wait hidden hud
        let cellToLike = tableView.descendants(matching: .cell).element(boundBy: 1)

        cellToLike.buttons["LikeButton"].tap()
        waitForHUDToDisappear(hud)

        cellToLike.buttons["LikeButton"].tap()
        waitForHUDToDisappear(hud)

        // click cell n and wait hidden hud
        cell.tap()
        waitForHUDToDisappear(hud)

        // zoom image
        let image = app.scrollViews.images.element(boundBy: 0)
        image.pinch(withScale: 3, velocity: 1)
        image.pinch(withScale: 0.5, velocity: -1)

        // click back button
        app.buttons["BackButton"].tap()

        // check return to image feed
        XCTAssertTrue(
            cell.waitForExistence(timeout: 5),
            "The first table cell did not appear within 5 seconds"
        )
    }

    func testProfile() throws {
        launch()

        let expectedName = "Artem Krasnov"
        let expectedLogin = "@wonsarc"
        let expectedBio = "test"

        // go to profile page
        app.tabBars.buttons.element(boundBy: 1).tap()

        // check name
        XCTAssertTrue(
            app.staticTexts[expectedName].waitForExistence(timeout: 5),
            "The name did not appear within 5 seconds"
        )

        // check login
        XCTAssertTrue(
            app.staticTexts[expectedLogin].waitForExistence(timeout: 5),
            "The login did not appear within 5 seconds"
        )

        // check bio
        XCTAssertTrue(
            app.staticTexts[expectedBio].waitForExistence(timeout: 5),
            "The bio did not appear within 5 seconds"
        )

        // logout
        app.buttons["LogoutButton"].tap()

        let alert = app.alerts[localizedString(key: "profile_alert.title")]
        XCTAssert(alert.waitForExistence(timeout: 5))

        alert.buttons[localizedString(key: "profile_alert.action")].tap()

        let authenticateButton = app.buttons["Authenticate"]

        // check success logout
        XCTAssertTrue(
            authenticateButton.waitForExistence(timeout: 5),
            "The authenticateButton did not appear within 5 seconds"
        )
    }

    private func waitForHUDToDisappear(_ hud: XCUIElement) {
        let hudExpectation = expectation(for: NSPredicate(format: "exists == false"), evaluatedWith: hud, handler: nil)
        wait(for: [hudExpectation], timeout: 15)
    }

    private func localizedString(key: String) -> String {
        return NSLocalizedString(key, bundle: Bundle(for: ImageFeedUITests.self), comment: "")
    }
}
