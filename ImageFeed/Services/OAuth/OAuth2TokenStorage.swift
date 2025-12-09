//
//  OAuth2TokenStorage.swift
//  ImageFeed
//
//  Created by Алена Апарина on 10.11.2025.
//
import Foundation
import SwiftKeychainWrapper

final class OAuth2TokenStorage {
    static let shared = OAuth2TokenStorage()
    private init() { }

    private let tokenKey = "BearerToken"

    var token: String? {
        get {
            KeychainWrapper.standard.string(forKey: tokenKey)
        }
        set {
            if let newValue = newValue {
                let success = KeychainWrapper.standard.set(newValue, forKey: tokenKey)
                if !success {
                    print("[Keychain]: Ошибка сохранения токена")
                }
            } else {
                let success = KeychainWrapper.standard.removeObject(forKey: tokenKey)
                if !success {
                    print("[Keychain]: Ошибка удаления токена")
                }
            }
        }
    }

    func clearToken() {
        let success = KeychainWrapper.standard.removeObject(forKey: tokenKey)
        if !success {
            print("[Keychain]: Ошибка clearToken — токен не удалён")
        }
    }
}

