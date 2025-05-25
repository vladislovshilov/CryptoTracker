//
//  CoinLoadingUseCase.swift
//  CryptoTracker
//
//  Created by lil angee on 25.05.25.
//

import Foundation
import Combine

final class LoadCoinsUseCase: CoinLoading, CoinLoadingConfiguring, PriceLogging {
    
    var errorMessage: String = "" {
        didSet {
            errorPublisher.send(error?.errorDescription ?? errorMessage)
        }
    }

    var coinsPublisher = CurrentValueSubject<[CryptoCurrency], Never>([])
    var errorPublisher = CurrentValueSubject<String?, Never>(nil)
    
    private let queue = DispatchQueue(label: "coins.queue")
    
    private(set) var currentPage = 0
    private var bunchAmount = 20
    private var canLoadMore = true
    
    private var coins: [CryptoCurrency] = []
    private var lastLoadedAt: Date?
    private var lastPriceUpdateAt: Date?
    private var error: NetworkError?
    
    private let coinService: CoinGeckoAPI
    
    private var refreshTask: Task<Void, Never>?
    private var refreshTimer: AnyCancellable?
    
    init(service: CoinGeckoAPI) {
        self.coinService = service
        startAutoRefresh()
    }
    
    deinit {
        refreshTimer?.cancel()
        refreshTask?.cancel()
        refreshTask = nil
        refreshTimer = nil
    }
    
    // MARK: CoinLoading

    func currentCoins() -> [CryptoCurrency] {
        var result: [CryptoCurrency] = []
        queue.sync {
            result = self.coins
        }
        return result
    }
    
    func load(force: Bool = false) {
        let now = Date()
        guard force || lastLoadedAt == nil || UInt8(now.timeIntervalSince(lastLoadedAt!)) > UserSettings.refreshRate else {
            coinsPublisher.send(coins)
            return
        }
        
        refreshTask?.cancel()
        refreshTask = nil
        refreshTask = Task {
            await fetchCoins()
        }
    }
    
    func loadNextPage() {
        currentPage += 1
        load(force: true)
    }
    
    func refresh() {
        load(force: true)
    }
    
    func refreshPrices(force: Bool = false) {
        guard !coins.isEmpty else { return }
        
        let now = Date()
        guard force || lastPriceUpdateAt == nil || UInt8(now.timeIntervalSince(lastPriceUpdateAt!)) > UserSettings.refreshRate else {
            return
        }
        
        refreshTask?.cancel()
        refreshTask = nil
        refreshTask = Task {
            do {
                try Task.checkCancellation()
                print("Refreshin only prices")
                
                let ids = coins.map { $0.id }
                let updated = try await coinService.fetchPrices(for: ids)
                coins = updated
                coinsPublisher.send(coins)
                
                lastPriceUpdateAt = Date()
                logUpdated(updated, for: coins)
            } catch {
                print("and getting error")
                self.error = error as? NetworkError ?? .unknown
                errorMessage = "Failed to update prices: \(error)"
            }
        }
    }
    
    func changeRefreshRate(to value: UInt8) {
        UserSettings.refreshRate = UInt8(value)
        stopAutoRefresh()
        startAutoRefresh()
    }
}

// MARK: - Helpers

extension LoadCoinsUseCase {
    private func fetchCoins() async {
        do {
            try Task.checkCancellation()
            print("Fetch coins")
            let newCoins = try await coinService.fetchCryptos(page: currentPage, perPage: bunchAmount)
            coins = newCoins
            coinsPublisher.send(coins)
            
            lastLoadedAt = Date()
            logUpdated(coins, for: coins.map { $0 })
        } catch {
            print("and getting error")
            self.error = error as? NetworkError ?? .unknown
            errorMessage = "Failed to update coins: \(error)"
        }
    }
}

// MARK: - Auto Refresh

extension LoadCoinsUseCase {
    private func startAutoRefresh() {
        print("\(UserSettings.refreshRate)")
        refreshTimer = Timer
            .publish(every: TimeInterval(UserSettings.refreshRate), on: .current, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                if self?.coins.isEmpty ?? true {
                    self?.refresh()
                } else {
                    self?.refreshPrices()
                }
            }
    }
    
    private func stopAutoRefresh() {
        refreshTimer?.cancel()
        refreshTimer = nil
    }
}
