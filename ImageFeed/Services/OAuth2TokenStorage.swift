//
//  OAuth2TokenStorage.swift
//  ImageFeed
//
//  Created by Artem Krasnov on 17.01.2024.
//

import Foundation

final class OAuth2TokenStorage {
    private let userDefaults = UserDefaults.standard

    var token: String {
        get {
            userDefaults.string(forKey: Keys.authToken.rawValue) ?? ""
        }

        set {
            userDefaults.set(newValue, forKey: Keys.authToken.rawValue)
        }
    }

    private enum Keys: String {
        case authToken
    }
}
