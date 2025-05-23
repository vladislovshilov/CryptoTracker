//
//  ViewController.swift
//  CryptoTracker
//
//  Created by lil angee on 21.05.25.
//

import UIKit
import Combine

class ViewController: BaseViewController<ViewModel> {

    @IBOutlet weak var label: UILabel!
    
    private var cancellables = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bindViewModel()

        viewModel.$counter
            .receive(on: DispatchQueue.main)
            .sink { [weak self] obj in
                self?.label.text = obj
            }
            .store(in: &cancellables)
    }
    
    private func bindViewModel() {
        viewModel.$cryptos
            .receive(on: DispatchQueue.main)
            .sink { [weak self] value in
                print("received")
                let result = value.map {
                    "\($0.name) - \($0.currentPrice)"
                }.joined(separator: "\n")
                self?.label.text = result
            }
            .store(in: &cancellables)
        
        viewModel.$errorMessage
            .receive(on: DispatchQueue.main)
            .compactMap { $0 }
            .sink { [weak self] errorMsg in
                self?.label.text = errorMsg
            }
            .store(in: &cancellables)
        
        viewModel.$isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] loading in
                if loading {
                    self?.label.text = "loading..."
                }
            }
            .store(in: &cancellables)
    }
}

