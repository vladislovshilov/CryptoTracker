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
    private var cancellables = Set<AnyCancellable>()
    
    private var task: Task<Void, Never>?
    
    init(api: CoinGeckoAPI = CoinGeckoAPI()) {
        self.api = api
        
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
            let fetchedCtyptos = try await api.fetchCryptos(page: currentPage, perPage: perPage)
            
//            let filteredCryptos = cryptos.filter {
//                $0.name.lowercased().contains(filterText.lowercased()) ||
//                $0.symbol.lowercased().contains(filterText.lowercased())
//            }
            
            isLoading = false
            cryptos = fetchedCtyptos
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
                    guard crypto.currentPrice < newPrice.currentPrice else {
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
    
    
    
    func fetchAllPages() async {
        let urls = ["page1", "page2", "page3"]

        await withTaskGroup(of: String.self) { group in
            for url in urls {
                group.addTask {
                    return url
                }
            }

            for await page in group {
                print("Received: \(page)")
                counter = page
            }
        }
    }
    
    private func fetchAllArticles() async {
        let sources = ["cnn.com", "bbc.com", "reuters.com"]

        await withTaskGroup(of: String.self) { group in
            counter = "loading"
//            var i: UInt32 = 1
//            for source in sources {
//                group.addTask {
//                    // Simulate fetching article from a source
//                    sleep(2)
////                    i += 20
//                    print(i)
//                    return "Article from \(source)"
//                }
//            }
            
            group.addTask {
                sleep(1)
                return "1"
            }
            
            group.addTask {
                sleep(3)
                return "3"
            }
            
            group.addTask {
                sleep(5)
                return "5"
            }
            

            for await article in group {
                print(article)
                counter = article
            }
            
            
        }
    }
}
