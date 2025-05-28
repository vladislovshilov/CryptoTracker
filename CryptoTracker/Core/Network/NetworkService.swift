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
    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }
    
    func fetch<T: Decodable>(_ urlRequest: URLRequest) async throws -> T {
        do {
            let (data, response) = try await session.data(for: urlRequest)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                throw NetworkError(statusCode: (response as? HTTPURLResponse)?.statusCode ?? -1)
            }

            let parsedResponse = try JSONDecoder().decode(T.self, from: data)
            return parsedResponse
        } catch let error as DecodingError {
            throw NetworkError.decodingFailed(error)
        } catch let error as URLError {
            throw NetworkError(statusCode: error.code.rawValue)
        }
    }
}
