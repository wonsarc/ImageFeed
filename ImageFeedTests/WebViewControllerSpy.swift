//
//  WebViewControllerSpy.swift
//  ImageFeedTests
//
//  Created by Artem Krasnov on 23.02.2024.
//

@testable import ImageFeed
import UIKit

final class WebViewControllerSpy: UIViewController, WebViewControllerProtocol {
    var presenter: ImageFeed.WebViewPresenterProtocol?
    var funcLoadRequestCalled: Bool = false

    func setProgressValue(_ newValue: Float) {
    }

    func setProgressHidden(_ isHidden: Bool) {
    }

    func didUpdateProgressValue(_ newValue: Double) {

    }

    func load(request: URLRequest) {
        funcLoadRequestCalled = true
    }
}
