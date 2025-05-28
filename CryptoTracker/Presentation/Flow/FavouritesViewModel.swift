//
//  FavouritesViewModel.swift
//  CryptoTracker
//
//  Created by lil angee on 24.05.25.
//

import Foundation
import Combine

final class FavouriteViewModel: ViewModeling, PriceLogging {
    
    @Published private(set) var favoriteCoins: [FavoriteCurrency] = []
    @Published var isLoading = false
    @Published var filterText: String = ""
    
    let coinSelection = PassthroughSubject<any CryptoModel, Never>()
    
    private let useCase: CoinLoading
    private let storage: FavoritesStoring
    private let settingsObserving: SettingsOberving
    
    private var cancellables = Set<AnyCancellable>()
    
    init(useCase: CoinLoading, storage: FavoritesStoring, settingsObserving: SettingsOberving) {
        self.storage = storage
        self.useCase = useCase
        self.settingsObserving = settingsObserving
        
        bindUseCase()
        
        storage.favoritesPublisher
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .sink { [weak self] coins in
                self?.favoriteCoins = Array(coins)
                self?.useCase.load(force: true, isBackground: true)
            }
            .store(in: &cancellables)
    }
    
    deinit {
        unbindUseCase()
    }
    
    func selectCoin(at index: Int) {
        if let coin = favoriteCoins[safe: index] {
            coinSelection.send(coin)
        }
    }
    
    func isFavorite(_ coin: FavoriteCurrency) -> Bool {
        return storage.isFavorite(coin)
    }
    
    func toggleFavorite(for coin: FavoriteCurrency) {
        storage.toggle(coin)
    }
    
    func reload() {
        isLoading = true
        if favoriteCoins.isEmpty {
            useCase.load(force: true)
        } else {
            useCase.refreshPrices(force: true)
        }
    }
    
    private func bindUseCase() {
        isLoading = useCase.isLoading
        
        useCase.coinsPublisher
            .sorted(by: settingsObserving.sortOption.eraseToAnyPublisher())
            .filter { !$0.isEmpty }
            .combineLatest(storage.favoritesPublisher)
            .map { coins, favorites -> [FavoriteCurrency] in
                coins
                    .filter { coin in
                        favorites.contains(where: { $0.id == coin.id })
                    }
                    .map { $0.toFavouriteModel() }
            }
            .sink(receiveValue: { [weak self] coins in
                self?.favoriteCoins = coins
                self?.isLoading = false
            })
            .store(in: &cancellables)
        
        
        useCase.errorPublisher
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .sink { [weak self] errorMessage in
                self?.isLoading = false
            }
            .store(in: &cancellables)
    }
    
    private func unbindUseCase() {
        cancellables.removeAll()
    }
}
