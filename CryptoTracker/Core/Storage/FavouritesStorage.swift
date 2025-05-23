//
//  FavouritesStorage.swift
//  CryptoTracker
//
//  Created by lil angee on 24.05.25.
//

import Foundation
import Combine

protocol FavoritesStorageProtocol {
    var favoritesPublisher: AnyPublisher<Set<FavoriteCurrency>, Never> { get }
    func toggle(_ coin: FavoriteCurrency)
    func isFavorite(_ coin: FavoriteCurrency) -> Bool
    func allFavorites() -> Set<FavoriteCurrency>
}

final class FavoritesStorage: FavoritesStorageProtocol {
    private let key = "favoriteCoins"
    private let defaults = UserDefaults.standard
    private var favorites: Set<FavoriteCurrency> = []
    private let subject = CurrentValueSubject<Set<FavoriteCurrency>, Never>([])

    var favoritesPublisher: AnyPublisher<Set<FavoriteCurrency>, Never> {
        subject.eraseToAnyPublisher()
    }

    init() {
        load()
    }

    private func load() {
        if let data = defaults.data(forKey: key),
           let saved = try? JSONDecoder().decode(Set<FavoriteCurrency>.self, from: data) {
            favorites = saved
            subject.send(favorites)
        }
    }

    private func save() {
        if let data = try? JSONEncoder().encode(favorites) {
            defaults.set(data, forKey: key)
            subject.send(favorites)
        }
    }

    func toggle(_ coin: FavoriteCurrency) {
        let favoritesIDs = favorites.map { $0.id }
        let cointID = coin.id
        
        if favoritesIDs.contains(cointID) {
            favorites.remove(coin)
        } else {
            favorites.insert(coin)
        }
        save()
    }

    func isFavorite(_ coin: FavoriteCurrency) -> Bool {
        let favoritesIDs = favorites.map { $0.id }
        return favoritesIDs.contains(coin.id)
    }

    func allFavorites() -> Set<FavoriteCurrency> {
        favorites
    }
}
