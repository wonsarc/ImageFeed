//
//  ImageLoader.swift
//  ImageFeed
//
//  Created by Artem Krasnov on 02.03.2024.
//

import UIKit
import Kingfisher

protocol ImageLoaderProtocol {
    func loadImage(on url: String, completion: @escaping (Result<UIImage, Error>) -> Void)
}

final class ImageLoadService: ImageLoaderProtocol {

    // MARK: - Public Properties

    let options: KingfisherOptionsInfo = [.cacheMemoryOnly, .transition(.fade(0.2))]

    // MARK: - Public Methods

    func loadImage(on stringUrl: String, completion: @escaping (Result<UIImage, Error>) -> Void) {
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
