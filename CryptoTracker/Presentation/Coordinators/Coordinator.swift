//
//  Coordinator.swift
//  CryptoTracker
//
//  Created by lil angee on 21.05.25.
//

import UIKit
import Combine

class Coordinator {
    
    let navigationController: UINavigationController
    private let windows: [UIWindow?]
    
    private let storyboard = UIStoryboard(name: "Main", bundle: nil)
    
    private lazy var networkService = NetworkService()
    private lazy var coinGekoAPI = CoinGeckoAPI(networkService: networkService)
    private lazy var storage = FavoritesStorage()
    private lazy var loadCoinsUseCase = LoadCoinsUseCase(service: coinGekoAPI)
    private lazy var settingsService = SettingsManager(windows: windows, coinLoadingConfiguration: loadCoinsUseCase)
    
    private var cancellables = Set<AnyCancellable>()

    init(windows: [UIWindow?], navigationController: UINavigationController) {
        self.windows = windows
        self.navigationController = navigationController
        settingsService.changeAppTheme(to: AppTheme(rawValue: UserSettings.appTheme) ?? .light)
    }

    func start() {
        let vm = ViewModel(useCase: loadCoinsUseCase, storage: storage)
        vm.coinSelection
            .receive(on: DispatchQueue.main)
            .sink { [weak self] coin in
                self?.showDetails(for: coin)
            }
            .store(in: &cancellables)
        
        vm.errorMessage
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] errorMessage in
                self?.navigationController.showAlert(title: "Error", message: errorMessage)
            }
            .store(in: &cancellables)
        
        let vc: ViewController = storyboard.instantiateViewController(withIdentifier: .vc)
        vc.viewModel = vm
        
        vc.filterTap
            .receive(on: DispatchQueue.main)
            .sink { [weak self] errorMessage in
                self?.showFilters()
            }
            .store(in: &cancellables)
        
        vc.favouriteTap
            .receive(on: DispatchQueue.main)
            .sink { [weak self] errorMessage in
                self?.showFavourites()
            }
            .store(in: &cancellables)
        
        vc.settingsTap
            .receive(on: DispatchQueue.main)
            .sink { [weak self] errorMessage in
                self?.showSettings()
            }
            .store(in: &cancellables)
        
        navigationController.pushViewController(vc, animated: true)
    }
    
    private func showFavourites() {
        let vm = FavouriteViewModel(useCase: loadCoinsUseCase, storage: storage)
        vm.coinSelection
            .receive(on: DispatchQueue.main)
            .sink { [weak self] coin in
                self?.showDetails(for: coin)
            }
            .store(in: &cancellables)
        
        vm.errorMessage
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] errorMessage in
                self?.navigationController.showAlert(title: "Error", message: errorMessage)
            }
            .store(in: &cancellables)
        
        let vc: FavouritesViewController = storyboard.instantiateViewController(withIdentifier: .favourites)
        vc.viewModel = vm
        
        vc.popVC = { [weak self] in
            self?.navigationController.popViewController(animated: true)
        }
        
        navigationController.pushViewController(vc, animated: true)
    }
    
    private func showFilters() {
        print("show filters")
    }
    
    private func showSettings() {
        let viewModel = SettingsViewModel(useCase: settingsService)
        let viewController: SettingsViewController = storyboard.instantiateViewController(withIdentifier: .settings)
        viewController.viewModel = viewModel
        navigationController.pushViewController(viewController, animated: true)
    }
    
    private func showDetails(for coin: any CryptoModel) {
        print("Need to show \(coin.name)")
        navigationController.showAlert(title: "\(coin.name) price ", message: "\(coin.currentPrice) | \(coin.marketCap ?? 0) | \(coin.totalVolume ?? 0)")
    }
}
