//
//  FavouritesViewController.swift
//  CryptoTracker
//
//  Created by lil angee on 21.05.25.
//

import UIKit

class FavouritesViewController: BaseViewController<FavouriteViewModel> {
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.leftBarButtonItem = nil
    }
    
    @IBAction func buttonDidPress(_ sender: Any) {
        popVC?()
    }
}
