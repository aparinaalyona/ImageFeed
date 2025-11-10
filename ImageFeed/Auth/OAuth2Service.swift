//
//  OAuth2Service.swift
//  ImageFeed
//
//  Created by Алена Апарина on 10.11.2025.
//
import Foundation

final class OAuth2Service {
    static let shared = OAuth2Service()
    private init() { }

    private let storage = OAuth2TokenStorage()
    private var task: URLSessionDataTask?

    private func makeOAuthTokenRequest(code: String) -> URLRequest? {
        guard let url = URL(string: "https://unsplash.com/oauth/token") else {
            return nil
        }

        var components = URLComponents()
        components.queryItems = [
            URLQueryItem(name: "client_id", value: Constants.accessKey),
            URLQueryItem(name: "client_secret", value: Constants.secretKey),
            URLQueryItem(name: "redirect_uri", value: Constants.redirectURI),
            URLQueryItem(name: "code", value: code),
            URLQueryItem(name: "grant_type", value: "authorization_code")
        ]

        guard let bodyData = components.query?.data(using: .utf8) else {
            return nil
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = bodyData
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        return request
    }

    func fetchOAuthToken(code: String, completion: @escaping (Result<String, Error>) -> Void) {
        task?.cancel()

        guard let request = makeOAuthTokenRequest(code: code) else {
            completion(.failure(NSError(
                domain: "OAuth2Service",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "Не удалось создать запрос"]
            )))
            return
        }

        task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in

            if let error = error {
                print("Сетевая ошибка: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                let err = NSError(domain: "OAuth2Service", code: -2, userInfo: [NSLocalizedDescriptionKey: "Некорректный ответ"])
                print("Ошибка: нет HTTP-ответа")
                DispatchQueue.main.async {
                    completion(.failure(err))
                }
                return
            }

            guard (200 ... 299).contains(httpResponse.statusCode) else {
                let err = NSError(
                    domain: "OAuth2Service",
                    code: httpResponse.statusCode,
                    userInfo: [NSLocalizedDescriptionKey: "Ошибка сервера \(httpResponse.statusCode)"]
                )
                print("Ошибка от сервиса Unsplash: \(httpResponse.statusCode)")
                DispatchQueue.main.async {
                    completion(.failure(err))
                }
                return
            }

            guard let data = data else {
                let err = NSError(
                    domain: "OAuth2Service",
                    code: -3,
                    userInfo: [NSLocalizedDescriptionKey: "Пустой ответ от сервера"]
                )
                print("Пустой ответ от сервера")
                DispatchQueue.main.async {
                    completion(.failure(err))
                }
                return
            }

            do {
                let tokenResponse = try JSONDecoder().decode(OAuthTokenResponseBody.self, from: data)
                let accessToken = tokenResponse.access_token

                self?.storage.token = accessToken
                print("Токен успешно получен и сохранён")

                DispatchQueue.main.async {
                    completion(.success(accessToken))
                }
            } catch {
                print("Ошибка декодирования JSON: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }

        task?.resume()
    }
}
