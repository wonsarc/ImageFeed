//
//  ImagesListService.swift
//  ImageFeed
//
//  Created by Artem Krasnov on 02.02.2024.
//

import Foundation

final class ImagesListService {
    // MARK: - Properties
    static let didChangeNotification = Notification.Name(rawValue: "ImagesListServiceDidChange")
    static let shared = ImagesListService()
    private let photosURL = "\(defaultBaseURL)/photos"
    private var lastLoadedPage = 0
    private (set) var photos: [Photo] = []
    private var task: URLSessionTask?
    private let urlSession = URLSession.shared
    
    // MARK: - Init
    private init() { }
    
    // MARK: - Func
    func fetchPhotosNextPage(_ completion: @escaping (Result<[Photo], Error>) -> Void) {
        assert(Thread.isMainThread)
        if task != nil { task?.cancel() }
        
        let nextPage = lastLoadedPage + 1
        let url = NetworkClient().createURL(
            url: photosURL,
            queryItems: [
                URLQueryItem(name: "page", value: String(nextPage)),
                URLQueryItem(name: "per_page", value: String(10))
            ])
        let request = NetworkClient().createRequestWithBearerAuth(
            url: url,
            httpMethod: .GET,
            token: OAuth2TokenStorage.shared.token)
        
        task = urlSession.objectTask(
            for: request,
            completion: { [weak self] (result: Result<[PhotoResult], Error>) in
                guard let self = self else { return }
                switch result {
                case .success(let listPhoto):
                    for photo in listPhoto {
                        let photo = Photo(
                            id: photo.id ?? "",
                            size: CGSize(width: photo.width ?? 0, height: photo.height ?? 0),
                            createdAt: photo.createdAt ?? Date(),
                            welcomeDescription: photo.description ?? "",
                            thumbImageURL: photo.urls?.thumb ?? "",
                            largeImageURL: photo.urls?.full ?? "",
                            isLiked: photo.likedByUser ?? false
                        )
                        photos.append(photo)
                    }

                    lastLoadedPage = nextPage
                    completion(.success(photos))
                case .failure(let error):
                    completion(.failure(error))
                }
            })
        task?.resume()
        
        NotificationCenter.default
            .post(
                name: ImagesListService.didChangeNotification,
                object: self,
                userInfo: ["photos": photos]
            )
    }
}
