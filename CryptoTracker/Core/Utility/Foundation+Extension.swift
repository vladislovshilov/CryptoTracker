//
//  Foundation+Extension.swift
//  CryptoTracker
//
//  Created by lil angee on 25.05.25.
//

import Foundation
import Combine

extension Set where Element: Identifiable {
    mutating func update(with newElements: Set<Element>) {
        let newIDs = newElements.map { $0.id }
        self = filter { !newIDs.contains($0.id) }
        formUnion(newElements)
    }
}

extension CurrentValueSubject where Output == [CryptoCurrency], Failure == Never {
    func sorted(by sortOptionPublisher: AnyPublisher<SortOption, Never>) -> AnyPublisher<[CryptoCurrency], Never> {
        self.combineLatest(sortOptionPublisher)
            .map { coins, sortOption in
                coins.sorted(by: sortOption.sort)
            }
            .eraseToAnyPublisher()
    }
}

extension Collection {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

extension Double {
    func prettyCurrency(locale: Locale = Locale.current) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        if self >= 1 {
            formatter.minimumFractionDigits = 0
            formatter.maximumFractionDigits = 2
        } else {
            formatter.minimumFractionDigits = 2
            formatter.maximumFractionDigits = 8
        }
        formatter.locale = locale
        return (formatter.string(from: NSNumber(value: self)) ?? "\(self)") + "$"
    }
}

extension Optional where Wrapped == Double {
    func prettyCurrency(locale: Locale = Locale.current) -> String {
        guard let value = self else { return "–" }
        return value.prettyCurrency()
    }
}
