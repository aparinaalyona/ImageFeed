//
//  URLSResult.swift
//  ImageFeed
//
//  Created by Алена Апарина on 09.12.2025.
//

import Foundation

struct UrlsResult: Decodable {
    let raw: String
    let full: String
    let regular: String
    let small: String
    let thumb: String
}
