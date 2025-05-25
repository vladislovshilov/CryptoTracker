//
//  EmptyStateView.swift
//  CryptoTracker
//
//  Created by lil angee on 25.05.25.
//

import UIKit

final class EmptyStateView: UIView {
    
    private let messageLabel = UILabel()
    
    init(message: String) {
        super.init(frame: .zero)
        setupUI(message: message)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI(message: "No data available")
    }
    
    private func setupUI(message: String) {
        messageLabel.text = message
        messageLabel.textColor = .gray
        messageLabel.textAlignment = .center
        messageLabel.numberOfLines = 0
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(messageLabel)
        
        NSLayoutConstraint.activate([
            messageLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            messageLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            messageLabel.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: 16),
            messageLabel.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -16)
        ])
    }
    
    func updateMessage(_ text: String) {
        messageLabel.text = text
    }
}

