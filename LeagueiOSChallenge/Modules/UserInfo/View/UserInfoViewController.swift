//
//  UserInfoViewController.swift
//  LeagueiOSChallenge
//
//  Created by macbook pro on 2025-02-21.
//

import Combine
import UIKit

protocol UserInfoViewControllerViewModel: ObservableObject {
    var avatar: UIImage? { get }
    var username: String { get }
    var email: String { get }
    var error: PassthroughSubject<Error, Never> { get }
}

final class UserInfoViewController<ViewModel>: ViewController where ViewModel: UserInfoViewControllerViewModel {

    private let viewModel: ViewModel
    private let avatarImageView = UIImageView()
    private let usernameLabel = UILabel()
    private let emailLabel = UILabel()
    
    private var cancellables = Set<AnyCancellable>()
    
    init(viewModel: ViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("Storyboards not supported")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        bindToViewModel()
        updateView()
    }
    
    private func setupView() {
        view.backgroundColor = .white
        
        let stackView = UIStackView(arrangedSubviews: [avatarImageView, usernameLabel, emailLabel])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.alignment = .center
        view.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
        
        // Configure avatarImageView
        avatarImageView.contentMode = .scaleAspectFit
        avatarImageView.clipsToBounds = true
        NSLayoutConstraint.activate([
            avatarImageView.heightAnchor.constraint(equalToConstant: 200),
            avatarImageView.widthAnchor.constraint(equalToConstant: 200)
        ])
        
        usernameLabel.font = .preferredFont(forTextStyle: .headline)
        emailLabel.font = .preferredFont(forTextStyle: .subheadline)
    }
    
    private func bindToViewModel() {
        viewModel.objectWillChange
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in self?.updateView() }
            .store(in: &cancellables)
        
        viewModel.error
            .receive(on: DispatchQueue.main)
            .sink { [weak self] error in self?.handleError(error) }
            .store(in: &cancellables)
    }
    
    private func handleError(_ error: Error) {
        let alert = UIAlertController(title: error.localizedDescription, message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private func updateView() {
        avatarImageView.image = viewModel.avatar
        usernameLabel.text = viewModel.username
        emailLabel.text = viewModel.email
    }
}
