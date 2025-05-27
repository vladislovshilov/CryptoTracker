//
//  ChartModel.swift
//  CryptoTracker
//
//  Created by lil angee on 27.05.25.
//

import Foundation

@MainActor
final class ChartModel: ObservableObject {
    @Published var min: Double = 0
    @Published var max: Double = 0
    @Published var chartData: [ChartPoint] = []
}

@MainActor
struct ChartModelProxy {
    var min: Double = 0
    var max: Double = 0
    var chartData: [ChartPoint] = []
    
    init(model: ChartModel) {
        min = model.min
        max = model.max
        chartData = model.chartData
    }
}
