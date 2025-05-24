//
//  NetworkService.swift
//  CryptoTracker
//
//  Created by lil angee on 23.05.25.
//

import Foundation

protocol NetworkServiceProtocol {
    func fetch<T: Decodable>(_ urlRequest: URLRequest) async throws -> T
}

final class NetworkService: NetworkServiceProtocol {
    func fetch<T: Decodable>(_ urlRequest: URLRequest) async throws -> T {
        let (data, response) = try await URLSession.shared.data(for: urlRequest)

        guard let httpResponse = response as? HTTPURLResponse,
              200..<300 ~= httpResponse.statusCode else {
            throw URLError(.badServerResponse)
        }

        return try JSONDecoder().decode(T.self, from: data)
    }
}
