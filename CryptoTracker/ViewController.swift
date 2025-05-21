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

        viewModel.$counter
//            .receive(on: DispatchQueue.main)
            .sink { [weak self] obj in
                self?.label.text = obj
            }
            .store(in: &cancellables)
    }
}

