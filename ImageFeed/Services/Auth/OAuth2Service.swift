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

            let url = createAuthTokenUrl(code)
            var request = URLRequest(url: url)
            request.httpMethod = "POST"

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

    private func createAuthTokenUrl(_ code: String) -> URL {
        var urlComponents = URLComponents(string: "https://unsplash.com/oauth/token")
        urlComponents?.queryItems = [
            URLQueryItem(name: "client_id", value: accessKey),
            URLQueryItem(name: "client_secret", value: secretKey),
            URLQueryItem(name: "redirect_uri", value: redirectURI),
            URLQueryItem(name: "code", value: code),
            URLQueryItem(name: "grant_type", value: "authorization_code")
        ]
        guard let url = urlComponents?.url else {
            preconditionFailure("Unable to construct authTokenUrl")
        }
        return url
    }
}
