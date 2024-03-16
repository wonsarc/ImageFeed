//
//  OAuth2TokenStorage.swift
//  ImageFeed
//
//  Created by Artem Krasnov on 17.01.2024.
//

import Foundation
import SwiftKeychainWrapper

final class OAuth2TokenStorage {

    // MARK: - Public Properties

    static let shared = OAuth2TokenStorage()
    var token: String {
        get {
            keychainWrapper.string(forKey: Keys.authToken.rawValue) ?? ""
        }

        set {
            keychainWrapper.set(newValue, forKey: Keys.authToken.rawValue)
        }
    }

    // MARK: - Private Properties

    private let keychainWrapper = KeychainWrapper.standard

    // MARK: - Initializers

    private init() {
    }

    // MARK: - Public Methods

    func deleteToken() {
        keychainWrapper.removeObject(forKey: Keys.authToken.rawValue)
    }
}

private enum Keys: String {
    case authToken
}
