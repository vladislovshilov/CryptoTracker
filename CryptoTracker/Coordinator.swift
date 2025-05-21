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

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func start() {
        let vc: ViewController = storyboard.instantiateViewController(withIdentifier: .vc)
        
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
        
        let vm = ViewModel()
        vm.counter = "asdasd"
        vc.viewModel = vm
        
        navigationController.pushViewController(vc, animated: true)
    }
    
    private func showFavourites() {
        let vc: FavouritesViewController = storyboard.instantiateViewController(withIdentifier: .favourites)
        navigationController.pushViewController(vc, animated: true)
    }
    
    private func showFilters() {
        print("show filters")
    }
    
    private func showSettings() {
        print("show settings")
    }
}
