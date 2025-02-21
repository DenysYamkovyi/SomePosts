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
    
    let didFinishLogin = PassthroughSubject<Void, Never>()
    
    private var cancellables: Set<AnyCancellable> = []
    
    public init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    @discardableResult
    func start(animated: Bool) -> CompletionPublisher {
        let apiService = API(urlSession: .init(configuration: .default))
        let loginUseCase = LoginUseCase(apiService: apiService)
        let viewModel = LoginViewModel(loginViewModelUseCase: loginUseCase)
        let viewController = LoginViewController(viewModel: viewModel)
        
        viewModel.showPosts
            .sink { [weak self] in
                self?.didFinishLogin.send()
            }
            .store(in: &cancellables)
        
        navigationController?.pushViewController(viewController, animated: animated)
        
        return .never()
    }
}

