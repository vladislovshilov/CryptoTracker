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

protocol SettingsOberving {
    var refreshRate: CurrentValueSubject<UInt8, Never> { get }
    var appTheme: CurrentValueSubject<AppTheme, Never> { get }
}

typealias SettingsUseCasing = CoinLoadingConfiguring & AppThemeConfiguring
