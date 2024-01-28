//
//  OAuth2Service.swift
//  ImageFeed
//
//  Created by Artem Krasnov on 15.01.2024.
//

import Foundation

final class OAuth2Service {
    private (set) var authToken: String? {
        get {
            return OAuth2TokenStorage.shared.token
        }
        set {
            OAuth2TokenStorage.shared.token = newValue ?? ""
        }
    }

    private var lastCode: String?
    private var task: URLSessionTask?

    func fetchOAuthToken(
        _ code: String,
        completion: @escaping (Result<String, Error>) -> Void ) {
            assert(Thread.isMainThread)
            if lastCode == code {return}
            task?.cancel()
            lastCode = code

            let url = NetworkClient().createURL(
                url: "https://unsplash.com/oauth/token",
                queryItems: createQueryItems(code))

            let request = NetworkClient().createRequest(
                url: url,
                httpMethod: .POST
            )
//            task = URLSession.shared.objectTask(for: request,
//                                                completion: { [weak self] (result: Result<OAuthTokenResponseBody,
//                                                                           Error>) in
//                guard let self = self else { return }
//                switch result {
//                case .success(let body):
//                    let token = body.accessToken
//                    self.authToken = token
//                    completion(.success(token))
//                case .failure(let error):
//                    completion(.failure(error))
//                }
//            })
//            task?.resume()
//        }

            task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                if let data = data,
                   let response = response,
                   let statusCode = (response as? HTTPURLResponse)?.statusCode {
                    if 200 ..< 300 ~= statusCode {
                        do {
                            let decoder = JSONDecoder()
                            decoder.keyDecodingStrategy = .convertFromSnakeCase
                            let json =  try decoder.decode(OAuthTokenResponseBody.self, from: data)
                            self.authToken = json.accessToken
                            completion(.success(self.authToken ?? ""))
                        } catch {
                            completion(.failure(error))
                        }
                    }
                }
            }
            task?.resume()
        }

    private func createQueryItems(_ code: String) -> [URLQueryItem] {
        let queryItemsList = [
            URLQueryItem(name: "client_id", value: accessKey),
            URLQueryItem(name: "client_secret", value: secretKey),
            URLQueryItem(name: "redirect_uri", value: redirectURI),
            URLQueryItem(name: "code", value: code),
            URLQueryItem(name: "grant_type", value: "authorization_code")
        ]
        return queryItemsList
    }
}
