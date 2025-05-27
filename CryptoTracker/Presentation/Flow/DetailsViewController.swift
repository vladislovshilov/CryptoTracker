//
//  DetailsViewController.swift
//  CryptoTracker
//
//  Created by lil angee on 26.05.25.
//

import UIKit
import Combine
import SwiftUI
import Charts

struct MonthlyHoursOfSunshine: Identifiable {
    var id: Int
    
    var date: Date
    var hoursOfSunshine: Double

    init(month: Int, hoursOfSunshine: Double) {
        let calendar = Calendar.autoupdatingCurrent
        self.date = calendar.date(from: DateComponents(year: 2020, month: month))!
        self.hoursOfSunshine = hoursOfSunshine
        self.id = month
    }
}

struct SwiftUIView: View {
    var title: String = ""
    
    var data: [MonthlyHoursOfSunshine] = [
        MonthlyHoursOfSunshine(month: 1, hoursOfSunshine: 74),
        MonthlyHoursOfSunshine(month: 2, hoursOfSunshine: 99),
        MonthlyHoursOfSunshine(month: 3, hoursOfSunshine: 11),
        MonthlyHoursOfSunshine(month: 4, hoursOfSunshine: 62),
        MonthlyHoursOfSunshine(month: 5, hoursOfSunshine: 68),
        MonthlyHoursOfSunshine(month: 6, hoursOfSunshine: 44),
        MonthlyHoursOfSunshine(month: 7, hoursOfSunshine: 55),
        MonthlyHoursOfSunshine(month: 8, hoursOfSunshine: 88),
        MonthlyHoursOfSunshine(month: 12, hoursOfSunshine: 99)
    ]
    
    var body: some View {
        ZStack {
//            Color.pink
//            Button(title) {
//                
//            }
//            .font(.title)
//            .buttonStyle(.borderedProminent)
//            .padding()
            Chart(data) { el in
                LineMark(
                    x: .value("Month", el.date),
                    y: .value("Hours of Sunshine", el.hoursOfSunshine)
                )
            }
        }
    }
}

class DetailsViewController: BaseViewController<DetailsViewModel> {

    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var saveButton: UIButton!
    @IBOutlet private weak var priceChangeLabel: UILabel!
    @IBOutlet private weak var priceLabel: UILabel!
    @IBOutlet private weak var totalVolumeLabel: UILabel!
    @IBOutlet private weak var containerView: UIView!
    
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
        
        let vc = UIHostingController(rootView: SwiftUIView(title: viewModel.coin.name))
        
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
    }

    // MARK: - Actions
    
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
        priceLabel.text = "$\(coin.currentPrice) for 1\(coin.symbol.uppercased())"
        
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
        
        totalVolumeLabel.text = "Total Traded Volume: \(coin.totalVolume ?? 0)"
        
        handleFavourite(isFavourite: viewModel.isFavourite)
    }
}
