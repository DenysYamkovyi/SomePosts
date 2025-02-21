//
//  UserInfoViewModel.swift
//  LeagueiOSChallenge
//
//  Created by macbook pro on 2025-02-21.
//

import Combine
import UIKit

final class UserInfoViewModel: UserInfoViewControllerViewModel {
    @Published private(set) var avatar: UIImage? = nil
    private(set) var username: String
    private(set) var email: String
    
    let error: PassthroughSubject<Error, Never> = .init()
    
    private let imageLoader: ImageLoaderService
    private var cancellables: Set<AnyCancellable> = []
    
    init(user: UserResponse, imageLoader: ImageLoaderService) {
        self.username = user.username
        self.email = user.email
        self.imageLoader = imageLoader
        loadAvatar(from: user.avatar)
    }
    
    private func loadAvatar(from path: String) {
        imageLoader.loadImage(path: path)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                if case let .failure(err) = completion {
                    self?.error.send(err)
                }
            }, receiveValue: { [weak self] image in
                self?.avatar = image
            })
            .store(in: &cancellables)
    }
}
