//
//  UserSettings.swift
//  CryptoTracker
//
//  Created by lil angee on 25.05.25.
//

import Foundation
//
//struct UserSettings {
//    @UserDefault(key: "refreshRate", defaultValue: 15)
//    static var refreshRate: UInt8
//
//    @UserDefault(key: "favoriteCoinIDs", defaultValue: [])
//    static var favoriteCoinIDs: [String]
//}

final class UserSettings: ObservableObject {
    @UserDefault(key: "refreshRate", defaultValue: 15)
    static var refreshRate: UInt8
    
    @UserDefault(key: "favoriteCoinIDs", defaultValue: [])
    static var storedFavoriteCoinIDs: [String]
}
