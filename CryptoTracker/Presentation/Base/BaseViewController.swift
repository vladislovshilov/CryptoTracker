//
//  BaseViewController.swift
//  CryptoTracker
//
//  Created by lil angee on 21.05.25.
//

import UIKit

protocol ViewModeling {
    func onAppear()
    func onDisappear()
}

class BaseViewController<ViewModel: ViewModeling>: UIViewController {
    
    var onSettingsButtonTap: (() -> Void)?
    var onFavouritesButtonTap: (() -> Void)?
    var onFilterTap: (() -> Void)?
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.onAppear()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        viewModel.onDisappear()
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
        let filtersButton = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(filtersBarButtonTapped))
        navigationItem.rightBarButtonItems = [favouritesButton, filtersButton]
    }
    
    
    @objc private func settingsBarButtonTapped() {
        print("settings bar button tapped")
        onSettingsButtonTap?()
    }

    @objc private func favouritesBarButtonTapped() {
        onFavouritesButtonTap?()
        print("favourites bar button tapped")
    }
    
    @objc private func filtersBarButtonTapped() {
        print("filters bar button tapped")
        onFilterTap?()
    }

}
