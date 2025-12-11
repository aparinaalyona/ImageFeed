//
//  PhotoResult.swift
//  ImageFeed
//
//  Created by Алена Апарина on 09.12.2025.
//

import Foundation

struct PhotoResult: Decodable {
    let id: String
    let createdAt: Date?
    let width: Int
    let height: Int
    let description: String?
    let isLike: Bool
    let urls: UrlsResult

    enum CodingKeys: String, CodingKey {
        case id
        case createdAt = "created_at"
        case width
        case height
        case description
        case isLike = "liked_by_user"
        case urls
    }
}
