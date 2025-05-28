//
//  SettingsUseCasing.swift
//  CryptoTracker
//
//  Created by lil angee on 25.05.25.
//

import Foundation
import Combine

protocol AppThemeConfiguring {
    func changeAppTheme(to theme: AppTheme)
}

protocol UserDefaultsCleaning {
    func clearUserDefaults()
}

protocol SettingsOberving {
    var sortOption: CurrentValueSubject<SortOption, Never> { get }
    var refreshRate: CurrentValueSubject<UInt8, Never> { get }
    var appTheme: CurrentValueSubject<AppTheme, Never> { get }
}

typealias SettingsService = CoinLoadingConfiguring & AppThemeConfiguring & UserDefaultsCleaning
