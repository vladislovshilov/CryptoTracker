//
//  CryptoCurrency.swift
//  CryptoTracker
//
//  Created by lil angee on 23.05.25.
//

import Foundation

struct CryptoCurrency: CryptoModel {
    let id: String
    let symbol: String
    let name: String
    let image: String
    var currentPrice: Double
    let marketCap: Double?
    let marketCapRank: Int?
    let totalVolume: Double?
    var priceChangePercentage24h: Double?

    enum CodingKeys: String, CodingKey {
        case id, symbol, name, image
        case currentPrice = "current_price"
        case marketCap = "market_cap"
        case marketCapRank = "market_cap_rank"
        case totalVolume = "total_volume"
        case priceChangePercentage24h = "price_change_percentage_24h"
    }
}
