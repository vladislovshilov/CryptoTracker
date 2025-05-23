//
//  ViewModel.swift
//  CryptoTracker
//
//  Created by lil angee on 21.05.25.
//

import Foundation
import Combine

final class ViewModel: ViewModeling {
    
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
        
        observeRefreshRate()
        
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

            var updatedCryptos: [CryptoCurrency] = []

            for crypto in cryptos {
                if let newPrice = updated.first(where: { $0.id == crypto.id }) {
                    guard crypto.currentPrice != newPrice.currentPrice else {
                        return
                    }
                    var updatedItem = crypto
                    updatedItem.currentPrice = newPrice.currentPrice
                    updatedItem.priceChangePercentage24h = newPrice.priceChangePercentage24h
                    updatedCryptos.append(updatedItem)
                    print("updated price for \(crypto.name) is \(crypto.currentPrice)")
                } else {
                    updatedCryptos.append(crypto)
                }
            }

            cryptos = updatedCryptos
        } catch {
            print("Failed to update favorite prices: \(error.localizedDescription)")
        }
    }
    
    private func observeRefreshRate() {
        $cryptos
            .sink { [weak self] value in
                guard let self else { return }
                for i in stride(from: 0, to: value.count, by: 2) {
                    let fetched = value[i]
                    let fav = FavoriteCurrency(id: fetched.id, name: fetched.name, currentPrice: fetched.currentPrice)
                    storage.toggle(fav)
                }
            }
            .store(in: &cancellables)
    }
}
