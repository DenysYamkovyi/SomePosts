//
//  LoginCoordinator.swift
//  LeagueiOSChallenge
//
//  Copyright © 2024 League Inc. All rights reserved.
//

import Combine
import UIKit

final class LoginCoordinator: Coordinator {
    typealias CompletionType = Void
    
    private weak var navigationController: UINavigationController?
    
    private var cancellables: Set<AnyCancellable> = []
    
    public init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    @discardableResult
    func start(animated: Bool) -> CompletionPublisher {
        let apiService = API(urlSession: .init(configuration: .default))
        let viewModel = LoginViewModel(apiService: apiService)
        let viewController = LoginViewController(viewModel: viewModel)
        
        viewModel.showPosts
            .sink { [weak self] movie in
                self?.showPosts()
            }
            .store(in: &cancellables)
        
        navigationController?.pushViewController(viewController, animated: animated)
        
        return .never()
    }
    
    private func showPosts() {
//        let viewModel = PostsListViewModel()
//        let viewController = PostsListViewController(viewModel: viewModel)
//
//        navigationController?.pushViewController(viewController, animated: true)
    }
}

