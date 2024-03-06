//
//  Constants.swift
//  ImageFeed
//
//  Created by Artem Krasnov on 12.01.2024.
//

import Foundation

private let accessKeyStandard = "bJwardQNhRa51vP0_byJw1lF0WfDzB8vk42QjJxdJ90"
private let secretKeyStandard = "Q1GyBNn0UDi4NA_1KdpWseNmtutKpUauH8FoB-6CSxA"
private let redirectURIStandard = "urn:ietf:wg:oauth:2.0:oob"
private let accessScopeStandard = "public+read_user+write_likes"

private let defaultBaseURLStandard = URL(string: "https://api.unsplash.com")!
private let unsplashAuthorizeURLStringStandard = "https://unsplash.com/oauth/authorize"

struct AuthConfiguration {
    let accessKey: String
    let secretKey: String
    let redirectURI: String
    let accessScope: String
    let defaultBaseURL: URL
    let authURLString: String

    init(
        accessKey: String,
        secretKey: String,
        redirectURI: String,
        accessScope: String,
        authURLString: String,
        defaultBaseURL: URL
    ) {
        self.accessKey = accessKey
        self.secretKey = secretKey
        self.redirectURI = redirectURI
        self.accessScope = accessScope
        self.defaultBaseURL = defaultBaseURL
        self.authURLString = authURLString
    }

    static var standard: AuthConfiguration {
        return AuthConfiguration(accessKey: accessKeyStandard,
                                 secretKey: secretKeyStandard,
                                 redirectURI: redirectURIStandard,
                                 accessScope: accessScopeStandard,
                                 authURLString: unsplashAuthorizeURLStringStandard,
                                 defaultBaseURL: defaultBaseURLStandard)
    }
}
