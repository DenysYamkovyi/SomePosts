//
//  PostTableViewCellViewModel.swift
//  MovieIMDB
//
//  Created by macbook pro on 2024-07-22.
//

import UIKit
import Combine

protocol PostTableViewCellViewModel {
    var avatar: String { get }
    var username: String { get }
    var title: String { get }
    var description: String { get }
    
    var onButtonAction: PassthroughSubject<Void, Never> { get }
}

class PostTableViewCellView: UITableViewCell {
    static let reuseIdentifier = "PostTableViewCellView"
    
    private var cancellables = Set<AnyCancellable>()
    
    // Subviews
    private let avatarImageView = UIImageView()
    private let usernameLabel = UILabel()
    private let titleLabel = UILabel()
    private let descriptionLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    private func setupViews() {
        contentView.addSubview(avatarImageView)
        contentView.addSubview(usernameLabel)
        contentView.addSubview(titleLabel)
        contentView.addSubview(descriptionLabel)
        
        setupAvatarImageView()
        setupUsernameLabel()
        setupTitleLabel()
        setupDescriptionLabel()
    }
    
    private func setupAvatarImageView() {
        avatarImageView.translatesAutoresizingMaskIntoConstraints = false
        avatarImageView.contentMode = .scaleAspectFit
        avatarImageView.clipsToBounds = true

        NSLayoutConstraint.activate([
            avatarImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            avatarImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            avatarImageView.widthAnchor.constraint(equalToConstant: 60),
            avatarImageView.heightAnchor.constraint(equalToConstant: 90),
            avatarImageView.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -8)
        ])
    }

    private func setupUsernameLabel() {
        usernameLabel.translatesAutoresizingMaskIntoConstraints = false
        usernameLabel.numberOfLines = 1
        usernameLabel.font = UIFont.boldSystemFont(ofSize: 16)
        
        NSLayoutConstraint.activate([
            usernameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            usernameLabel.leadingAnchor.constraint(equalTo: avatarImageView.trailingAnchor, constant: 8),
            usernameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8)
        ])
    }
    
    private func setupTitleLabel() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.numberOfLines = 0
        titleLabel.font = UIFont.systemFont(ofSize: 14)
        titleLabel.textColor = .darkGray
        
        // Title label should be below the username label.
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: usernameLabel.bottomAnchor, constant: 4),
            titleLabel.leadingAnchor.constraint(equalTo: avatarImageView.trailingAnchor, constant: 8),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8)
        ])
    }
    
    private func setupDescriptionLabel() {
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.numberOfLines = 0
        descriptionLabel.font = UIFont.systemFont(ofSize: 12)
        descriptionLabel.textColor = .gray
        
        // Description label should be below the title label.
        NSLayoutConstraint.activate([
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            descriptionLabel.leadingAnchor.constraint(equalTo: avatarImageView.trailingAnchor, constant: 8),
            descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            descriptionLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -8)
        ])
    }
}

extension PostTableViewCellView: Configurable {
    func configure(with viewModel: PostTableViewCellViewModel) {
        cancellables.removeAll()
        
        usernameLabel.text = viewModel.username
        titleLabel.text = viewModel.title
        descriptionLabel.text = viewModel.description
        
        ImageLoader().loadImage(path: viewModel.avatar)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in }, receiveValue: { [weak self] image in
                self?.avatarImageView.image = image
            })
            .store(in: &cancellables)
    }
}
