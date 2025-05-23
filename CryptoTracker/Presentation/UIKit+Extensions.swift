//
//  UIKit+Extensions.swift
//  CryptoTracker
//
//  Created by lil angee on 21.05.25.
//

import UIKit

extension UIStoryboard {
    func instantiateViewController<T: UIViewController>(withIdentifier vcName: VCNames) -> T {
        guard let vc = instantiateViewController(withIdentifier: vcName.identifier) as? T else {
            fatalError("Could not instantiate view controller with identifier \(vcName.identifier)")
        }
        return vc
    }
}
