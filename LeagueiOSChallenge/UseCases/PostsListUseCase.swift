//
//  PostsListUseCase.swift
//  LeagueiOSChallenge
//
//  Created by macbook pro on 2025-02-21.
//

import Combine
import Foundation

struct PostsListUseCase: PostsListViewModelUseCase {
    private let apiService: APIService
    
    init(apiService: APIService) {
        self.apiService = apiService
    }
    
    func fetchPosts(userId: String) -> AnyPublisher<[PostModel], Error> {
        let queryParams = ["userId": userId]
        
        return apiService.request(
            endpoint: .posts,
            method: .get,
            queryParams: queryParams,
            body: nil,
            headers: nil
        )
        .tryMap { data -> [PostResponse] in
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase

            return try decoder.decode([PostResponse].self, from: data)
        }
        .map { postResponses in
            if let user = KeychainService.shared.loadUser() {
                return postResponses.map { post in
                    PostModel(title: post.title, body: post.body, user: user)
                }
            } else {
                return []
            }
        }
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }
}
