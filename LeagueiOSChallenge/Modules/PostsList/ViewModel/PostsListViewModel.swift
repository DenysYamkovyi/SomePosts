//
//  PostsListViewModel.swift
//  LeagueiOSChallenge
//
//  Created by macbook pro on 2025-02-20.
//

import Combine
import UIKit

protocol PostsListViewModelUseCase {
    func fetchPosts(userId: String) -> AnyPublisher<[PostModel], Error>
}

final class PostsListViewModel: PostsListViewControllerViewModel {
    @Published var posts: [PostModel] = []
    @Published var isLoading: Bool = false
    @Published var showError: Bool = false
    @Published var errorMessage: String? = nil
    
    private let postsListUseCase: PostsListViewModelUseCase
    
    private var originalPostsList: [PostModel] = [] {
        didSet {
            posts = originalPostsList
        }
    }
    
    let error: PassthroughSubject<Error, Never> = .init()
    
    @Passthrough var showUserInfo: AnyPublisher<Void, Never>
    @Passthrough var navigateBack: AnyPublisher<Void, Never>
    
    private var cancellables: Set<AnyCancellable> = .init()
    
    init(postsListUseCase: PostsListViewModelUseCase) {
        self.postsListUseCase = postsListUseCase
    }
    
    func getPosts(userId: String) {
        guard !isLoading else {
            return
        }
        
        isLoading = true
        showError = false
        errorMessage = nil
        
        postsListUseCase
            .fetchPosts(userId: userId)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] result in
                self?.isLoading = false
                switch result {
                case let .failure(error):
                    self?.showError = true
                    self?.errorMessage = error.localizedDescription
                    self?.error.send(error)
                default:
                    break
                }
            }, receiveValue: { [weak self] posts in
                guard let self else { return }
                self.originalPostsList = posts
            })
            .store(in: &cancellables)
    }
    
    func userDidSelect() {
        _showUserInfo.subject.send()
    }
    
    func navigateBackToLogin() {
        KeychainService.shared.deleteToken()
        KeychainService.shared.deleteUser()
        KeychainService.shared.deleteGuestLogin()
        _navigateBack.subject.send()
    }
    
}


