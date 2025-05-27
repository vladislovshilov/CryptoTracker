//
//  FavouriteCurrency.swift
//  CryptoTracker
//
//  Created by lil angee on 24.05.25.
//

import Foundation

struct FavoriteCurrency: CryptoModel {
    let id: String
    let name: String
    let marketCap: Double?
    var currentPrice: Double
    let totalVolume: Double?
    
    func toCryptoCurrency() -> CryptoCurrency {
        .init(id: id, symbol: "", name: name, image: "", currentPrice: currentPrice, marketCap: marketCap, marketCapRank: nil, totalVolume: totalVolume)
    }
}

