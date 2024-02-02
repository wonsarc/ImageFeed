//
//  ProfileResult.swift
//  ImageFeed
//
//  Created by Artem Krasnov on 24.01.2024.
//

import Foundation

struct ProfileResult: Decodable {
    let username: String?
    let firstName: String?
    let lastName: String?
    let bio: String?
}
