//
//  CryptoModel.swift
//  CryptoTracker
//
//  Created by lil angee on 24.05.25.
//

import Foundation

protocol CryptoModel: Codable, Identifiable, Hashable, Equatable {
    var id: String { get }
    var name: String { get }
    var currentPrice: Double { get set }
    var marketCap: Double? { get }
    var totalVolume: Double? { get }
    var isStableCoin: Bool { get }
}

extension CryptoModel {
    var isStableCoin: Bool {
        id == "usd-coin" || id == "tether" || id == "ethereum"
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id) 
    }
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        print("Comparing \(lhs.id) and \(rhs.id)")
        return lhs.id == rhs.id
    }
}
