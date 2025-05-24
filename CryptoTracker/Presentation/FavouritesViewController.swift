//
//  FavouritesViewController.swift
//  CryptoTracker
//
//  Created by lil angee on 21.05.25.
//

import UIKit
import Combine

class FavouritesViewController: BaseViewController<FavouriteViewModel> {
    
    @IBOutlet weak var refreshRateSlider: UISlider!
    @IBOutlet weak var refreshRateLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.leftBarButtonItem = nil
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        
        refreshRateSlider.minimumValue = Float(viewModel.minRefreshRate)
        refreshRateSlider.maximumValue = Float(viewModel.maxRefreshRate)
        refreshRateSlider.value = Float(viewModel.refreshRate)
        refreshRateSlider.addTarget(self, action: #selector(sliderValueChanged), for: .valueChanged)
        
        refreshRateLabel.font = .systemFont(ofSize: 16)
        refreshRateLabel.textAlignment = .center
    }
    
    @IBAction func buttonDidPress(_ sender: Any) {
        popVC?()
    }
    
    @objc private func sliderValueChanged(_ sender: UISlider) {
        let stepped = round(sender.value)
        sender.value = stepped
        viewModel.refreshRate = UInt8(stepped)
    }
}

extension FavouritesViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.favoriteCoins.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let coin = viewModel.favoriteCoins[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        var content = cell.defaultContentConfiguration()
        content.text = "\(coin.name))"
        content.secondaryText = "$\(coin.currentPrice)"
        cell.contentConfiguration = content
        cell.accessoryType = viewModel.isFavorite(coin) ? .checkmark : .none
        return cell
    }
}
