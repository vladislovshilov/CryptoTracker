//
//  ChartPoints.swift
//  CryptoTracker
//
//  Created by lil angee on 27.05.25.
//

import Foundation

struct ChartPoint: Identifiable, Equatable {
    let timestamp: Date
    let price: Double
    
    var id: TimeInterval {
        timestamp.timeIntervalSince1970
    }
}
