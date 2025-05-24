//
//  ViewModel.swift
//  CryptoTracker
//
//  Created by lil angee on 21.05.25.
//

import Foundation
import Combine

final class ViewModel: ViewModeling, PriceLogging {
    
    @Published var counter: String = "empty"
    
    @Published private(set) var cryptos: [CryptoCurrency] = []
    @Published var filterText: String = ""
    @Published var errorMessage: String?
    @Published var isLoading = false
    
    var onCoinSelected: ((CryptoCurrency) -> Void)?
    
    private var currentPage = 1
    private let perPage = 20
    private var canLoadMore = true
    
    private let api: CoinGeckoAPI
    private let storage: FavoritesStorageProtocol
    private var cancellables = Set<AnyCancellable>()
    
    private var task: Task<Void, Never>?
    private var refreshTask: Task<Void, Never>?
    
    init(api: CoinGeckoAPI = CoinGeckoAPI(), storage: FavoritesStorageProtocol) {
        self.api = api
        self.storage = storage
        
        task = Task {
            await fetchCryptos(reset: false)
        }
    }
    
    func onAppear() {
        // TODO: - Update only price
        task = Task {
            await refreshPrices(reset: false)
        }
    }
    
    func onDisappear() {
        task?.cancel()
        refreshTask?.cancel()
    }
    
    func selectCoin(at index: Int) {
        guard cryptos.indices.contains(index) else { return }
        let coin = cryptos[index]
        onCoinSelected?(coin)
    }
    
    private func fetchCryptos(reset: Bool = false) async {
        guard !isLoading && canLoadMore else { return }
        if reset {
            currentPage = 1
            canLoadMore = true
        }
        isLoading = true
        errorMessage = nil
        
        do {
            try await Task.sleep(for: .seconds(3))
            let fetchedCryptos = try await api.fetchCryptos(page: currentPage, perPage: perPage)
            
//            let filteredCryptos = cryptos.filter {
//                $0.name.lowercased().contains(filterText.lowercased()) ||
//                $0.symbol.lowercased().contains(filterText.lowercased())
//            }
            
            isLoading = false
            cryptos = fetchedCryptos
            
            populateFavourites()
        } catch {
            isLoading = false
            print("smh wrong: \(error.localizedDescription)")
            errorMessage = error.localizedDescription
        }
    }
    
    private func refreshPrices(reset: Bool) async {
        guard !cryptos.isEmpty else { return }
        
        do {
            let ids = cryptos.map { $0.id }
            let updated = try await api.fetchPrices(for: ids)
            logUpdated(updated, for: cryptos)
            cryptos = updated
        } catch {
            print("Failed to update favorite prices: \(error.localizedDescription)")
        }
    }
    
    private func populateFavourites() {
        for i in stride(from: 0, to: cryptos.count, by: 2) {
            let fetched = cryptos[i]
            let fav = FavoriteCurrency(id: fetched.id, name: fetched.name, currentPrice: fetched.currentPrice)
            storage.toggle(fav)
        }
    }
}
