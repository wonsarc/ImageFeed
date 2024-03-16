//
//  AuthConfigurationService.swift
//  ImageFeed
//
//  Created by Artem Krasnov on 21.02.2024.
//

import Foundation

protocol AuthConfigurationServiceProtocol {
    func authRequest() -> URLRequest?
    func code(from url: URL) -> String?
}

class AuthConfigurationService: AuthConfigurationServiceProtocol {

    // MARK: - Public Properties

    let configuration: AuthConfiguration

    // MARK: - Initializers

    init(configuration: AuthConfiguration = .standard) {
        self.configuration = configuration
    }

    // MARK: - Public Methods

    func authRequest() -> URLRequest? {
        let url = authURL()
        guard let url = url else { return nil }
        return URLRequest(url: url)
    }

    func authURL() -> URL? {
        var urlComponents = URLComponents(string: configuration.authURLString)
        urlComponents?.queryItems = [
            URLQueryItem(name: "client_id", value: configuration.accessKey),
            URLQueryItem(name: "redirect_uri", value: configuration.redirectURI),
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "scope", value: configuration.accessScope)
        ]
        return urlComponents?.url
    }

    func code(from url: URL) -> String? {
        if let urlComponents = URLComponents(string: url.absoluteString),
           urlComponents.path == "/oauth/authorize/native",
           let items = urlComponents.queryItems,
           let codeItem = items.first(where: { $0.name == "code" }) {
            return codeItem.value
        } else {
            return nil
        }
    }
}
