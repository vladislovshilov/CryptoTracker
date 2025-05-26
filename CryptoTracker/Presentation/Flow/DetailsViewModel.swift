//
//  DetailsViewModel.swift
//  CryptoTracker
//
//  Created by lil angee on 26.05.25.
//

import Foundation

final class DetailsViewModel: ViewModeling {
    
    @Published var title: String = ""
    @Published var price: String = ""
    @Published var data: [MonthlyHoursOfSunshine] = [
        MonthlyHoursOfSunshine(month: 1, hoursOfSunshine: 74),
        MonthlyHoursOfSunshine(month: 2, hoursOfSunshine: 99),
        MonthlyHoursOfSunshine(month: 3, hoursOfSunshine: 11),
        MonthlyHoursOfSunshine(month: 4, hoursOfSunshine: 62),
        MonthlyHoursOfSunshine(month: 5, hoursOfSunshine: 68),
        MonthlyHoursOfSunshine(month: 6, hoursOfSunshine: 44),
        MonthlyHoursOfSunshine(month: 7, hoursOfSunshine: 55),
        MonthlyHoursOfSunshine(month: 8, hoursOfSunshine: 88),
        MonthlyHoursOfSunshine(month: 12, hoursOfSunshine: 99)
    ]
    
    init(title: String, price: String) {
        self.title = title
        self.price = price
    }
    
    func onAppear() {
        
    }
    
    func onDisappear() {
        
    }
}
