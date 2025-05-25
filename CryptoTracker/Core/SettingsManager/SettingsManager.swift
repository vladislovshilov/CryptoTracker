//
//  SettingsUseCase.swift
//  CryptoTracker
//
//  Created by lil angee on 25.05.25.
//

import UIKit
import Combine

final class SettingsManager: SettingsOberving, SettingsUseCasing {
    
    var refreshRate: CurrentValueSubject<UInt8, Never>
    var appTheme: CurrentValueSubject<AppTheme, Never>
    
    private var windows: [UIWindow?]
    private let coinLoadingConfiguration: CoinLoadingConfiguring
    
    init(windows: [UIWindow?], coinLoadingConfiguration: CoinLoadingConfiguring) {
        self.windows = windows
        self.coinLoadingConfiguration = coinLoadingConfiguration
        
        refreshRate = .init(UserSettings.refreshRate)
        appTheme = .init(AppTheme(rawValue: UserSettings.appTheme) ?? .light)
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
}
