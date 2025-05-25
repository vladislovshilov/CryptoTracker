//
//  SettingsViewModel.swift
//  CryptoTracker
//
//  Created by lil angee on 25.05.25.
//

import Foundation
import Combine

final class SettingsViewModel: ViewModeling {
    @Published var refreshRate: TimeInterval = TimeInterval(UserSettings.refreshRate)
    
    let minRefreshRate: UInt8 = UserSettings.minRefreshRate
    let maxRefreshRate: UInt8 = UInt8.max
    
    private let useCase: SettingsUseCase
    
    private var cancellables = Set<AnyCancellable>()
    
    init(useCase: SettingsUseCase) {
        self.useCase = useCase
        
        $refreshRate
            .dropFirst()
            .removeDuplicates()
            .debounce(for: .milliseconds(1000), scheduler: RunLoop.main)
            .sink { value in
                useCase.changeRefreshRate(to: UInt8(value))
            }
            .store(in: &cancellables)
    }
}
