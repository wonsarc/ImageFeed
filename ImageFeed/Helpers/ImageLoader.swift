//
//  ImageLoader.swift
//  ImageFeed
//
//  Created by Artem Krasnov on 02.03.2024.
//

import UIKit
import Kingfisher

protocol ImageLoaderProtocol {
    func loadImage(for photo: Photo, completion: @escaping (Result<UIImage, Error>) -> Void)
}

final class ImageLoader: ImageLoaderProtocol {
    func loadImage(for photo: Photo, completion: @escaping (Result<UIImage, Error>) -> Void) {
       guard let imageURL = URL(string: photo.thumbImageURL) else {
           completion(.failure(PhotoError.invalidURL))
           return
       }

       let options: KingfisherOptionsInfo = [.cacheMemoryOnly, .transition(.fade(0.2))]

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
