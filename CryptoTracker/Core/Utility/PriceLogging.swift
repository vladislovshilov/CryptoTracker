//
//  PriceLogging.swift
//  CryptoTracker
//
//  Created by lil angee on 24.05.25.
//

import Foundation

protocol PriceLogging {
    func logUpdated(_ updated: [CryptoCurrency], for models: [any CryptoModel])
}

extension PriceLogging {
    func logUpdated(_ updated: [CryptoCurrency], for models: [any CryptoModel]) {
        var hasUpdate = false
        for model in models {
            if let newPrice = updated.first(where: { $0.id == model.id })?.currentPrice {
                guard model.currentPrice != newPrice else { continue }
                print("\(model.name) \(model.currentPrice) -> \(newPrice)")
                hasUpdate = true
            }
        }
        if !hasUpdate {
            print("no updates\n")
        } else {
            print("Prices update \(Date()):")
            print("\n")
        }
    }
}
