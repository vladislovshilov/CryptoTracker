//
//  Foundation+Extension.swift
//  CryptoTracker
//
//  Created by lil angee on 25.05.25.
//

import Foundation

extension Collection {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
