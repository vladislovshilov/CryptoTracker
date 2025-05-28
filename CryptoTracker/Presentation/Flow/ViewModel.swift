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
    private let settingsObserving: SettingsOberving
    
    private var isLoadingNextPage = false
    
    private var cancellables = Set<AnyCancellable>()
    
    init(useCase: CoinLoading, settingsObserving: SettingsOberving) {
        self.useCase = useCase
        self.settingsObserving = settingsObserving
        bindUseCase()
        cryptos = useCase.currentCoins()
    }
    
    deinit {
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
        guard !isLoadingNextPage else { return }
        isLoadingNextPage = true

        useCase.loadNextPage()
    }
    
    func selectCoin(_ coin: CryptoCurrency) {
        coinSelection.send(coin)
    }
    
    private func bindUseCase() {
        isLoading = useCase.isLoading
        
        useCase.coinsPublisher
            .sorted(by: settingsObserving.sortOption.eraseToAnyPublisher())
            .sink(receiveValue: { [weak self] coins in
                self?.isLoading = false
                self?.isLoadingNextPage = false
                self?.stables = coins.filter { $0.isStableCoin }
                self?.cryptos = coins
            })
            .store(in: &cancellables)
        
        useCase.errorPublisher
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .sink { [weak self] errorMessage in
                self?.isLoading = false
                self?.isLoadingNextPage = false
            }
            .store(in: &cancellables)
    }
    
    private func unbindUseCase() {
        cancellables.removeAll()
    }
}
