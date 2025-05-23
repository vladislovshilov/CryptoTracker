//
//  Coordinator.swift
//  CryptoTracker
//
//  Created by lil angee on 21.05.25.
//

import UIKit

enum VCNames: String {
    case vc = "ViewController"
    case favourites = "FavouritesViewController"
    
    var identifier: String { rawValue }
}

class Coordinator {
    let navigationController: UINavigationController
    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    
    private lazy var networkService = NetworkService()
    private lazy var coinGekoAPI = CoinGeckoAPI(networkService: networkService)
    private lazy var storage = FavoritesStorage()

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func start() {
        let vm = ViewModel(api: coinGekoAPI, storage: storage)
        vm.counter = "asdasd"
        let vc: ViewController = storyboard.instantiateViewController(withIdentifier: .vc)
        vc.viewModel = vm
        
        vc.onFavouritesButtonTap = { [weak self] in
            guard let self = self else { return }
            showFavourites()
        }
        
        vc.onFilterTap = { [weak self] in
            guard let self = self else { return }
            showFilters()
        }
        
        vc.onSettingsButtonTap = { [weak self] in
            guard let self = self else { return }
            showSettings()
        }
        
        navigationController.pushViewController(vc, animated: true)
    }
    
    private func showFavourites() {
        let vm = FavouriteViewModel(storage: storage, service: coinGekoAPI)
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
        print("show settings")
    }
}
