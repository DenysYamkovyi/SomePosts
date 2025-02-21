//
//  AppCoordinator.swift
//  MovieIMDB
//
//  Created by macbook pro on 2024-07-22.
//

import Combine
import UIKit

protocol Coordinator {
    associatedtype CompletionType
    typealias CompletionPublisher = AnyPublisher<CompletionType, Never>
    
    func start(animated: Bool) -> CompletionPublisher
}

final class AppCoordinator: Coordinator {
    typealias CompletionType = Void
    
    private let window : UIWindow
    private var childCoordinators: [any Coordinator] = []
    
    init(window: UIWindow) {
        self.window = window
    }
    
    @discardableResult
    func start(animated: Bool) -> CompletionPublisher {
        let rootViewController = UINavigationController()
        
        window.rootViewController = rootViewController
        window.makeKeyAndVisible()
        
        let coordinator = LoginCoordinator(navigationController: rootViewController)
        coordinator.start(animated: false)
        
        childCoordinators.append(coordinator)
        
        return .never()
    }
}

