//
//  AppTheme.swift
//  CryptoTracker
//
//  Created by lil angee on 25.05.25.
//

import Foundation

enum AppTheme: String {
    case light, dark
    
    var boolValue: Bool { self != .light }
}
