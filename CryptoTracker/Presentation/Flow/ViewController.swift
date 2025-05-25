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
    }
    
    private func bindViewModel() {
        viewModel.$cryptos
            .dropFirst()
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] values in
                print("received")
                
                guard !values.isEmpty else { return }
                let result = values.map {
                    "\($0.name) - \($0.currentPrice)"
                }.joined(separator: "\n")
                
                self?.label.text = result
            }
            .store(in: &cancellables)
        
        viewModel.$isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] loading in
                if loading {
                    self?.label.text = "loading..."
                }
                self?.toggleLoading(isLoading: loading)
            }
            .store(in: &cancellables)
    }
}

