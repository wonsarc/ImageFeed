//
//  ImageFeedTests.swift
//  ImageFeedTests
//
//  Created by Artem Krasnov on 23.02.2024.
//

@testable import ImageFeed
import XCTest

final class WebViewTests: XCTestCase {
    func testViewControllerCallsViewDidLoad() {
        // given
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(
            withIdentifier: "WebViewController"
        ) as? WebViewController

        guard let viewController = viewController else { return }
        let presenter = WebViewPresenterSpy()
        viewController.presenter = presenter
        presenter.view = viewController

        // when
        _ = viewController.view

        // then
        XCTAssertTrue(presenter.viewDidLoadCalled)
    }

    func testPresenterCallsLoadRequest() {
        // given
        let viewController = WebViewControllerSpy()
        let authHelper = AuthConfigurationService()
        let presenter = WebViewPresenter(authHelper: authHelper)
        viewController.presenter = presenter
        presenter.view = viewController

        // when
        presenter.viewDidLoad()
        _ = viewController.view

        // then
        XCTAssertTrue(viewController.funcLoadRequestCalled)
    }

    func testProgressVisibleWhenLessThenOne() {
        // given
        let authHelper = AuthConfigurationService()
        let presenter = WebViewPresenter(authHelper: authHelper)
        let progress: Float = 0.6

        // when
        let isHideProgress = presenter.shouldHideProgress(for: progress)

        // then
        XCTAssertFalse(isHideProgress)
    }

    func testProgressHiddenWhenOne() {
        // given
        let authHelper = AuthConfigurationService()
        let presenter = WebViewPresenter(authHelper: authHelper)
        let progress: Float = 1

        // when
        let isHideProgress = presenter.shouldHideProgress(for: progress)

        // then
        XCTAssertTrue(isHideProgress)
    }

    func testAuthHelperAuthURL() {
        // given
        let configuration = AuthConfiguration.standard
        let authHelper = AuthConfigurationService(configuration: configuration)

        // when
        let url = authHelper.authURL()
        guard let urlString = url?.absoluteString else { return }

        // then
        XCTAssertTrue(urlString.contains(configuration.authURLString))
        XCTAssertTrue(urlString.contains(configuration.accessKey))
        XCTAssertTrue(urlString.contains(configuration.redirectURI))
        XCTAssertTrue(urlString.contains("code"))
        XCTAssertTrue(urlString.contains(configuration.accessScope))

    }

    func testCodeFromURL() {
        // given
        let expCodeValue = "test code"
        let authHelper = AuthConfigurationService()
        var urlComponents = URLComponents(string: "https://unsplash.com/oauth/authorize/native")
        urlComponents?.queryItems = [URLQueryItem(name: "code", value: expCodeValue)]
        guard let url = urlComponents?.url else { return }

        // when
        let code = authHelper.code(from: url)

        // then
        XCTAssertEqual(code, expCodeValue)
    }
}
