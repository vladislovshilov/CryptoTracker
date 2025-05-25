//
//  ViewModel.swift
//  CryptoTracker
//
//  Created by lil angee on 21.05.25.
//

import Foundation
import Combine

final class ViewModel: ViewModeling, PriceLogging {
    
    @Published private(set) var cryptos: [CryptoCurrency] = []
    @Published var filterText: String = ""
    @Published var isLoading = false
    
    let coinSelection = PassthroughSubject<CryptoCurrency, Never>()
    let errorMessage = PassthroughSubject<String, Never>()
    
//    private var currentPage = 1
//    private let perPage = 20
    
    private let useCase: CoinLoading
    private let storage: FavoritesStoring
    
    private var cancellables = Set<AnyCancellable>()
    
    init(useCase: CoinLoading, storage: FavoritesStoring) {
        self.useCase = useCase
        self.storage = storage
    }
    
    func onAppear() {
        bindUseCase()
        cryptos = Array(useCase.currentCoins())
    }
    
    func onDisappear() {
        unbindUseCase()
    }
    
    func selectCoin(at index: Int) {
        guard cryptos.indices.contains(index) else { return }
        let coin = cryptos[index]
        coinSelection.send(coin)
    }
    
    private func bindUseCase() {
        useCase.coinsPublisher
            .sink { [weak self] coins in
                self?.cryptos = Array(coins)
                self?.populateFavouritesIfNeeded()
                self?.isLoading = false
            }
            .store(in: &cancellables)
        
        useCase.errorPublisher
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .sink { [weak self] errorMessage in
                self?.errorMessage.send(errorMessage ?? "no error")
                self?.isLoading = false
            }
            .store(in: &cancellables)
    }
    
    private func unbindUseCase() {
        cancellables.removeAll()
    }
}

// MARK: Temp

extension ViewModel {
    private func populateFavouritesIfNeeded() {
        if storage.allFavorites().isEmpty {
            for i in stride(from: 0, to: cryptos.count, by: 2) {
                let fetched = cryptos[i]
                storage.toggle(fetched.toFavouriteModel())
            }
        }
    }
}
