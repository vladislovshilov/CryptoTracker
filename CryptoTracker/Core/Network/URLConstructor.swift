//
//  URLConstructor.swift
//  CryptoTracker
//
//  Created by lil angee on 23.05.25.
//

import Foundation

final class URLConstructor {
    static func makeFetchURL(baseURL: String, page: Int, perPage: Int) throws -> URL {
        var components = URLComponents(string: "\(baseURL)/coins/markets")!
        components.queryItems = [
            URLQueryItem(name: "vs_currency", value: "usd"),
            URLQueryItem(name: "order", value: "market_cap_desc"),
            URLQueryItem(name: "per_page", value: "\(perPage)"),
            URLQueryItem(name: "page", value: "\(page)"),
            URLQueryItem(name: "sparkline", value: "false")
        ]
        
        guard let url = components.url else {
            throw URLError(.badURL)
        }
        
        return url
    }
    
    static func makeDetailsURL(baseURL: String, id: String) throws -> URL {
        guard let url = URL(string: "\(baseURL)/coins/\(id)") else {
            throw URLError(.badURL)
        }
        
        return url
    }
    
    static func makePriceURL(baseURL: String, ids: [String]) throws -> URL {
        var components = URLComponents(string: "\(baseURL)/coins/markets")!
        components.queryItems = [
            URLQueryItem(name: "vs_currency", value: "usd"),
            URLQueryItem(name: "ids", value: ids.joined(separator: ",")),
            URLQueryItem(name: "order", value: "market_cap_desc"),
            URLQueryItem(name: "sparkline", value: "false")
        ]

        guard let url = components.url else {
            throw URLError(.badURL)
        }
        
        return url
    }
}
