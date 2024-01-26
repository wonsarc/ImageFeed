//
//  ProfileService.swift
//  ImageFeed
//
//  Created by Artem Krasnov on 24.01.2024.
//

import Foundation

private let getProfileMeURL = URL(string: "\(defaultBaseURL)/me")!

final class ProfileService {
    private var lastToken: String?
    private var task: URLSessionTask?

    func fetchProfile(_ token: String, completion: @escaping (Result<Profile, Error>) -> Void) {
        assert(Thread.isMainThread)
        if lastToken == token {return}
        task?.cancel()
        lastToken = token

        var request = URLRequest(url: getProfileMeURL)
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
                        let json =  try decoder.decode(ProfileResult.self, from: data)
                        let profile = Profile(
                            username: json.username,
                            name: "\(json.firstName ?? "") \(json.lastName ?? "")",
                            loginName: "@\(json.username ?? "")",
                            bio: json.bio
                        )
                        completion(.success(profile))
                    } catch {
                        completion(.failure(error))
                    }
                }
            }
        }
        task?.resume()
    }
}
