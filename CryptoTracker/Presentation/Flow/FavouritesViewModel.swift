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
    let errorMessage = PassthroughSubject<String, Never>()
    
    private let useCase: CoinLoading
    private let storage: FavoritesStoring
    
    private var cancellables = Set<AnyCancellable>()
    
    init(useCase: CoinLoading, storage: FavoritesStoring) {
        self.storage = storage
        self.useCase = useCase
        
        storage.favoritesPublisher
            .dropFirst()
//            .removeDuplicates()
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .sink { [weak self] coins in
                self?.useCase.load(force: true)
            }
            .store(in: &cancellables)
    }
    
    func onAppear() {
        bindUseCase()
    }
    
    func onDisappear() {
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
    
    func loadNextPage() {
//        useCase.loadNextPage()
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
        useCase.coinsPublisher
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
                self?.errorMessage.send(errorMessage ?? "no error")
                self?.isLoading = false
            }
            .store(in: &cancellables)
    }
    
    private func unbindUseCase() {
        cancellables.removeAll()
    }
}
