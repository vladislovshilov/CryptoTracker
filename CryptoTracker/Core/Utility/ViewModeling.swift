//
//  ViewModeling.swift
//  CryptoTracker
//
//  Created by lil angee on 24.05.25.
//

import Foundation

@objc protocol ViewModeling {
    @objc optional func onAppear()
    @objc optional func onDisappear()
}
