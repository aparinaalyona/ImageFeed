//
//  OAuth2TokenStorage.swift
//  ImageFeed
//
//  Created by Алена Апарина on 10.11.2025.
//
import Foundation

final class OAuth2TokenStorage {
    private let tokenKey = "BearerToken"
    private let defaults = UserDefaults.standard
    
    var token: String? {
        get {
            defaults.string(forKey: tokenKey)
        }
        set {
            defaults.setValue(newValue, forKey: tokenKey)
        }
    }
}
