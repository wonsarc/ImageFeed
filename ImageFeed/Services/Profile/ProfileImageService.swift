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

    func fetchProfileImageURL(username: String, _ completion: @escaping (Result<String, Error>) -> Void) {
        assert(Thread.isMainThread)
        let token = OAuth2TokenStorage.shared.token
        let url = createURL(username: username)

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let data = data,
               let response = response,
               let statusCode = (response as? HTTPURLResponse)?.statusCode {
                if 200 ..< 300 ~= statusCode {
                    do {
                        let decoder = JSONDecoder()
                        decoder.keyDecodingStrategy = .convertFromSnakeCase
                        let json = try decoder.decode(UserResult.self, from: data)
                        self.avatarURL = json.profileImage?["small"]
                    } catch {
                        completion(.failure(error))
                    }
                }
            }
        }
        task?.resume()
        NotificationCenter.default
            .post(
                name: ProfileImageService.didChangeNotification,
                object: self,
                userInfo: ["URL": avatarURL ?? ""]
            )
    }

    private func createURL(username: String) -> URL {
        var urlComponents = URLComponents(string: getProfileImageURL)
        urlComponents?.queryItems = [
            URLQueryItem(name: "username", value: username)
        ]
        guard let url = urlComponents?.url else {
            preconditionFailure("Error")
        }
        return url
    }
}
