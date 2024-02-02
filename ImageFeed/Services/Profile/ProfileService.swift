//
//  ProfileService.swift
//  ImageFeed
//
//  Created by Artem Krasnov on 24.01.2024.
//

import Foundation

final class ProfileService {
    private let profileMeURL = URL(string: "\(defaultBaseURL)/me")!
    static let shared = ProfileService()

    private var lastToken: String?
    private var task: URLSessionTask?
    private let urlSession = URLSession.shared
    private(set) var profile: Profile?

    private init() { }

    func fetchProfile(_ token: String, completion: @escaping (Result<Profile, Error>) -> Void) {
        assert(Thread.isMainThread)
        if lastToken == token {return}
        task?.cancel()
        lastToken = token

        let request = NetworkClient().createRequestWithBearerAuth(
            url: profileMeURL,
            httpMethod: .GET,
            token: token
        )

        task = urlSession.objectTask(for: request,
                                     completion: { [weak self] (result: Result<ProfileResult,
                                                                Error>) in
            guard let self = self else { return }
            switch result {
            case .success(let body):
                let currentProfile = Profile(
                    username: body.username,
                    name: "\(body.firstName ?? "") \(body.lastName ?? "")",
                    loginName: "@\(body.username ?? "")",
                    bio: body.bio
                )
                self.profile = currentProfile
                completion(.success(currentProfile))
            case .failure(let error):
                completion(.failure(error))
            }
        })
        task?.resume()
    }
}
