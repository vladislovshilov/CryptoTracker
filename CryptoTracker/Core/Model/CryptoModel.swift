//
//  CryptoModel.swift
//  CryptoTracker
//
//  Created by lil angee on 24.05.25.
//

import Foundation

protocol CryptoModel: Codable, Identifiable, Hashable {
    var id: String { get }
    var name: String { get }
    var currentPrice: Double { get set }
    var marketCap: Double? { get }
    var totalVolume: Double? { get }
}
