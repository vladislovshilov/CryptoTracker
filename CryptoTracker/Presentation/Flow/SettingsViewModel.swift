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
    @Published var appThemeOn: Bool = (AppTheme(rawValue: UserSettings.appTheme) ?? .light) == .dark
    
    let minRefreshRate: UInt8 = UserSettings.minRefreshRate
    let maxRefreshRate: UInt8 = UInt8.max
    
    private let useCase: SettingsUseCasing
    
    private var cancellables = Set<AnyCancellable>()
    
    init(useCase: SettingsUseCasing) {
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
    
    func toggleAppTheme() {
        useCase.changeAppTheme(to: appThemeOn ? .light : .dark)
        appThemeOn.toggle()
    }
    
    func cleanUserDefaults() {
        useCase.clearUserDefaults()
    }
}
