//
//  UserDefaults.swift
//  CryptoTracker
//
//  Created by lil angee on 25.05.25.
//

import Foundation

@propertyWrapper
struct UserDefault<Value: Codable> {
    let key: String
    let defaultValue: Value
    private let storage: UserDefaults

    init(key: String, defaultValue: Value, storage: UserDefaults = .standard) {
        self.key = key
        self.defaultValue = defaultValue
        self.storage = storage
    }

    var wrappedValue: Value {
        get {
            guard let data = storage.data(forKey: key) else {
                return defaultValue
            }

            do {
                return try JSONDecoder().decode(Value.self, from: data)
            } catch {
                print("Failed to decode \(key):", error)
                return defaultValue
            }
        }
        set {
            do {
                let data = try JSONEncoder().encode(newValue)
                storage.set(data, forKey: key)
            } catch {
                print("Failed to encode \(key):", error)
            }
        }
    }
}
