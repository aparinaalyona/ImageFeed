//
//  Photo.swift
//  ImageFeed
//
//  Created by Алена Апарина on 09.12.2025.
//

import UIKit

struct Photo {
    let id: String
    let size: CGSize
    let createdAt: Date?
    let welcomeDescription: String?
    let thumbImageURL: String
    let largeImageURL: String
    var isLiked: Bool
}

