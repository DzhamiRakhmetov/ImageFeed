//
//  OAuth2TokenStorage.swift
//  ImageFeed
//
//  Created by Джами on 21.02.2023.
//

import Foundation

final class OAuth2TokenStorage {
    
    private let defaults = UserDefaults.standard
    
    var token : String? {
        get {
             defaults.string(forKey: "bearerToken")
        }
        set {
            if let token = newValue {
                defaults.set(newValue, forKey: "bearerToken")
            } else {
                defaults.removeObject(forKey: "bearerToken")
            }
        }
    }
}
