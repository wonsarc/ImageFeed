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
    private let photosURL = "\(defaultBaseURL)/photos"
    private let networkClient = NetworkClient()
    private let urlSession = URLSession.shared
    private var lastLoadedPage = 0
    private (set) var photos: [Photo] = []
    private var task: URLSessionTask?

    // MARK: - Public Func
    func fetchPhotosNextPage() {
        assert(Thread.isMainThread)
        if task != nil { task?.cancel() }

        let nextPage = lastLoadedPage + 1
        let url = createURL(nextPage: nextPage)
        let request = createRequest(url: url)

        task = createTask(request: request, nextPage: nextPage)
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

    private func createTask(request: URLRequest, nextPage: Int) -> URLSessionTask? {
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
                                createdAt: self.convertDate(stringDate: photo.createdAt ?? ""),
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
                        print(error, "CASE ERROR urlSession.objectTask")
                    }
                }
            })
    }

    private func convertDate(stringDate: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd’T’HH:mm:ssZ"
        return stringDate == "" ? Date() : formatter.date(from: stringDate)
    }

    private func createURL(nextPage: Int) -> URL {
        return networkClient.createURL(
            url: photosURL,
            queryItems: [
                URLQueryItem(name: "page", value: String(nextPage)),
                URLQueryItem(name: "per_page", value: String(10))
            ])
    }

    private func createRequest(url: URL) -> URLRequest {
        return networkClient.createRequestWithBearerAuth(
            url: url,
            httpMethod: .GET,
            token: OAuth2TokenStorage.shared.token
        )
    }
}
