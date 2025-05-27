//
//  CoinGeckoAPI.swift
//  CryptoTracker
//
//  Created by lil angee on 23.05.25.
//

import Foundation
import Combine

protocol CryptosLoading {
    func fetchCryptos(page: Int, perPage: Int) async throws -> [CryptoCurrency]
    func fetchCryptoDetails(id: String) async throws -> CryptoCurrency
    func fetchPrices(for ids: [String]) async throws -> [CryptoCurrency]
}

protocol ChartDataLoading {
    func fetchMarketChart(for coinID: String, days: Int) async throws -> [ChartPoint]
}

final class CoinGeckoAPI: CryptosLoading, ChartDataLoading {
    struct MarketChartResponse: Decodable {
        let prices: [[Double]]
    }
    
    private let baseURL = "https://api.coingecko.com/api/v3"
    private let network: NetworkServiceProtocol

    init(networkService: NetworkServiceProtocol = NetworkService()) {
        self.network = networkService
    }

    func fetchCryptos(page: Int, perPage: Int) async throws -> [CryptoCurrency] {
        let url = try URLConstructor.makeFetchURL(baseURL: baseURL, page: page, perPage: perPage)
        let request = URLRequest(url: url)
        return try await network.fetch(request)
    }

    func fetchCryptoDetails(id: String) async throws -> CryptoCurrency {
        let url = try URLConstructor.makeDetailsURL(baseURL: baseURL, id: id)
        let request = URLRequest(url: url)
        return try await network.fetch(request)
    }
    
    func fetchPrices(for ids: [String]) async throws -> [CryptoCurrency] {
        let url = try URLConstructor.makePriceURL(baseURL: baseURL, ids: ids)
        let request = URLRequest(url: url)
        return try await network.fetch(request)
    }
    
    func fetchMarketChart(for coinID: String, days: Int) async throws -> [ChartPoint] {
        let url = try URLConstructor.makeChartURL(baseURL: baseURL, coinID: coinID, days: days)
        let request = URLRequest(url: url)
        let response: MarketChartResponse = try await network.fetch(request)

        let points = response.prices.map { item in
            ChartPoint(timestamp: Date(timeIntervalSince1970: item[0] / 1000),
                       price: item[1])
        }
        
        let uniquePoints = Dictionary(grouping: points, by: \.timestamp)
            .compactMapValues { $0.first }
            .values
            .sorted(by: { $0.timestamp < $1.timestamp })
            .filter { $0.price != 0 }
        
        return uniquePoints
    }
}
