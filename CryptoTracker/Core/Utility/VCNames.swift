//
//  VCNames.swift
//  CryptoTracker
//
//  Created by lil angee on 25.05.25.
//

import Foundation

enum VCNames: String {
    case vc = "ViewController"
    case favourites = "FavouritesViewController"
    case settings = "SettingsViewController"
    case details = "DetailsViewController"
    
    var identifier: String { rawValue }
}
