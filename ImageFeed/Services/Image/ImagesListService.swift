//
//  ImagesListService.swift
//  ImageFeed
//
//  Created by Artem Krasnov on 02.02.2024.
//

import Foundation

final class ImagesListService {
    // MARK: - Static Properties
    static let didChangeNotification = Notification.Name(rawValue: "ImagesListServiceDidChange")

    // MARK: - Private Properties
    private let photosURL = "\(AuthConfiguration.standard.defaultBaseURL)/photos"
    private let networkClient = NetworkClient()
    private let urlSession = URLSession.shared
    private let dateFormatter = ISO8601DateFormatter()
    private let perPage = 10
    private var lastLoadedPage = 0
    private (set) var photos: [Photo] = []
    private var task: URLSessionTask?

    // MARK: - Public Func
    func fetchPhotosNextPage() {
        assert(Thread.isMainThread)
        if task != nil {
            if lastLoadedPage == photos.count / perPage {
                task?.cancel()
            } else {
                return
            }
        }

        let nextPage = lastLoadedPage + 1
        let url = networkClient.createURL(
            url: photosURL,
            queryItems: [
                URLQueryItem(name: "page", value: String(nextPage)),
                URLQueryItem(name: "per_page", value: String(perPage))
            ])
        let request = networkClient.createRequestWithBearerAuth(
            url: url,
            httpMethod: .GET,
            token: OAuth2TokenStorage.shared.token
        )
        task = createPhotosTask(request: request, nextPage: nextPage)
        task?.resume()
    }

    func changeLike(photoId: String, isLike: Bool, _ completion: @escaping (Result<Void, Error>) -> Void) {
        let likeURL = "\(AuthConfiguration.standard.defaultBaseURL)/photos/\(photoId)/like"
        let url = networkClient.createURL(
            url: likeURL,
            queryItems: [])
        let request = networkClient.createRequestWithBearerAuth(
            url: url,
            httpMethod: isLike ? .DELETE : .POST,
            token: OAuth2TokenStorage.shared.token
        )

        task = urlSession.dataTask(with: request, completionHandler: { _, response, error in
            DispatchQueue.main.async {
                if let response = response,
                   let statusCode = (response as? HTTPURLResponse)?.statusCode {
                    if 200 ..< 300 ~= statusCode {
                        completion(.success(self.changeLikeed(photoId: photoId)))
                    } else {
                        completion(.failure(error ?? NetworkError.urlSessionError))
                    }
                }
            }
        })
        task?.resume()
    }

    // MARK: - Private Func
    private func createNotification() {
        NotificationCenter.default
            .post(
                name: ImagesListService.didChangeNotification,
                object: self,
                userInfo: ["photos": photos]
            )
    }

    private func changeLikeed(photoId: String) {
        if let index = self.photos.firstIndex(where: { $0.id == photoId }) {
            let photo = self.photos[index]
            let newPhoto = Photo(
                      id: photo.id,
                      size: photo.size,
                      createdAt: photo.createdAt,
                      welcomeDescription: photo.welcomeDescription,
                      thumbImageURL: photo.thumbImageURL,
                      largeImageURL: photo.largeImageURL,
                      isLiked: !photo.isLiked
                  )
            self.photos[index] = newPhoto
        }
    }

    private func createPhotosTask(request: URLRequest, nextPage: Int) -> URLSessionTask? {
        return urlSession.objectTask(
            for: request,
            completion: { [weak self ] (result: Result<[PhotoResult], Error>) in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    switch result {
                    case .success(let listPhoto):
                        for photo in listPhoto {
                            let photo = Photo(
                                id: photo.id ?? "",
                                size: CGSize(width: photo.width ?? 0, height: photo.height ?? 0),
                                createdAt: self.dateFormatter.date(from: photo.createdAt ?? ""),
                                welcomeDescription: photo.description ?? "",
                                thumbImageURL: photo.urls?.thumb ?? "",
                                largeImageURL: photo.urls?.full ?? "",
                                isLiked: photo.likedByUser ?? false
                            )
                            self.photos.append(photo)
                        }
                        self.lastLoadedPage = nextPage
                        self.createNotification()
                    case .failure(let error):
                        print(error)
                    }
                }
            })
    }
}
