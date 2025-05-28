//
//  BaseViewController.swift
//  CryptoTracker
//
//  Created by lil angee on 21.05.25.
//

import UIKit
import Combine

class BaseViewController<ViewModel: ViewModeling>: UIViewController {
    
    let settingsTap = PassthroughSubject<Void, Never>()
    let favouriteTap = PassthroughSubject<Void, Never>()
    let sortTap = PassthroughSubject<SortOption, Never>()
    
    var popVC: (() -> Void)?
    
    var viewModel: ViewModel!
    
    private var activityIndicator: UIActivityIndicatorView?
    
    init(viewModel: ViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBarButtons()
    }
    
    func toggleLoading(isLoading: Bool) {
        if isLoading {
            showLoading()
        } else {
            hideLoading()
        }
    }
    
    private func showLoading() {
        DispatchQueue.main.async {
            if self.activityIndicator == nil {
                let indicator = UIActivityIndicatorView(style: .large)
                indicator.translatesAutoresizingMaskIntoConstraints = false
                indicator.hidesWhenStopped = true
                indicator.color = .gray
                
                self.view.addSubview(indicator)
                NSLayoutConstraint.activate([
                    indicator.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
                    indicator.centerYAnchor.constraint(equalTo: self.view.centerYAnchor)
                ])
                
                self.activityIndicator = indicator
            }
            self.activityIndicator?.startAnimating()
            self.view.isUserInteractionEnabled = false
        }
    }

    private func hideLoading() {
        DispatchQueue.main.async {
            self.activityIndicator?.stopAnimating()
            self.view.isUserInteractionEnabled = true
        }
    }
    
    private func setupNavigationBarButtons() {
        let settingsButton = UIBarButtonItem(title: "Settings", style: .plain, target: self, action: #selector(settingsBarButtonTapped))
        navigationItem.leftBarButtonItem = settingsButton
        
        let favouritesButton = UIBarButtonItem(barButtonSystemItem: .bookmarks, target: self, action: #selector(favouritesBarButtonTapped))
        
        let sortByName = UIAction(title: "Sort by Volume", image: UIImage(systemName: "textformat")) { action in
            self.filtersBarButtonTapped(.volume)
        }

        let sortByPrice = UIAction(title: "Sort by Price", image: UIImage(systemName: "dollarsign.circle")) { action in
            self.filtersBarButtonTapped(.price)
        }
        
        let sortByGain = UIAction(title: "Most Gainers (24h)", image: UIImage(systemName: "arrow.up")) { action in
            self.filtersBarButtonTapped(.mostGainers)
        }

        let sortByLose = UIAction(title: "Most Loosers (24h)", image: UIImage(systemName: "arrow.down")) { action in
            self.filtersBarButtonTapped(.mostLoosers)
        }
        
        let menu = UIMenu(title: "Sort Options", children: [sortByName, sortByPrice, sortByGain, sortByLose])
        let menuButton = UIBarButtonItem(
            title: nil,
            image: UIImage(systemName: "arrow.up.arrow.down"),
            primaryAction: nil,
            menu: menu
        )
        
        navigationItem.rightBarButtonItems = [favouritesButton, menuButton]
    }
    
    
    @objc private func settingsBarButtonTapped() {
        print("settings bar button tapped")
        settingsTap.send()
    }

    @objc private func favouritesBarButtonTapped() {
        print("favourites bar button tapped")
        favouriteTap.send()
    }
    
    private func filtersBarButtonTapped(_ sortOption: SortOption) {
        print("filters bar button tapped")
        sortTap.send(sortOption)
    }

}
