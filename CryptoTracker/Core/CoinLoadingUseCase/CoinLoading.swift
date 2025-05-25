//
//  ErrorRepresentable.swift
//  CryptoTracker
//
//  Created by lil angee on 25.05.25.
//

import Foundation
import Combine

protocol ErrorRepresentable {
    var errorMessage: String { get }
    var errorPublisher: CurrentValueSubject<String?, Never> { get }
}

protocol CoinLoadingConfiguring {
    func changeRefreshRate(to value: UInt8)
}

protocol CoinLoading: ErrorRepresentable {
    var coinsPublisher: CurrentValueSubject<[CryptoCurrency], Never> { get }
    
    func currentCoins() -> [CryptoCurrency]
    
    func load(force: Bool)
    func loadNextPage()
    func refresh()
    func refreshPrices(force: Bool)
}
