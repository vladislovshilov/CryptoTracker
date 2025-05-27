//
//  ViewModel.swift
//  CryptoTracker
//
//  Created by lil angee on 21.05.25.
//

import Foundation
import Combine

final class ViewModel: ViewModeling, PriceLogging {
    
    enum ListItem: Hashable {
        case header(String)
        case crypto(CryptoCurrency)
        case stableCoinCarousel([CryptoCurrency])
    }
    
    enum Section: Hashable {
        case header(String)
        case carousel
        case cryptoList
    }
    
    @Published private var cryptos: [CryptoCurrency] = []
    @Published private var stables: [CryptoCurrency] = []
    @Published var filterText: String = ""
    @Published var isLoading = false
    
    var listItemsPublisher: AnyPublisher<[ListItem], Never> {
        Publishers.CombineLatest($stables, $cryptos)
            .map { stable, all in
                var items: [ListItem] = []
                if !stable.isEmpty {
                    items.append(.header("Stables"))
                    items.append(.stableCoinCarousel(stable))
                }
                items.append(.header("All"))
                items.append(contentsOf: all.map { ListItem.crypto($0) })
                return items
            }
            .eraseToAnyPublisher()
    }
    
    let coinSelection = PassthroughSubject<CryptoCurrency, Never>()
    
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
        // TODO: -
    }
    
    func selectCoin(_ coin: CryptoCurrency) {
        coinSelection.send(coin)
    }
    
    private func bindUseCase() {
        isLoading = useCase.isLoading
        
        useCase.coinsPublisher
            .sink(receiveValue: { [weak self] coins in
                self?.isLoading = false
                self?.stables = coins.filter { $0.isStableCoin }
                self?.cryptos = coins
            })
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
