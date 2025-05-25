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
    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    
    private lazy var networkService = NetworkService()
    private lazy var coinGekoAPI = CoinGeckoAPI(networkService: networkService)
    private lazy var storage = FavoritesStorage()
    private lazy var loadCoinsUseCase = LoadCoinsUseCase(service: coinGekoAPI)
    
    private var cancellables = Set<AnyCancellable>()

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func start() {
        let vm = ViewModel(useCase: loadCoinsUseCase, storage: storage)
        let vc: ViewController = storyboard.instantiateViewController(withIdentifier: .vc)
        vc.viewModel = vm
        
        vm.coinSelection
            .receive(on: DispatchQueue.main)
            .sink { [weak self] coin in
                self?.showDetails(for: coin)
            }
            .store(in: &cancellables)
        
        vc.didGetError
            .receive(on: DispatchQueue.main)
            .sink { [weak self] errorMessage in
                self?.navigationController.showAlert(title: "Error", message: errorMessage)
            }
            .store(in: &cancellables)
        
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
        let vc: FavouritesViewController = storyboard.instantiateViewController(withIdentifier: .favourites)
        vc.viewModel = vm
        
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
        
        vc.popVC = { [weak self] in
            self?.navigationController.popViewController(animated: true)
        }
        
        navigationController.pushViewController(vc, animated: true)
    }
    
    private func showFilters() {
        print("show filters")
    }
    
    private func showSettings() {
        print("show settings")
    }
    
    private func showDetails(for coin: any CryptoModel) {
        print("Need to show \(coin.name)")
        navigationController.showAlert(title: "\(coin.name) price ", message: "\(coin.currentPrice) | \(coin.marketCap ?? 0) | \(coin.totalVolume ?? 0)")
    }
}
