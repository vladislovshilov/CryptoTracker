//
//  ErrorRepresentable.swift
//  CryptoTracker
//
//  Created by lil angee on 25.05.25.
//

import Foundation
import Combine

protocol ErrorRepresentable {
    var errorPublisher: CurrentValueSubject<String?, Never> { get }
}

protocol CoinLoadingConfiguring {
    func changeRefreshRate(to value: UInt8)
}

protocol CoinLoading: ErrorRepresentable {
    var isLoading: Bool { get }
    var coinsPublisher: CurrentValueSubject<[CryptoCurrency], Never> { get }
    
    func currentCoins() -> [CryptoCurrency]
    
    func load(force: Bool, isBackground: Bool)
    func loadNextPage()
    func refresh(isBackground: Bool)
    func refreshPrices(for ids: [String], force: Bool, isBackground: Bool)
}

extension CoinLoading {
    func load(force: Bool = false, isBackground: Bool = false) {
        load(force: force, isBackground: isBackground)
    }
    
    func refreshPrices(for ids: [String] = [], force: Bool = false, isBackground: Bool = false) {
        refreshPrices(for: ids, force: force, isBackground: isBackground)
    }
}
