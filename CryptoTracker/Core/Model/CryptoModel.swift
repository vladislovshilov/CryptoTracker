//
//  CryptoModel.swift
//  CryptoTracker
//
//  Created by lil angee on 24.05.25.
//

import Foundation

protocol CryptoModel: Codable, Identifiable {
    var id: String { get }
    var name: String { get }
    var currentPrice: Double { get set }
}
