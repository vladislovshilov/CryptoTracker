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

        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        
        let code = httpResponse.statusCode
        if 200..<300 ~= code {
            return try JSONDecoder().decode(T.self, from: data)
        } else {
            throw NetworkError(statusCode: code)
        }
    }
}
