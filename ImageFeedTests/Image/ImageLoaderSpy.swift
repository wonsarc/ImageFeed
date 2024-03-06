//
//  ImageLoaderMock.swift
//  ImageFeedTests
//
//  Created by Artem Krasnov on 02.03.2024.
//

@testable import ImageFeed
import UIKit

final class ImageLoaderSpy: ImageLoaderProtocol {
    func loadImage(for photo: Photo, completion: @escaping (Result<UIImage, Error>) -> Void) {
        guard let image = UIImage(named: "0") else { return }
        return  completion(.success(image))
    }
}
