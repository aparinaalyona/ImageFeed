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
                print("[data(for:)]: NetworkError - \(error.localizedDescription)")
                completion(.failure(error))
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                let errorr = NSError(domain: "data(for:)", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid response"])
                print("[data(for:)]: InvalidResponseError - нет HTTPURLResponse")
                completion(.failure(errorr))
                return
            }

            guard let data = data else {
                let errorr = NSError(domain: "data(for:)", code: -2, userInfo: [NSLocalizedDescriptionKey: "Empty data"])
                print("[data(for:)]: EmptyDataError - пустой ответ от сервера")
                completion(.failure(errorr))
                return
            }

            if !(200..<300).contains(httpResponse.statusCode) {
                let errorr = NSError(domain: "data(for:)", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "HTTP status code \(httpResponse.statusCode)"])
                print("[data(for:)]: HTTPError - статус \(httpResponse.statusCode)")
                completion(.failure(errorr))
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

        let task = self.data(for: request) { result in
            switch result {
            case .success(let data):
                do {
                    let object = try decoder.decode(T.self, from: data)
                    completion(.success(object))
                } catch {
                    print("[objectTask]: DecodingError - \(error.localizedDescription), Данные: \(String(data: data, encoding: .utf8) ?? "")")
                    completion(.failure(error))
                }

            case .failure(let error):
                print("[objectTask]: NetworkError - \(error.localizedDescription)")
                completion(.failure(error))
            }
        }

        return task
    }
}
