//
//  DetailsViewModel.swift
//  CryptoTracker
//
//  Created by lil angee on 26.05.25.
//

import Foundation
import Combine

final class DetailsViewModel: ViewModeling {
    
    @Published var coin: CryptoCurrency
    @Published var isFavourite: Bool = false
    @Published var data: [MonthlyHoursOfSunshine] = [
        MonthlyHoursOfSunshine(month: 1, hoursOfSunshine: 74),
        MonthlyHoursOfSunshine(month: 2, hoursOfSunshine: 99),
        MonthlyHoursOfSunshine(month: 3, hoursOfSunshine: 11),
        MonthlyHoursOfSunshine(month: 4, hoursOfSunshine: 62),
        MonthlyHoursOfSunshine(month: 5, hoursOfSunshine: 68),
        MonthlyHoursOfSunshine(month: 6, hoursOfSunshine: 44),
        MonthlyHoursOfSunshine(month: 7, hoursOfSunshine: 55),
        MonthlyHoursOfSunshine(month: 8, hoursOfSunshine: 88),
        MonthlyHoursOfSunshine(month: 12, hoursOfSunshine: 99)
    ]
    
    private let id: String
    private let storage: FavoritesStorage
    private let useCase: CoinLoading
    
    private var cancellables = Set<AnyCancellable>()
    
    init(favouriteStorage: FavoritesStorage, coinLoadingUseCase: CoinLoading, coinID: String) {
        storage = favouriteStorage
        useCase = coinLoadingUseCase
        id = coinID
        coin = coinLoadingUseCase.currentCoins().filter { $0.id == coinID }.first!
        
        useCase.coinsPublisher
            .sink(receiveValue: { [weak self] coins in
                guard let updatedCoin = coins.filter({ $0.id == self?.id ?? "" }).first else { return }
                self?.coin = updatedCoin
            })
            .store(in: &cancellables)
        
        storage.favoritesPublisher
            .sink { [weak self] favourites in
                self?.isFavourite = favourites.filter({ $0.id == self?.id ?? "" }).first != nil
            }
            .store(in: &cancellables)
        
//        useCase.errorPublisher
//            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
//            .sink { [weak self] errorMessage in
//                self?.isLoading = false
//            }
//            .store(in: &cancellables)
    }
    
    private func handleCoinUpdate(_ coins: [CryptoCurrency]) {
        guard let updatedCoin = coins.filter({ $0.id == id }).first else { return }
        coin = updatedCoin
    }
    
    func onAppear() {
        
    }
    
    func onDisappear() {
        
    }
    
    func toggleFavourite() {
        storage.toggle(coin.toFavouriteModel())
    }
}
