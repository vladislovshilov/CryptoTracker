//
//  DetailsViewController.swift
//  CryptoTracker
//
//  Created by lil angee on 26.05.25.
//

import UIKit
import Combine
import SwiftUI

class DetailsViewController: BaseViewController<DetailsViewModel> {

    @IBOutlet private weak var marketCupLabel: UILabel!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var saveButton: UIButton!
    @IBOutlet private weak var priceChangeLabel: UILabel!
    @IBOutlet private weak var priceLabel: UILabel!
    @IBOutlet private weak var totalVolumeLabel: UILabel!
    @IBOutlet private weak var containerView: UIView!
    @IBOutlet private weak var timeframesContainerView: UIStackView!
    
    private var suiChart: SwiftUIView?
    
    private var cancellables = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()
    }
    
    // MAKR: - Setup
    
    private func setupUI() {
        navigationItem.leftBarButtonItem = nil
        navigationItem.rightBarButtonItems = navigationItem.rightBarButtonItems?.dropLast()
        
        addSUIChart()
        
        viewModel.timeframes.forEach { timeframe in
            let button = UIButton(type: .system)
            button.setTitle("\(timeframe)", for: .normal)
            button.tag = timeframe
            button.addTarget(self, action: #selector(timeframeButtonTapped(_:)), for: .touchUpInside)
            timeframesContainerView.addArrangedSubview(button)
        }
    }
    
    private func bindViewModel() {
        viewModel.$coin
            .receive(on: DispatchQueue.main)
            .sink { [weak self] value in
                self?.handleCoin(value)
            }
            .store(in: &cancellables)
        
        viewModel.$isFavourite
            .receive(on: DispatchQueue.main)
            .sink { [weak self] value in
                self?.handleFavourite(isFavourite: value)
            }
            .store(in: &cancellables)
        
        viewModel.$isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                self?.timeframesContainerView.isUserInteractionEnabled = !isLoading
                self?.toggleLoading(isLoading: isLoading)
            }
            .store(in: &cancellables)
        
        viewModel.$selectedTimeframe
            .receive(on: DispatchQueue.main)
            .sink { [weak self] timeframe in
                guard let button = self?.timeframesContainerView.subviews.first(where: { $0.tag == timeframe }) as? UIButton else {
                    return
                }
                self?.timeframesContainerView.subviews.forEach { ($0 as? UIButton)?.isSelected = false }
                button.isSelected = true
            }
            .store(in: &cancellables)
        
        viewModel.errorPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] message in
                self?.showErrorAlert(message)
            }
            .store(in: &cancellables)
    }

    // MARK: - Actions
    
    @objc private func timeframeButtonTapped(_ sender: UIButton) {
        viewModel.selectTimeframe(sender.tag)
    }
    
    @IBAction private func saveButtonDidPress(_ sender: Any) {
        viewModel.toggleFavourite()
    }
    
    // MARK: - Helpers
    
    private func handleFavourite(isFavourite: Bool) {
        if isFavourite {
            saveButton.setTitle("remove", for: .normal)
        } else {
            saveButton.setTitle("save", for: .normal)
        }
    }
    
    private func handleCoin(_ coin: CryptoCurrency) {
        titleLabel.text = coin.name
        priceLabel.text = "$\(coin.currentPrice.prettyCurrency()) for 1\(coin.symbol.uppercased())"
        
        if let priceChange = coin.priceChangePercentage24h {
            priceChangeLabel.isHidden = false
            if priceChange >= 0 {
                priceChangeLabel.textColor = .systemGreen
                priceChangeLabel.backgroundColor = .systemGreen.withAlphaComponent(0.3)
            } else {
                priceChangeLabel.textColor = .systemRed
                priceChangeLabel.backgroundColor = .systemRed.withAlphaComponent(0.3)
            }
            priceChangeLabel.text = "\(priceChange)%"
        } else {
            priceChangeLabel.isHidden = true
        }
        
        marketCupLabel.text = "mrkt cup: \(coin.totalVolume.prettyCurrency())"
        totalVolumeLabel.text = "Total Traded Volume: \(coin.totalVolume.prettyCurrency())"
        
        handleFavourite(isFavourite: viewModel.isFavourite)
    }
    
    func addSUIChart() {
        suiChart = SwiftUIView(model: self.viewModel.chartModel)
        let vc = UIHostingController(rootView: suiChart)
        
        let swiftuiView = vc.view!
        swiftuiView.translatesAutoresizingMaskIntoConstraints = false

        addChild(vc)
        containerView.addSubview(swiftuiView)

        NSLayoutConstraint.activate([
            swiftuiView.topAnchor.constraint(equalTo: containerView.topAnchor),
            swiftuiView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            swiftuiView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            swiftuiView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
        ])

        vc.didMove(toParent: self)
    }
    
    private func showErrorAlert(_ message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
