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


extension Double {
    func prettyCurrency(locale: Locale = Locale.current) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2
        formatter.locale = locale
        return (formatter.string(from: NSNumber(value: self)) ?? "\(self)") + "$"
    }
}

extension Optional where Wrapped == Double {
    func prettyCurrency(locale: Locale = Locale.current) -> String {
        guard let value = self else { return "–" } // or "" or "0,00", depending on your UX
        return value.prettyCurrency()
    }
}
