//
//  URLSession+ObjectTask.swift
//  ImageFeed
//
//  Created by Алена Апарина on 28.11.2025.
//

import Foundation

extension URLSession {
    func data(
        for request: URLRequest,
        completion: @escaping (Result<Data, Error>) -> Void
    ) -> URLSessionDataTask {
        let task = dataTask(with: request) { data, response, error in

            if let error = error {
                print("[data(for:)]: NetworkError - message: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                let error = NSError(
                    domain: "data(for:)",
                    code: -1,
                    userInfo: [NSLocalizedDescriptionKey: "Invalid HTTPURLResponse"]
                )
                print("[data(for:)]: InvalidResponseError - reason: missing HTTPURLResponse")
                completion(.failure(error))
                return
            }

            guard let data = data else {
                let error = NSError(
                    domain: "data(for:)",
                    code: -2,
                    userInfo: [NSLocalizedDescriptionKey: "Empty data"]
                )
                print("[data(for:)]: EmptyDataError - reason: server returned empty data")
                completion(.failure(error))
                return
            }

            if !(200 ..< 300).contains(httpResponse.statusCode) {
                let status = httpResponse.statusCode
                let error = NSError(
                    domain: "data(for:)",
                    code: status,
                    userInfo: [NSLocalizedDescriptionKey: "HTTP status code \(status)"]
                )
                print("[data(for:)]: HTTPError - status: \(status)")
                completion(.failure(error))
                return
            }

            completion(.success(data))
        }

        return task
    }

    func objectTask<T: Decodable>(
        for request: URLRequest,
        completion: @escaping (Result<T, Error>) -> Void
    ) -> URLSessionTask {
        let decoder = JSONDecoder()

        let task = data(for: request) { result in
            switch result {
            case let .success(data):
                do {
                    let object = try decoder.decode(T.self, from: data)
                    completion(.success(object))
                } catch {
                    let raw = String(data: data, encoding: .utf8) ?? "unreadable"
                    print("[objectTask]: DecodingError - message: \(error.localizedDescription), data: \(raw)")
                    completion(.failure(error))
                }

            case let .failure(error):
                print("[objectTask]: NetworkError - message: \(error.localizedDescription)")
                completion(.failure(error))
            }
        }

        return task
    }
}
