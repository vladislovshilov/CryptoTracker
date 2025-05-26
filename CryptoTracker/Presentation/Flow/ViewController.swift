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
    
    private var dataSource: UICollectionViewDiffableDataSource<Int, ViewModel.ListItem>!
    
    private var cancellables = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bindViewModel()
        setupCollectionView()
    }
    
    private func bindViewModel() {
        viewModel.listItemsPublisher
            .receive(on: DispatchQueue.main)
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .sink { [weak self] items in
                self?.applySnapshot(items: items)
                self?.updateEmptyState(isEmpty: items.isEmpty)
            }
            .store(in: &cancellables)
        
        viewModel.$isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] loading in
                if loading {
                    // TODO: - in vm?
                    self?.label.text = loading ? "loading..." : ""
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


// MARK: - StableCoinCarouselCellDelegate

extension ViewController: StableCoinCarouselCellDelegate {
    func didSelectStableCoin(_ crypto: CryptoCurrency, in cell: StableCoinCarouselCell) {
        viewModel.selectCoin(crypto)
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
    
    private func setupCollectionView() {
        collectionView.setCollectionViewLayout(createLayoutWithDistinctSections(), animated: true)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .systemGray6 // Или другой цвет для выделения
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.register(StableCoinCarouselCell.self, forCellWithReuseIdentifier: StableCoinCarouselCell.reuseIdentifier)
        collectionView.register(CryptoListItemCell.self, forCellWithReuseIdentifier: CryptoListItemCell.reuseIdentifier)
        collectionView.register(HeaderCell.self, forCellWithReuseIdentifier: HeaderCell.reuseIdentifier)
        
        configureDataSource()
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(didPullToRefresh), for: .valueChanged)
        collectionView.refreshControl = refreshControl
    }
    
    private func applySnapshot(items: [ViewModel.ListItem]) {
        var snapshot = NSDiffableDataSourceSnapshot<Int, ViewModel.ListItem>()
        snapshot.appendSections([0])
        snapshot.appendItems(items, toSection: 0)
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    private func createLayoutWithDistinctSections() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { (sectionIndex, layoutEnvironment) -> NSCollectionLayoutSection? in
            let estimatedHeight: CGFloat = 50
            let itemSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .estimated(estimatedHeight)
            )
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            
            let groupSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .estimated(estimatedHeight)
            )
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
            
            let section = NSCollectionLayoutSection(group: group)
            section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)
            section.interGroupSpacing = 10
            
            return section
        }
        return layout
    }
    
    private func configureDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Int, ViewModel.ListItem>(collectionView: collectionView) {
            (collectionView, indexPath, listItem) -> UICollectionViewCell? in

            switch listItem {
            case .stableCoinCarousel(let stableCoins):
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: StableCoinCarouselCell.reuseIdentifier, for: indexPath) as? StableCoinCarouselCell else {
                    fatalError("Unable to dequeue StableCoinCarouselCell")
                }
                cell.configure(with: stableCoins)
                cell.delegate = self
                return cell

            case .crypto(let cryptoCurrency):
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CryptoListItemCell.reuseIdentifier, for: indexPath) as? CryptoListItemCell else {
                    fatalError("Unable to dequeue CryptoListItemCell")
                }
                cell.configure(with: cryptoCurrency)
                return cell

            case .header(let title):
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HeaderCell.reuseIdentifier, for: indexPath) as? HeaderCell else {
                    fatalError("Unable to dequeue CryptoListItemCell")
                }
                cell.configure(with: title)
                return cell
            }
        }

        var initialSnapshot = NSDiffableDataSourceSnapshot<Int, ViewModel.ListItem>()
        initialSnapshot.appendSections([0])
        dataSource.apply(initialSnapshot, animatingDifferences: false)
    }
}

// MARK: - UICollectionViewDelegate

extension ViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        guard let item = dataSource.itemIdentifier(for: indexPath) else { return }
        if case let .crypto(coin) = item {
            viewModel.selectCoin(coin)
        }
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
