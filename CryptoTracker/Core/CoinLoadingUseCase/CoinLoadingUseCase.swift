//
//  CoinLoadingUseCase.swift
//  CryptoTracker
//
//  Created by lil angee on 25.05.25.
//

import Foundation
import Combine

///
/// Этот сервис используется как единый source of truth для получения списка монет
/// Дополнительно инкапсулирует в себя автоматическое обновление как всего списка, так и цен (fetch по ids)
/// *coinsPublisher* каждый раз эмитит новые значения, вью модели слушают его
///

final class LoadCoinsUseCase: CoinLoading, CoinLoadingConfiguring, PriceLogging {
    
    var isLoading = false

    var coinsPublisher = CurrentValueSubject<[CryptoCurrency], Never>([])
    var errorPublisher = CurrentValueSubject<String?, Never>(nil)
    
    private let queue = DispatchQueue(label: "coins.queue")
    
    private let coinService: CoinGeckoAPI
    
    private var coins: Set<CryptoCurrency> = []
    private var lastLoadedAt: Date?
    private var lastPriceUpdateAt: Date?
    private var error: NetworkError?
    
    private(set) var currentPage = 0
    private var bunchAmount = 20
    private var canLoadMore = true

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
            result = Array(self.coins)
        }
        return result
    }
    
    func load(force: Bool = false, isBackground: Bool = false) {
        let now = Date()
        guard force || lastLoadedAt == nil || now.timeIntervalSince(lastLoadedAt!) > TimeInterval(UserSettings.refreshRate) else {
            coinsPublisher.send(Array(coins))
            return
        }
        
        refreshTask?.cancel()
        refreshTask = nil
        refreshTask = Task {
            await fetchCoins(isBackground: isBackground)
        }
    }
    
    func loadNextPage() {
        currentPage += 1
        load(force: true, isBackground: true)
    }
    
    func refresh(isBackground: Bool = false) {
        load(force: true, isBackground: isBackground)
    }
    
    
    // жалко у апи нету ендпоинта на обновление только цен...
    func refreshPrices(for ids: [String] = [], force: Bool = false, isBackground: Bool = false) {
        defer { isLoading = false }
        guard !coins.isEmpty else { return }
        
        let now = Date()
        guard force || lastPriceUpdateAt == nil || now.timeIntervalSince(lastPriceUpdateAt!) > TimeInterval(UserSettings.refreshRate) else {
            return
        }
        
        refreshTask?.cancel()
        refreshTask = nil
        refreshTask = Task {
            do {
                try Task.checkCancellation()
                print("Refreshin only prices")
                isLoading = true
                let ids = ids.isEmpty ? coins.map { $0.id } : ids
                let updated = try await coinService.fetchPrices(for: ids)
                coins.update(with: Set(updated))
                coinsPublisher.send(Array(coins))
                
                lastPriceUpdateAt = Date()
                logUpdated(updated, for: Array(coins))
            } catch {
                print("and getting error")
                self.error = error as? NetworkError ?? .unknown
                if !isBackground {
                    errorPublisher.send(self.error?.errorDescription)
                }
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
    private func fetchCoins(isBackground: Bool = false) async {
        defer { isLoading = false }
        
        do {
            try Task.checkCancellation()
            print("Fetch coins")
            isLoading = true
            
            let newCoins = try await coinService.fetchCryptos(page: currentPage, perPage: bunchAmount)
            currentPage += 1
            coins.formUnion(newCoins)
            coinsPublisher.send(Array(coins))
            
            lastLoadedAt = Date()
            logUpdated(Array(coins), for: Array(coins).map { $0 })
        } catch {
            print("and getting error")
            self.error = error as? NetworkError ?? .unknown
            if !isBackground {
                errorPublisher.send(self.error?.errorDescription)
            }
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
                self?.autorefresh()
            }
    }
    
    private func stopAutoRefresh() {
        refreshTimer?.cancel()
        refreshTimer = nil
    }
    
    private func autorefresh() {
        if coins.isEmpty {
            refresh(isBackground: true)
        } else {
            refreshPrices(isBackground: true)
        }
    }
}
