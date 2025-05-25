//
//  UIKit+Extensions.swift
//  CryptoTracker
//
//  Created by lil angee on 21.05.25.
//

import UIKit
import Combine

extension UIStoryboard {
    func instantiateViewController<T: UIViewController>(withIdentifier vcName: VCNames) -> T {
        guard let vc = instantiateViewController(withIdentifier: vcName.identifier) as? T else {
            fatalError("Could not instantiate view controller with identifier \(vcName.identifier)")
        }
        return vc
    }
}

extension UINavigationController {
    func showAlert(title: String, message: String?) {
        let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "ok", style: .cancel, handler: { action in
            (action.value(forKeyPath: "alertController") as? UIAlertController)?.dismiss(animated: true)
        }))
        present(ac, animated: true)
    }
}
