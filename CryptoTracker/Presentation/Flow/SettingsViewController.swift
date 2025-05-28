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
    
    @IBOutlet private weak var appThemeSwitch: UISwitch!
    @IBOutlet private weak var appThemeLabel: UILabel!
    
    private var shouldRemoveItem = true
    
    private var cancellables = Set<AnyCancellable>()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        navigationItem.leftBarButtonItem = nil
        navigationItem.rightBarButtonItems = navigationItem.rightBarButtonItems?.dropLast()
        
        refreshRateSlider.minimumValue = Float(viewModel.minRefreshRate)
        refreshRateSlider.maximumValue = Float(viewModel.maxRefreshRate)
        refreshRateSlider.value = Float(viewModel.refreshRate)
        refreshRateSlider.addTarget(self, action: #selector(sliderValueChanged), for: .valueChanged)
        
        refreshRateLabel.font = .systemFont(ofSize: 16)
        refreshRateLabel.textAlignment = .center
    }
    
    private func bindViewModel() {
        viewModel.$refreshRate
            .receive(on: DispatchQueue.main)
            .sink { [weak self] rate in
                self?.refreshRateLabel.text = "Refresh every \(rate) sec"
                self?.refreshRateSlider.setValue(Float(rate), animated: true)
            }
            .store(in: &cancellables)
        
        viewModel.$appThemeOn
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isOn in
                self?.appThemeSwitch.isOn = isOn
                self?.appThemeLabel.text = "Current app theme: \(isOn ? "dark" : "light")"
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Actions
    
    @objc private func sliderValueChanged(_ sender: UISlider) {
        let stepped = round(sender.value)
        sender.value = stepped
        viewModel.refreshRate = TimeInterval(stepped)
    }
    
    @IBAction private func switchValueDidChange(_ sender: Any) {
        viewModel.toggleAppTheme()
    }
    
    @IBAction private func clearButtonDidPress(_ sender: Any) {
        viewModel.cleanUserDefaults()
    }
}
