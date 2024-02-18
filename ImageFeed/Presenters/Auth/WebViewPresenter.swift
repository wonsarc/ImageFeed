//
//  WebViewPresenter.swift
//  ImageFeed
//
//  Created by Artem Krasnov on 18.02.2024.
//

import Foundation

protocol WebViewPresenterProtocol {
    var view: WebViewControllerProtocol? {get set}
    func viewDidLoad()
    func didUpdateProgressValue(_ newValue: Double)
    func code(from url: URL) -> String?
}

final class WebViewPresenter: WebViewPresenterProtocol {
    // MARK: - Properties
    private let unsplashAuthorizeURLString = "https://unsplash.com/oauth/authorize"
    weak var view: WebViewControllerProtocol?

    // MARK: - Public Methods
    func viewDidLoad() {
        var urlComponents = URLComponents(string: unsplashAuthorizeURLString)
        urlComponents?.queryItems = [
            URLQueryItem(name: "client_id", value: accessKey),
            URLQueryItem(name: "redirect_uri", value: redirectURI),
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "scope", value: accessScope)
        ]
        if let url = urlComponents?.url {
            let request = URLRequest(url: url)
            view?.load(request: request)
        }
    }

    func didUpdateProgressValue(_ newValue: Double) {
        let newProgressValue = Float(newValue)
        view?.setProgressValue(newProgressValue)

        let shouldHideProgress = shouldHideProgress(for: newProgressValue)
        view?.setProgressHidden(shouldHideProgress)
    }

    func shouldHideProgress(for value: Float) -> Bool {
        abs(value - 1.0) <= 0.0001
    }

    func code(from url: URL) -> String? {
        if let components = URLComponents(string: url.absoluteString),
           components.path == "/oauth/authorize/native",
           let codeItem = components.queryItems?.first(where: { $0.name == "code" }) {
            return codeItem.value
        } else {
            return nil
        }
    }
}
