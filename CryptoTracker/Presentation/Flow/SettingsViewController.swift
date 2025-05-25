//
//  SettingsViewController.swift
//  CryptoTracker
//
//  Created by lil angee on 25.05.25.
//

import UIKit
import Combine

class SettingsViewController: BaseViewController<SettingsViewModel> {
    
    @IBOutlet private weak var refreshRateSlider: UISlider!
    @IBOutlet private weak var refreshRateLabel: UILabel!
    
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
        refreshRateSlider.minimumValue = Float(viewModel.minRefreshRate)
        refreshRateSlider.maximumValue = Float(viewModel.maxRefreshRate)
        refreshRateSlider.value = Float(viewModel.refreshRate)
        refreshRateSlider.addTarget(self, action: #selector(sliderValueChanged), for: .valueChanged)
        
        refreshRateLabel.font = .systemFont(ofSize: 16)
        refreshRateLabel.textAlignment = .center
    }
    
    @objc private func sliderValueChanged(_ sender: UISlider) {
        let stepped = round(sender.value)
        sender.value = stepped
        viewModel.refreshRate = TimeInterval(stepped)
    }
}
