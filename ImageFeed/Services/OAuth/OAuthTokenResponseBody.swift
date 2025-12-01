//
//  OAuthTokenResponseBody.swift
//  ImageFeed
//
//  Created by Алена Апарина on 10.11.2025.
//

struct OAuthTokenResponseBody: Decodable {
    let access_token: String
    let token_type: String
    let scope: String
    let created_at: Int
}
