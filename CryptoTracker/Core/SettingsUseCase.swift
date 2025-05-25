//
//  SettingsUseCase.swift
//  CryptoTracker
//
//  Created by lil angee on 25.05.25.
//

import Foundation
import Combine

final class SettingsUseCase: CoinLoadingConfiguring {
    let coinLoadingConfiguration: CoinLoadingConfiguring
    
    init(coinLoadingConfiguration: CoinLoadingConfiguring) {
        self.coinLoadingConfiguration = coinLoadingConfiguration
    }
    
    func changeRefreshRate(to value: UInt8) {
        coinLoadingConfiguration.changeRefreshRate(to: value)
    }
}
