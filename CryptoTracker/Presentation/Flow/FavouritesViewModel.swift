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
    @Published var refreshRate: TimeInterval = TimeInterval(UserSettings.refreshRate)
    @Published var isLoading = false
    @Published var filterText: String = ""
    
    let coinSelection = PassthroughSubject<any CryptoModel, Never>()
    let errorMessage = PassthroughSubject<String, Never>()
    
    let minRefreshRate: UInt8 = 6
    let maxRefreshRate: UInt8 = UInt8.max
    
    private let useCase: LoadCoinsUseCase
    private let storage: FavoritesStorageProtocol
    
    private var cancellables = Set<AnyCancellable>()
    
    init(useCase: LoadCoinsUseCase, storage: FavoritesStorageProtocol) {
        self.storage = storage
        self.useCase = useCase
        
        storage.favoritesPublisher
            .dropFirst()
            .removeDuplicates()
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .sink { [weak self] coins in
                self?.useCase.load(force: true)
            }
            .store(in: &cancellables)
        
        $refreshRate
            .dropFirst()
            .removeDuplicates()
            .debounce(for: .milliseconds(1000), scheduler: RunLoop.main)
            .sink { value in
                useCase.changeRefreshRate(to: UInt8(value))
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
