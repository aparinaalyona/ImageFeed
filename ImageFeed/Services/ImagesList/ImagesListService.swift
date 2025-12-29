//
//  ImagesListService.swift
//  ImageFeed
//
//  Created by Алена Апарина on 09.12.2025.
//
import Foundation
import UIKit

final class ImagesListService {
    static let didChangeNotification = Notification.Name("ImagesListServiceDidChange")

    private(set) var photos: [Photo] = []

    private var isLoading = false
    private var lastLoadedPage: Int?
    private let perPage = 10
    private let session = URLSession.shared

    private let accessKey = Constants.accessKey

    func fetchPhotosNextPage() {
        guard !isLoading else { return }
        isLoading = true

        let nextPage = (lastLoadedPage ?? 0) + 1

        var components = URLComponents(string: "https://api.unsplash.com/photos")!
        components.queryItems = [
            URLQueryItem(name: "page", value: "\(nextPage)"),
            URLQueryItem(name: "per_page", value: "\(perPage)")
        ]

        guard let url = components.url else {
            print("[ImagesListService.fetchPhotosNextPage]: [Invalid URL] page=\(nextPage) perPage=\(perPage)")
            isLoading = false
            return
        }

        var request = URLRequest(url: url)
        request.setValue("Client-ID \(accessKey)", forHTTPHeaderField: "Authorization")

        let task = session.dataTask(with: request) { [weak self] data, _, error in
            guard let self = self else { return }
            defer { self.isLoading = false }

            if let error = error {
                print("[ImagesListService.fetchPhotosNextPage]: [Network error] page=\(nextPage) error=\(error)")
                return
            }

            guard let data = data else {
                print("[ImagesListService.fetchPhotosNextPage]: [No data] page=\(nextPage)")
                return
            }

            do {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601

                let results = try decoder.decode([PhotoResult].self, from: data)
                let newPhotos = results.map { self.makePhoto(from: $0) }

                DispatchQueue.main.async {
                    self.photos.append(contentsOf: newPhotos)
                    self.lastLoadedPage = nextPage

                    NotificationCenter.default.post(
                        name: ImagesListService.didChangeNotification,
                        object: self
                    )
                }

            } catch {
                let jsonString = String(data: data, encoding: .utf8) ?? "Unreadable data"
                print("""
                [ImagesListService.fetchPhotosNextPage]: [Decoding error] page=\(nextPage)
                error=\(error)
                data=\(jsonString)
                """)
            }
        }

        task.resume()
    }

    private func makePhoto(from result: PhotoResult) -> Photo {
        Photo(
            id: result.id,
            size: CGSize(width: result.width, height: result.height),
            createdAt: result.createdAt,
            welcomeDescription: result.description,
            thumbImageURL: result.urls.thumb,
            largeImageURL: result.urls.full,
            isLiked: result.isLike
        )
    }

    func changeLike(photoId: String, isLike: Bool, completion: @escaping (Result<Void, Error>) -> Void) {
        let httpMethod = isLike ? "POST" : "DELETE"
        guard let url = URL(string: "https://api.unsplash.com/photos/\(photoId)/like") else {
            let error = NSError(domain: "Invalid URL", code: 0)
            print("[ImagesListService.changeLike]: [Invalid URL] id=\(photoId) isLike=\(isLike)")
            completion(.failure(error))
            return
        }

        guard let token = OAuth2TokenStorage.shared.token else {
            let error = NSError(domain: "No OAuth token", code: 401)
            print("[ImagesListService.changeLike]: [No OAuth token] id=\(photoId) isLike=\(isLike)")
            completion(.failure(error))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = httpMethod
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let task = session.dataTask(with: request) { data, response, error in

            if let error = error {
                print("[ImagesListService.changeLike]: [Network error] id=\(photoId) isLike=\(isLike) error=\(error)")
                completion(.failure(error))
                return
            }

            if let httpResponse = response as? HTTPURLResponse,
               !(200...299).contains(httpResponse.statusCode) {

                let statusCode = httpResponse.statusCode
                print("[ImagesListService.changeLike]: [Invalid status code] id=\(photoId) isLike=\(isLike) code=\(statusCode)")

                completion(.failure(NSError(
                    domain: "Invalid status code",
                    code: statusCode
                )))
                return
            }

            completion(.success(()))
        }
        task.resume()
    }
}
extension ImagesListService: ImagesListServiceProtocol { }
