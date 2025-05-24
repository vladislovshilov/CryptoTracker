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
    @Published var refreshRate: UInt8 = 60
    @Published var isLoading = false
    @Published var filterText: String = ""
    @Published var errorMessage: String?
    
    let minRefreshRate: UInt8 = 60
    let maxRefreshRate: UInt8 = 255
    
    private let coinService: CoinGeckoAPI
    private let storage: FavoritesStorageProtocol
    
    private var cancellables = Set<AnyCancellable>()
    private var refreshTask: Task<Void, Never>?
    private var refreshTimer: AnyCancellable?
    
    
    init(storage: FavoritesStorageProtocol, service: CoinGeckoAPI) {
        self.storage = storage
        self.coinService = service
        
        storage.favoritesPublisher
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .sink { [weak self] coins in
                self?.fetchFavoritesInfo(for: coins)
            }
            .store(in: &cancellables)
        
        $refreshRate
            .dropFirst()
            .removeDuplicates()
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .sink { [weak self] value in
                self?.startAutoRefresh()
            }
            .store(in: &cancellables)
    }
    
    func onAppear() {
        startAutoRefresh()
    }
    
    func onDisappear() {
        refreshTask?.cancel()
    }
    
    func isFavorite(_ coin: FavoriteCurrency) -> Bool {
        return storage.isFavorite(coin)
    }
    
    func toggleFavorite(for coin: FavoriteCurrency) {
        storage.toggle(coin)
    }
    
    func loadNextPage() {
        print("should load next page")
    }
    
    func reload() {
        fetchFavoritesInfo(for: Set(favoriteCoins))
    }
    
    private func fetchFavoritesInfo(for favorites: Set<FavoriteCurrency>) {
        let ids = favorites.map { $0.id }
        refreshTask = Task {
            do {
                try Task.checkCancellation()
                isLoading = true
                let updated = try await coinService.fetchPrices(for: ids)
                logUpdated(updated, for: favorites.map { $0 })
                favoriteCoins = updated.map { .init(id: $0.id, name: $0.name, currentPrice: $0.currentPrice) }
            } catch {
                print("Failed to update favorite coins: \(error)")
            }
            isLoading = false
        }
    }
    
    private func startAutoRefresh() {
        refreshTask?.cancel()
        refreshTimer?.cancel()
        refreshTimer = Timer
            .publish(every: TimeInterval(refreshRate), on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self else { return }
                fetchFavoritesInfo(for: storage.allFavorites())
            }
    }
}
