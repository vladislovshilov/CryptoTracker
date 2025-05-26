//
//  ViewController.swift
//  CryptoTracker
//
//  Created by lil angee on 21.05.25.
//

import UIKit
import Combine

class ViewController: BaseViewController<ViewModel> {

    @IBOutlet private weak var collectionView: UICollectionView!
    @IBOutlet private weak var label: UILabel!
    
    private let emptyView = EmptyStateView(message: "No coins found")
    
    private var dataSource: UICollectionViewDiffableDataSource<Int, CryptoCurrency>!
    
    private var cancellables = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bindViewModel()
        setupCollectionView()
    }
    
    private func setupCollectionView() {
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "Cell")
        
        dataSource = UICollectionViewDiffableDataSource<Int, CryptoCurrency>.init(collectionView: collectionView, cellProvider: { collectionView, indexPath, itemIdentifier in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
            cell.backgroundColor = .red
            return cell
        })
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(didPullToRefresh), for: .valueChanged)
        collectionView.refreshControl = refreshControl
        
        collectionView.reloadData()
    }
    
    private func bindViewModel() {
        viewModel.$cryptos
            .dropFirst()
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] coins in
                guard !coins.isEmpty else { return }
                self?.updateSnapshot(with: coins.map { $0 })
                self?.updateEmptyState(isEmpty: coins.isEmpty)
                
                let result = coins.map {
                    "\($0.name) - \($0.currentPrice)"
                }.joined(separator: "\n")
                
                self?.label.text = result
                self?.collectionView.reloadData()
            }
            .store(in: &cancellables)
        
        viewModel.$isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] loading in
                if loading {
                    // TODO: - in vm?
                    self?.label.text = "loading..."
                    self?.updateEmptyState(isEmpty: self?.viewModel.cryptos.isEmpty ?? true)
                }
                self?.toggleLoading(isLoading: loading)
            }
            .store(in: &cancellables)
    }
    
    @objc private func didPullToRefresh() {
        viewModel.reload()
        collectionView.refreshControl?.endRefreshing()
    }
}

// MARK: - Helpers

extension ViewController {
    private func updateSnapshot(with coins: [CryptoCurrency]) {
        var snapshot = NSDiffableDataSourceSnapshot<Int, CryptoCurrency>()
        snapshot.appendSections([0])
        snapshot.appendItems(coins)
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    private func updateEmptyState(isEmpty: Bool) {
        if isEmpty {
            collectionView.backgroundView = emptyView
        } else {
            collectionView.backgroundView = nil
        }
    }
}

// MARK: - UICollectionViewDataSource

extension ViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.cryptos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
        cell.backgroundColor = .red
        return cell
    }
}

// MARK: - UICollectionViewDelegate

extension ViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        viewModel.selectCoin(at: indexPath.row)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let height = scrollView.frame.size.height
        
        if offsetY > contentHeight - height - 100 {
            viewModel.loadNextPage()
        }
    }
}

