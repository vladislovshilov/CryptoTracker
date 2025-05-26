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
    
    private var cancellables = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bindViewModel()
        setupCollectionView()
    }
    
    private func setupCollectionView() {
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "Cell")
        
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
        return viewModel.sectionTypes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let sectionType = viewModel.sectionTypes[section]
        switch sectionType {
        case .stables:
            return viewModel.stables.count
        case .all:
            return viewModel.cryptos.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let sectionType = viewModel.sectionTypes[indexPath.section]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
        cell.backgroundColor = sectionType == .stables ? .blue : .red
        return cell
    }
}

// MARK: - UICollectionViewDelegate

extension ViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let sectionType = viewModel.sectionTypes[indexPath.section]
        viewModel.selectCoin(in: sectionType, at: indexPath.row)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let height = scrollView.frame.size.height
        
        if offsetY > contentHeight - height - 100 {
            viewModel.loadNextPage()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 150, height: 80)
    }
}

