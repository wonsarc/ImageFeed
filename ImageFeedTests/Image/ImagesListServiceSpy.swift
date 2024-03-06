//
//  ImageListServiceSpy.swift
//  ImageFeedTests
//
//  Created by Artem Krasnov on 02.03.2024.
//

@testable import ImageFeed
import Foundation

final class ImagesListServiceSpy: ImagesListServiceProtocol {
    var dataChangeHandler: (() -> Void)?
    var didFetchPhotosNextPage: Bool = false
    var photos: [ImageFeed.Photo] = []

    func changeLike(photoId: String, isLike: Bool, _ completion: @escaping (Result<Void, Error>) -> Void) {
        completion(.success(()))
    }

    func fetchPhotosNextPage() {
        didFetchPhotosNextPage = true
    }

    func observeDataChanges() {
        dataChangeHandler?()
    }
}
