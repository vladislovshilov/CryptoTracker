//
//  SceneDelegate.swift
//  CryptoTracker
//
//  Created by lil angee on 21.05.25.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    var coordinator: Coordinator?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        let window = UIWindow(windowScene: windowScene)
        
        let navController = UINavigationController()
        coordinator = Coordinator(windows: windowScene.windows, navigationController: navController)
        coordinator?.start()
        
        window.rootViewController = navController
        self.window = window
        window.makeKeyAndVisible()
    }
}

