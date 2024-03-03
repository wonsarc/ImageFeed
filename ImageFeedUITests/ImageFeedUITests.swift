//
//  ImageFeedUITests.swift
//  ImageFeedUITests
//
//  Created by Artem Krasnov on 03.03.2024.
//

import XCTest

final class ImageFeedUITests: XCTestCase {
    private let app = XCUIApplication()

    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launch()
    }

    func testAuth() throws {
        // given
        app.buttons["Authenticate"].tap()

        // when
        let webView = app.webViews["UnsplashWebView"]
        let isUnsplashWebView = webView.waitForExistence(timeout: 5)
        XCTAssertTrue(isUnsplashWebView, "UnsplashWebView did not appear within 5 seconds")

        let loginTextField = webView.descendants(matching: .textField).element
        loginTextField.tap()
        loginTextField.typeText("use test e-mail")

        let passwordTextField = webView.descendants(matching: .secureTextField).element
        passwordTextField.tap()
        passwordTextField.typeText("use test password")

        let loginButton = webView.buttons["Login"]
        loginButton.tap()

        // then
        let tablesQuery = app.tables
        let cell = tablesQuery.children(matching: .cell).element(boundBy: 0)
        XCTAssertTrue(cell.waitForExistence(timeout: 5), "The first table cell did not appear within 5 seconds")
    }

    func testFeed() throws {
        // тестируем сценарий ленты
    }

    func testProfile() throws {
        // тестируем сценарий профиля
    }
}
