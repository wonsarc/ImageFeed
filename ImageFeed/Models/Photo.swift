//
//  Photo.swift
//  ImageFeed
//
//  Created by Artem Krasnov on 02.02.2024.
//

import Foundation

struct Photo: Decodable, Equatable {
    let id: String
    let size: CGSize
    let createdAt: Date?
    let welcomeDescription: String?
    let thumbImageURL: String
    let largeImageURL: String
    let isLiked: Bool

    static func == (lhs: Photo, rhs: Photo) -> Bool {
        return lhs.id == rhs.id &&
        lhs.size == rhs.size &&
        lhs.createdAt == rhs.createdAt &&
        lhs.welcomeDescription == rhs.welcomeDescription &&
        lhs.thumbImageURL == rhs.thumbImageURL &&
        lhs.largeImageURL == rhs.largeImageURL &&
        lhs.isLiked == rhs.isLiked
    }
}

extension Array where Element == Photo {
    static func == (lhs: [Photo], rhs: [Photo]) -> Bool {
        guard lhs.count == rhs.count else {
            return false
        }

        for (index, element) in lhs.enumerated() where element != rhs[index] {
            return false
        }

        return true
    }
}
