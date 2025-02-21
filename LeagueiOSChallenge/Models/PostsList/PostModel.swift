//
//  PostModel.swift
//  LeagueiOSChallenge
//
//  Created by macbook pro on 2025-02-20.
//

import Combine
import Foundation

struct PostModel: PostTableViewCellViewModel, Hashable {
    let avatar: String
    let username: String
    let title: String
    let description: String
    
    @HashableExcluded
    var onButtonAction: PassthroughSubject<Void, Never> = .init()
}

extension PostModel {
    init(title: String, body: String, user: UserResponse) {
        self.avatar = user.avatar
        self.username = user.username
        self.title = title
        self.description = body
    }
}
