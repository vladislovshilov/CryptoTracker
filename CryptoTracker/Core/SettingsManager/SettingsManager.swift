//
//  SettingsUseCase.swift
//  CryptoTracker
//
//  Created by lil angee on 25.05.25.
//

import UIKit
import Combine

final class SettingsManager: SettingsOberving, SettingsService {
    
    var sortOption:  CurrentValueSubject<SortOption, Never>
    var refreshRate: CurrentValueSubject<UInt8, Never>
    var appTheme: CurrentValueSubject<AppTheme, Never>
    
    private var windows: [UIWindow?]
    private let coinLoadingConfiguration: CoinLoadingConfiguring
    private let storage: FavoritesStoring
    
    init(windows: [UIWindow?], coinLoadingConfiguration: CoinLoadingConfiguring, storage: FavoritesStoring) {
        self.windows = windows
        self.coinLoadingConfiguration = coinLoadingConfiguration
        self.storage = storage
        
        sortOption = .init(.init(rawValue: Int(UserSettings.sortOption)) ?? .price)
        refreshRate = .init(UserSettings.refreshRate)
        appTheme = .init(AppTheme(rawValue: UserSettings.appTheme) ?? .light)
    }
    
    func changeSortOption(option: SortOption) {
        UserSettings.sortOption = UInt8(option.rawValue)
        sortOption.send(option)
    }
    
    func changeRefreshRate(to value: UInt8) {
        coinLoadingConfiguration.changeRefreshRate(to: value)
        refreshRate.send(value)
    }
    
    func changeAppTheme(to theme: AppTheme) {
        UserSettings.appTheme = theme.rawValue
        appTheme.send(theme)
        
        switch theme {
        case .light:
            windows.forEach { $0?.overrideUserInterfaceStyle = .light }
        case .dark:
            windows.forEach { $0?.overrideUserInterfaceStyle = .dark }
        }
    }
    
    func clearUserDefaults() {
        storage.removeAll()
    }
}
