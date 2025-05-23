//
//  CoinGeckoAPI.swift
//  CryptoTracker
//
//  Created by lil angee on 23.05.25.
//

import Foundation
import Combine

protocol CoinGeckoAPIProtocol {
    func fetchCryptos(page: Int, perPage: Int) async throws -> [CryptoCurrency]
    func fetchCryptoDetails(id: String) async throws -> CryptoCurrency
    func fetchPrices(for ids: [String]) async throws -> [CryptoCurrency]
}

final class CoinGeckoAPI: CoinGeckoAPIProtocol {
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
}
