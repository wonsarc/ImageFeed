//
//  ImageLoader.swift
//  ImageFeed
//
//  Created by Artem Krasnov on 02.03.2024.
//

import UIKit
import Kingfisher

typealias ResultImageError = (Result<UIImage, Error>) -> Void

protocol ImageDownloadServiceProtocol {
    func downloadImage(on url: String, completion: @escaping ResultImageError)
}

final class ImageDownloadService: ImageDownloadServiceProtocol {

    // MARK: - Public Properties

    let options: KingfisherOptionsInfo = [.cacheMemoryOnly, .transition(.fade(0.2))]

    // MARK: - Public Methods

    func downloadImage(on stringUrl: String, completion: @escaping (Result<UIImage, Error>) -> Void) {
       guard let imageURL = URL(string: stringUrl) else {
           completion(.failure(PhotoError.invalidURL))
           return
       }

       KingfisherManager.shared.retrieveImage(with: imageURL, options: options) { result in
           switch result {
           case .success(let imageResult):
               completion(.success(imageResult.image))
           case .failure(let error):
               completion(.failure(error))
           }
       }
   }
}
