//
//  ProfileImageService.swift
//  ImageFeed
//
//  Created by Artem Krasnov on 27.01.2024.
//

import Foundation

private var getProfileImageURL = "\(defaultBaseURL)/me"

final class ProfileImageService {
    static let shared = ProfileImageService()
    static let didChangeNotification = Notification.Name(rawValue: "ProfileImageProviderDidChange")

    private (set) var avatarURL: String?
    private var task: URLSessionTask?
    private let urlSession = URLSession.shared

    func fetchProfileImageURL(username: String, _ completion: @escaping (Result<String, Error>) -> Void) {
        assert(Thread.isMainThread)
        let token = OAuth2TokenStorage.shared.token
        let url = NetworkClient().createURL(
            url: getProfileImageURL,
            queryItems: [URLQueryItem(name: "username", value: username)])

        let request = NetworkClient().createRequestWithBearerAuth(
            url: url,
            httpMethod: .GET,
            token: token
        )

        task = urlSession.objectTask(for: request,
                                     completion: { [weak self] (result: Result<UserResult,
                                                                Error>) in
            guard let self = self else { return }
            switch result {
            case .success(let body):
                let smallAvatarURL = body.profileImage?["small"]
                self.avatarURL = smallAvatarURL
                completion(.success(smallAvatarURL ?? ""))
            case .failure(let error):
                completion(.failure(error))
            }
        })
        task?.resume()

        NotificationCenter.default
            .post(
                name: ProfileImageService.didChangeNotification,
                object: self,
                userInfo: ["URL": avatarURL ?? ""]
            )
    }
}
