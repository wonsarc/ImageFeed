//
//  OAuthTokenResponseBody.swift
//  ImageFeed
//
//  Created by Artem Krasnov on 15.01.2024.
//

import Foundation

struct OAuthTokenResponseBody: Decodable {
    let accessToken: String
    let tokenType: String
    let scope: String
    let createdAt: Int
}
