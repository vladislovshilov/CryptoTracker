//
//  DetailsViewModel.swift
//  CryptoTracker
//
//  Created by lil angee on 26.05.25.
//

import Foundation
import Combine

@MainActor
final class DetailsViewModel: ViewModeling {
    
    @Published private(set) var coin: CryptoCurrency
    @Published private(set) var isFavourite: Bool = false
    @Published private(set) var isLoading: Bool = false

    @Published var chartModel = ChartModel()
    private var cachedChartModels = Dictionary<Int, ChartModelProxy>()
    
    @Published private(set) var selectedTimeframe = 1
    let timeframes: [Int] = [1, 7, 14, 30, 90, 180, 365]
    
    let errorPublisher = PassthroughSubject<String, Never>()
    
    private let id: String
    private let api: ChartDataLoading
    private let storage: FavoritesStorage
    private let useCase: CoinLoading
    
    private var loadChartTask: Task<Void, Never>?
    private var cancellables = Set<AnyCancellable>()
    
    init(api: ChartDataLoading, storage: FavoritesStorage, useCase: CoinLoading, id: String) {
        self.api = api
        self.storage = storage
        self.useCase = useCase
        self.id = id
        
        // pick a coin from useCase by id either way pick a coin from storage
        guard let parsedCoin = useCase.currentCoins().first(where: { $0.id == id }) ?? storage.allFavorites().first(where: { $0.id == id })?.toCryptoCurrency() else {
            isLoading = true
            errorPublisher.send("can't load coin")
            coin = .init(id: "unknown", symbol: "", name: "", image: "", currentPrice: 0, marketCap: nil, marketCapRank: nil, totalVolume: nil)
            return
        }
        coin = parsedCoin
        
        self.useCase.coinsPublisher
            .sink(receiveValue: { [weak self] coins in
                guard let updatedCoin = coins.filter({ $0.id == self?.id ?? "" }).first else { return }
                self?.coin = updatedCoin
            })
            .store(in: &cancellables)
        
        self.storage.favoritesPublisher
            .sink { [weak self] favourites in
                self?.isFavourite = favourites.filter({ $0.id == self?.id ?? "" }).first != nil
            }
            .store(in: &cancellables)
        
        loadChart(for: selectedTimeframe)
    }
    
    deinit {
        loadChartTask?.cancel()
        loadChartTask = nil
    }

    func toggleFavourite() {
        storage.toggle(coin.toFavouriteModel())
    }
    
    func selectTimeframe(_ timeframe: Int) {
        guard timeframes.contains(timeframe) else { return }
        
        loadChart(for: timeframe)
    }
    
    // MARK: - Helpers
    
    private func loadChart(for timeframe: Int) {
        if let model = cachedChartModels[timeframe],
           !model.chartData.isEmpty {
            DispatchQueue.main.async {
                self.chartModel.chartData = model.chartData
                self.chartModel.max = model.max
                self.chartModel.min = model.min
                self.selectedTimeframe = timeframe
            }
            
            return
        }
        
        loadChartTask = Task {
            do {
                isLoading = true
                let chartData = try await api.fetchMarketChart(for: coin.id, days: timeframe)
                let min = chartData.map(\.price).min() ?? 0
                let max = chartData.map(\.price).max() ?? 0
                
                chartModel.min = min - (max - min) / 2
                chartModel.max =  max + (max - min) / 2
                chartModel.chartData = chartData
                selectedTimeframe = timeframe
                cachedChartModels[timeframe] = ChartModelProxy(model: chartModel)
            } catch {
                let networkError = error as? NetworkError ?? .unknown
                errorPublisher.send(networkError.errorDescription ?? error.localizedDescription)
            }
            
            isLoading = false
        }
    }
}
