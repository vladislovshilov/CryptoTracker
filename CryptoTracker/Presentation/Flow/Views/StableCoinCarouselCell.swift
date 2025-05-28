//
//  StableCoinCarouselCell.swift
//  CryptoTracker
//
//  Created by lil angee on 26.05.25.
//

import UIKit
import Combine

protocol StableCoinCarouselCellDelegate: AnyObject {
    func didSelectStableCoin(_ crypto: CryptoCurrency, in cell: StableCoinCarouselCell)
}

class StableCoinCarouselCell: UICollectionViewCell {
    static let reuseIdentifier = "StableCoinCarouselCell"

    private var stableCoins: [CryptoCurrency] = []
    private var collectionView: UICollectionView!
    private var dataSource: UICollectionViewDiffableDataSource<Int, CryptoCurrency>!

    weak var delegate: StableCoinCarouselCellDelegate?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCollectionView()
        configureDataSource()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 140, height: 60)
        layout.minimumInteritemSpacing = 10
        layout.minimumLineSpacing = 10
        layout.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)

        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .systemGray6
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.register(SmallCryptoCell.self, forCellWithReuseIdentifier: SmallCryptoCell.reuseIdentifier)
        collectionView.delegate = self
        
        contentView.addSubview(collectionView)

        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: contentView.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])
    }

    private func configureDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Int, CryptoCurrency>(collectionView: collectionView) {
            (collectionView, indexPath, crypto) -> UICollectionViewCell? in
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SmallCryptoCell.reuseIdentifier, for: indexPath) as? SmallCryptoCell else {
                fatalError("Cannot create new cell")
            }
            cell.configure(with: crypto)
            return cell
        }
    }

    func configure(with stableCoins: [CryptoCurrency]) {
        self.stableCoins = stableCoins
        var snapshot = NSDiffableDataSourceSnapshot<Int, CryptoCurrency>()
        snapshot.appendSections([0])
        snapshot.appendItems(stableCoins)
        dataSource.apply(snapshot, animatingDifferences: false) 
    }
}

extension StableCoinCarouselCell: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let crypto = dataSource.itemIdentifier(for: indexPath) else { return }
        delegate?.didSelectStableCoin(crypto, in: self)
    }
}
