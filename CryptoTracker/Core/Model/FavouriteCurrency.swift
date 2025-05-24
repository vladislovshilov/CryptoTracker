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
    var currentPrice: Double
}
