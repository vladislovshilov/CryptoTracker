//
//  FavouritesViewController.swift
//  CryptoTracker
//
//  Created by lil angee on 21.05.25.
//

import UIKit
import Combine

class FavouritesViewController: BaseViewController<FavouriteViewModel> {
    
    @IBOutlet private weak var tableView: UITableView!
    private let emptyView = EmptyStateView(message: "No coins found")
    
    private var dataSource: UITableViewDiffableDataSource<Int, FavoriteCurrency>!
    private var cancellables = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
        viewModel.$favoriteCoins
            .receive(on: DispatchQueue.main)
            .sink { [weak self] coins in
                self?.updateSnapshot(with: coins.map { $0 })
                self?.updateEmptyState(isEmpty: coins.isEmpty)
            }
            .store(in: &cancellables)
        
        viewModel.$isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                self?.toggleLoading(isLoading: isLoading)
            }
            .store(in: &cancellables)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.leftBarButtonItem = nil
        navigationItem.rightBarButtonItems = navigationItem.rightBarButtonItems?.reversed().dropLast() ?? nil
    }
    
    // MARK: Setup
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        setupTableView()
    }
    
    private func setupTableView() {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        
        dataSource = UITableViewDiffableDataSource<Int, FavoriteCurrency>(tableView: tableView) { [weak self] tableView, indexPath, coin in
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
            self?.fillCell(cell, coin: coin)
            return cell
        }
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(didPullToRefresh), for: .valueChanged)
        tableView.refreshControl = refreshControl
    }
    
    private func fillCell(_ cell: UITableViewCell, coin: FavoriteCurrency) {
        var content = cell.defaultContentConfiguration()
        content.text = "\(coin.name)"
        content.secondaryText = "$\(coin.currentPrice)"
        cell.contentConfiguration = content
        cell.accessoryType = viewModel.isFavorite(coin) ? .checkmark : .none
    }
    
    // MARK: Actions
    
    @IBAction private func buttonDidPress(_ sender: Any) {
        popVC?()
    }
    
    @objc private func didPullToRefresh() {
        viewModel.reload()
        tableView.refreshControl?.endRefreshing()
    }
}

// MARK: - Helpers

extension FavouritesViewController {
    private func updateSnapshot(with coins: [FavoriteCurrency]) {
        var snapshot = NSDiffableDataSourceSnapshot<Int, FavoriteCurrency>()
        snapshot.appendSections([0])
        snapshot.appendItems(coins)
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    private func updateEmptyState(isEmpty: Bool) {
        if isEmpty {
            tableView.backgroundView = emptyView
            tableView.separatorStyle = .none
        } else {
            tableView.backgroundView = nil
            tableView.separatorStyle = .singleLine
        }
    }
}

// MARK: - UITableViewDataSource

extension FavouritesViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.favoriteCoins.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        fillCell(cell, coin: viewModel.favoriteCoins[indexPath.row])
        return cell
    }
}

// MARK: - UITableViewDelegate

extension FavouritesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.selectCoin(at: indexPath.row)
    }
}
