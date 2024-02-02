//
//  OAuth2TokenStorage.swift
//  ImageFeed
//
//  Created by Artem Krasnov on 17.01.2024.
//

import Foundation
import SwiftKeychainWrapper

final class OAuth2TokenStorage {
    static let shared = OAuth2TokenStorage()
    private let keychainWrapper = KeychainWrapper.standard

    private init() {
    }

    var token: String {
        get {
            keychainWrapper.string(forKey: Keys.authToken.rawValue) ?? ""
        }

        set {
            keychainWrapper.set(newValue, forKey: Keys.authToken.rawValue)
        }
    }

    private enum Keys: String {
        case authToken
    }
}
