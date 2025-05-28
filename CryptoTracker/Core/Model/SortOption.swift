//
//  SortOption.swift
//  CryptoTracker
//
//  Created by lil angee on 27.05.25.
//

import Foundation

enum SortOption: Int {
    case price = 0
    case volume
    case mostGainers
    case mostLoosers
    
    func sort(_ lhs: CryptoCurrency, _ rhs: CryptoCurrency) -> Bool {
        switch self {
        case .price: return lhs.currentPrice > rhs.currentPrice
        case .volume: return (lhs.totalVolume ?? 0) > (rhs.totalVolume ?? 0)
        case .mostGainers: return (lhs.priceChangePercentage24h ?? 0) > (rhs.priceChangePercentage24h ?? 0)
        case .mostLoosers: return (lhs.priceChangePercentage24h ?? 0) < (rhs.priceChangePercentage24h ?? 0)
        }
    }
}
