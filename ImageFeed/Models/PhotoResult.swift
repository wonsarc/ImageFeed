//
//  PhotoResult.swift
//  ImageFeed
//
//  Created by Artem Krasnov on 02.02.2024.
//

import Foundation

struct PhotoResult: Decodable {
    let id: String?
    let width: Int?
    let height: Int?
    let createdAt: String?
    let description: String?
    let likedByUser: Bool?
    let urls: UrlsResult?
}
