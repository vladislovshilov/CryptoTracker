//
//  UserSettings.swift
//  CryptoTracker
//
//  Created by lil angee on 25.05.25.
//

import Foundation

final class UserSettings: ObservableObject {
    @UserDefault(key: "minRefreshRate", defaultValue: 6)
    static var minRefreshRate: UInt8
    
    @UserDefault(key: "refreshRate", defaultValue: 15)
    static var refreshRate: UInt8
    
    @UserDefault(key: "favoriteCoinIDs", defaultValue: [])
    static var storedFavoriteCoinIDs: [String]
    
    @UserDefault(key: "appTheme", defaultValue: AppTheme.light.rawValue)
    static var appTheme: String
}
