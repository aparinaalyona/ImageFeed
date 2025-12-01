//
//  ProfileService.swift
//  ImageFeed
//
//  Created by Алена Апарина on 16.11.2025.
//

import Foundation

struct Profile {
    let userName: String
    let name: String
    let loginName: String
    let bio: String?
}

struct ProfileResult: Codable {
    let userName: String
    let firstName: String?
    let lastName: String?
    let bio: String?

    private enum CodingKeys: String, CodingKey {
        case userName = "username"
        case firstName = "first_name"
        case lastName = "last_name"
        case bio
    }
}

final class ProfileService {
    static let shared = ProfileService()
    private init() {}

    private var task: URLSessionTask?
    private let urlSession = URLSession.shared
    private(set) var profile: Profile?

    func fetchProfile(_ token: String, completion: @escaping (Result<Profile, Error>) -> Void) {
        assert(Thread.isMainThread)

        task?.cancel()

        guard let request = makeProfileRequest(token: token) else {
            print("[ProfileService.makeProfileRequest]: Failure - invalid URL")
            completion(.failure(URLError(.badURL)))
            return
        }

        task = urlSession.objectTask(for: request) { [weak self] (result: Result<ProfileResult, Error>) in
            guard let self else { return }

            switch result {
            case .success(let profileResult):
                let name = [profileResult.firstName, profileResult.lastName]
                    .compactMap { $0 }
                    .joined(separator: " ")

                let profile = Profile(
                    userName: profileResult.userName,
                    name: name,
                    loginName: "@\(profileResult.userName)",
                    bio: profileResult.bio
                )

                self.profile = profile
                completion(.success(profile))

            case .failure(let error):
                print("[ProfileService.fetchProfile]: Failure - \(error.localizedDescription)")
                completion(.failure(error))
            }

            self.task = nil
        }

        task?.resume()
    }

    private func makeProfileRequest(token: String) -> URLRequest? {
        guard let url = URL(string: "https://api.unsplash.com/me") else {
            return nil
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
}
