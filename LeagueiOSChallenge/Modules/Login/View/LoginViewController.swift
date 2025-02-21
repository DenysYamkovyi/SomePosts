//
//  LoginViewController.swift
//  LeagueiOSChallenge
//
//  Created by macbook pro on 2025-02-19.
//

import Combine
import UIKit

protocol LoginViewControllerViewModel: ObservableObject {
    var email: String { get set }
    var password: String { get set }
    var isLoading: Bool { get }
    
    var error: PassthroughSubject<Error, Never> { get }
    
    func login()
    func guestLogin()
}

final class LoginViewController<ViewModel>: BaseViewController where ViewModel: LoginViewControllerViewModel {
    private let viewModel: ViewModel
    private var activityIndicatorView: UIActivityIndicatorView?

    let emailFieldView = TextFieldView()
    let passwordFieldView = TextFieldView()
    let loginButtonView = ButtonView()
    let guestButtonView = ButtonView()
    
    private var cancellables: Set<AnyCancellable> = []
    
    init(viewModel: ViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("Storyboards not supported")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupViews()
        bindToViewModel()
        updateView()
    }
    
    private func setupViews() {
        // Setup stack view
        let stackView = UIStackView(arrangedSubviews: [
            emailFieldView,
            passwordFieldView,
            loginButtonView,
            guestButtonView
        ])
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.alignment = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
        
        // Configure custom views
        let emailVM = DefaultTextFieldViewModel(title: "Email", placeholder: "Enter your email", validator: "")
        let passwordVM = DefaultTextFieldViewModel(title: "Password", placeholder: "Enter your password", validator: "")
        let loginVM = DefaultButtonViewModel(title: "Login")
        let guestVM = DefaultButtonViewModel(title: "Continue as Guest")
        
        emailFieldView.configure(with: emailVM)
        passwordFieldView.configure(with: passwordVM)
        loginButtonView.configure(with: loginVM)
        guestButtonView.configure(with: guestVM)
        
        // Bind button actions to controller logic
        loginVM.onButtonAction
            .sink { [weak self] in self?.handleLogin() }
            .store(in: &cancellables)
        
        guestVM.onButtonAction
            .sink { [weak self] in self?.handleGuestLogin() }
            .store(in: &cancellables)
        
        emailVM.onEditAction
            .sink { print("Email field edited") }
            .store(in: &cancellables)
        
        passwordVM.onEditAction
            .sink { print("Password field edited") }
            .store(in: &cancellables)
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
    
    private func updateView() {
        view.isUserInteractionEnabled = !viewModel.isLoading
        updateActivityIndicator()
    }
    
    private func updateActivityIndicator() {
        if viewModel.isLoading,
           activityIndicatorView == nil {
            let activity = UIActivityIndicatorView(style: .large)
            activity.translatesAutoresizingMaskIntoConstraints = false
            activity.startAnimating()
            view.addSubview(activity)
            
            activity.bindToCenter()
            
            activityIndicatorView = activity
        } else if activityIndicatorView != nil {
            activityIndicatorView?.stopAnimating()
            activityIndicatorView?.removeFromSuperview()
            activityIndicatorView = nil
        }
    }
    
    private func handleError(_ error: Error) {
        let alertViewController = UIAlertController(
            title: error.localizedDescription,
            message: nil,
            preferredStyle: .alert
        )
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertViewController.addAction(okAction)
        present(alertViewController, animated: true)
    }
    
    // MARK: - Button Handlers
    
    private func handleLogin() {
        viewModel.email = emailFieldView.text
        viewModel.password = passwordFieldView.text
        
        viewModel.login()
    }
    
    private func handleGuestLogin() {
        viewModel.guestLogin()
    }
}
