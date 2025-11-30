//
//  ProfileImageService.swift
//  ImageFeed
//
//  Created by Алена Апарина on 18.11.2025.
//
import Foundation

struct ProfileImage: Codable {
    let small: String
    let medium: String
    let large: String

    private enum CodingKeys: String, CodingKey {
        case small
        case medium
        case large
    }
}

struct UserResult: Codable {
    let profileImage: ProfileImage

    private enum CodingKeys: String, CodingKey {
        case profileImage = "profile_image"
    }
}

final class ProfileImageService {
    static let shared = ProfileImageService()
    private init() { }

    static let didChangeNotification = Notification.Name(rawValue: "ProfileImageProviderDidChange")

    private(set) var avatarURL: String?
    private var task: URLSessionTask?

    func fetchProfileImageURL(
        userName: String,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        task?.cancel()

        guard let token = OAuth2TokenStorage.shared.token else {
            completion(.failure(NSError(
                domain: "ProfileImageService",
                code: 401,
                userInfo: [NSLocalizedDescriptionKey: "Authorization token missing"]
            )))
            return
        }

        guard let request = makeProfileImageRequest(userName: userName, token: token) else {
            completion(.failure(URLError(.badURL)))
            return
        }

        task = URLSession.shared.objectTask(for: request) { [weak self] (result: Result<UserResult, Error>) in
            guard let self else { return }

            switch result {
            case .success(let userResult):
                let url = userResult.profileImage.small
                self.avatarURL = url

                NotificationCenter.default.post(
                    name: ProfileImageService.didChangeNotification,
                    object: self,
                    userInfo: ["URL": url]
                )

                completion(.success(url))

            case .failure(let error):
                print("[ProfileImageService.fetchProfileImageURL]: Failure - \(error.localizedDescription)")
                completion(.failure(error))
            }

            self.task = nil
        }

        task?.resume()
    }

    private func makeProfileImageRequest(userName: String, token: String) -> URLRequest? {
        guard let url = URL(string: "https://api.unsplash.com/users/\(userName)") else {
            return nil
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
}
