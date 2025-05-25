//
//  FavouritesViewController.swift
//  CryptoTracker
//
//  Created by lil angee on 21.05.25.
//

import UIKit
import Combine

class FavouritesViewController: BaseViewController<FavouriteViewModel> {
    
    @IBOutlet private weak var refreshRateSlider: UISlider!
    @IBOutlet private weak var refreshRateLabel: UILabel!
    @IBOutlet private weak var tableView: UITableView!
    
    private var refreshIntervalLabel: UILabel!
    
    private var dataSource: UITableViewDiffableDataSource<Int, FavoriteCurrency>!
    private var cancellables = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
        viewModel.$refreshRate
            .receive(on: DispatchQueue.main)
            .sink { [weak self] rate in
                self?.refreshRateLabel.text = "Refresh every \(rate) sec"
                self?.refreshRateSlider.setValue(Float(rate), animated: true)
            }
            .store(in: &cancellables)
        
        viewModel.$favoriteCoins
            .receive(on: DispatchQueue.main)
            .sink { [weak self] coins in
                self?.updateSnapshot(with: coins.map { $0 })
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
    }
    
    // MARK: Setup
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        setupTableView()
        
        refreshRateSlider.minimumValue = Float(viewModel.minRefreshRate)
        refreshRateSlider.maximumValue = Float(viewModel.maxRefreshRate)
        refreshRateSlider.value = Float(viewModel.refreshRate)
        refreshRateSlider.addTarget(self, action: #selector(sliderValueChanged), for: .valueChanged)
        
        refreshRateLabel.font = .systemFont(ofSize: 16)
        refreshRateLabel.textAlignment = .center
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
    
    @objc private func sliderValueChanged(_ sender: UISlider) {
        let stepped = round(sender.value)
        sender.value = stepped
        viewModel.refreshRate = TimeInterval(stepped)
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
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let height = scrollView.frame.size.height
        
        if offsetY > contentHeight - height - 100 {
            viewModel.loadNextPage()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.selectCoin(at: indexPath.row)
    }
}
