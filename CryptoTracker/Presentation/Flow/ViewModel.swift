//
//  ViewModel.swift
//  CryptoTracker
//
//  Created by lil angee on 21.05.25.
//

import Foundation
import Combine

final class ViewModel: ViewModeling, PriceLogging {
    
    enum SectionType: String { case stables, all }
    
    @Published private(set) var cryptos: [CryptoCurrency] = []
    @Published private(set) var stables: [CryptoCurrency] = []
    @Published var filterText: String = ""
    @Published var isLoading = false
    @Published var sectionTypes: [SectionType] = []
    
    let coinSelection = PassthroughSubject<CryptoCurrency, Never>()
    
//    private var currentPage = 1
//    private let perPage = 20
    
    private let useCase: CoinLoading
    private let storage: FavoritesStoring
    
    private var cancellables = Set<AnyCancellable>()
    
    init(useCase: CoinLoading, storage: FavoritesStoring) {
        self.useCase = useCase
        self.storage = storage
    }
    
    func onAppear() {
        bindUseCase()
        cryptos = useCase.currentCoins()
    }
    
    func onDisappear() {
        unbindUseCase()
    }
    
    func reload() {
        isLoading = true
        if cryptos.isEmpty {
            useCase.load(force: true, isBackground: false)
        } else {
            useCase.refreshPrices(force: true, isBackground: false)
        }
    }
    
    func loadNextPage() {
//        useCase.loadNextPage()
    }
    
    func selectCoin(in section: SectionType, at index: Int) {
        var coin: CryptoCurrency
        switch section {
        case .stables:
            guard stables.indices.contains(index) else { return }
            coin = stables[index]
        case .all:
            guard cryptos.indices.contains(index) else { return }
            coin = cryptos[index]
        }
        coinSelection.send(coin)
    }
    
    private func bindUseCase() {
        isLoading = useCase.isLoading
        
        useCase.coinsPublisher
            .sink { [weak self] coins in
                guard let self else { return }
                stables = coins.filter { $0.id == "usd-coin" || $0.id == "tether" || $0.id == "ethereum" }
                if !stables.isEmpty {
                    sectionTypes = [.stables, .all]
                } else {
                    sectionTypes = [.all]
                }
                
                cryptos = coins
                populateFavouritesIfNeeded()
                isLoading = false
            }
            .store(in: &cancellables)
        
        useCase.errorPublisher
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .sink { [weak self] errorMessage in
                self?.isLoading = false
            }
            .store(in: &cancellables)
    }
    
    private func unbindUseCase() {
        cancellables.removeAll()
    }
}

// MARK: Temp

extension ViewModel {
    private func populateFavouritesIfNeeded() {
        if storage.allFavorites().isEmpty {
            for i in stride(from: 0, to: cryptos.count, by: 2) {
                let fetched = cryptos[i]
                storage.toggle(fetched.toFavouriteModel())
            }
        }
    }
}
