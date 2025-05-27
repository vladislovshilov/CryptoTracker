//
//  ChartView.swift
//  CryptoTracker
//
//  Created by lil angee on 27.05.25.
//

import SwiftUI
import Charts

struct SwiftUIView: View {

    @StateObject var model: ChartModel
    
    var body: some View {
        VStack {
            Text("Chart View")
                .font(.headline)
            
            ZStack {
                if model.chartData.isEmpty {
                    Text("No data")
                } else {
                    Chart {
                        ForEach(model.chartData) { data in
                            LineMark(
                                x: .value("date", data.timestamp),
                                y: .value("price", data.price)
                            )
                        }
                    }
                    .chartYScale(
                        domain: (model.min...model.max)
                    )
                }
            }
        }
        .animation(.easeOut, value: model.chartData)
    }
}
