//
//  PostsListCoordinator.swift
//  LeagueiOSChallenge
//
//  Created by macbook pro on 2025-02-20.
//

import Combine
import UIKit

final class PostsListCoordinator: Coordinator {
    typealias CompletionType = Void
    
    private weak var navigationController: UINavigationController?
    
    private var cancellables: Set<AnyCancellable> = []
    
    public init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    @discardableResult
    func start(animated: Bool) -> CompletionPublisher {
        let apiService = API(urlSession: .init(configuration: .default))
        let postsListUseCase = PostsListUseCase(apiService: apiService)
        let viewModel = PostsListViewModel(postsListUseCase: postsListUseCase)
        let viewController = PostsListViewController(viewModel: viewModel)
        
        viewModel.showUserInfo
            .sink {
                self.showUserInfo()
            }
            .store(in: &cancellables)
        
        viewModel.navigateBack
            .sink {
                self.navigateBackToLogin()
            }
            .store(in: &cancellables)
        
        navigationController?.pushViewController(viewController, animated: animated)
        
        return .never()
    }
    
    private func showUserInfo() {
        if let user = KeychainService.shared.loadUser() {
            let imageLoader: ImageLoaderService = ImageLoader()
            let viewModel = UserInfoViewModel(user: user, imageLoader: imageLoader)
            let viewController = UserInfoViewController(viewModel: viewModel)
            let navController = UINavigationController(rootViewController: viewController)
            navigationController?.present(navController, animated: true, completion: nil)
        } else {
            print("User not found in Keychain")
        }
    }
    
    private func navigateBackToLogin() {
        navigationController?.popToRootViewController(animated: true)
    }
}
