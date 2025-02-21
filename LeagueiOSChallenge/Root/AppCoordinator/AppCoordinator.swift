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
    
    private let window: UIWindow
    private var childCoordinators: [any Coordinator] = []
    private var cancellables: Set<AnyCancellable> = []
    
    init(window: UIWindow) {
        self.window = window
    }
    
    @discardableResult
    func start(animated: Bool) -> AnyPublisher<Void, Never> {
        let rootNavigationController = UINavigationController()
        window.rootViewController = rootNavigationController
        window.makeKeyAndVisible()
        
        let loginCoordinator = LoginCoordinator(navigationController: rootNavigationController)
        childCoordinators.append(loginCoordinator)
        
        loginCoordinator.start(animated: false)
        
        loginCoordinator.didFinishLogin
            .sink { [weak self] in
                guard let self = self else { return }
                self.startPostsCoordinator(on: rootNavigationController)
            }
            .store(in: &cancellables)
        
        return .never()
    }
    
    private func startPostsCoordinator(on navigationController: UINavigationController) {
        let postsCoordinator = PostsListCoordinator(navigationController: navigationController)
        childCoordinators.append(postsCoordinator)
        postsCoordinator.start(animated: true)
            .sink { _ in }
            .store(in: &cancellables)
    }
}
