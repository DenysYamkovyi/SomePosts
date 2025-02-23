//
//  LoginViewModel.swift
//  LeagueiOSChallenge
//
//  Created by macbook pro on 2025-02-19.
//

import Combine
import UIKit

protocol LoginViewModelUseCase {
    func fetchUserToken(email: String, password: String) -> AnyPublisher<Bool, Error>
    func fetchUser() -> AnyPublisher<Bool, Error>
}

final class LoginViewModel: LoginViewControllerViewModel {

    var email: String = ""
    var password: String = ""
    var isGuestLogin = false
    
    @Published var isLoading: Bool = false
    @Published var showError: Bool = false
    @Published var errorMessage: String? = nil
    
    var error: PassthroughSubject<any Error, Never> = .init()
    
    private let loginViewModelUseCase: LoginViewModelUseCase
    let showPosts = PassthroughSubject<Void, Never>()
    
    private var cancellables: Set<AnyCancellable> = []
    
    init(loginViewModelUseCase: LoginViewModelUseCase) {
        self.loginViewModelUseCase = loginViewModelUseCase
    }
    
    func login() {
        guard isValidEmail(email) else {
            return
        }
        performLogin(withEmail: email, password: password)
    }
    
    func guestLogin() {
        isGuestLogin = true
        performLogin(withEmail: "guest@email.com", password: "")
    }
    
    private func performLogin(withEmail email: String, password: String) {
        guard !isLoading, email.count > 0, password.count >= 0 else {
            return
        }
        
        isLoading = true
        showError = false
        errorMessage = nil
        
        loginViewModelUseCase
            .fetchUserToken(email: email, password: password)
            .flatMap { [weak self] tokenSuccess -> AnyPublisher<Bool, Error> in
                guard let self = self else {
                    return Fail(error: NSError(domain: "", code: -1,
                                               userInfo: [NSLocalizedDescriptionKey: "Self is nil"]))
                        .eraseToAnyPublisher()
                }
                guard tokenSuccess else {
                    return Fail(error: NSError(domain: "", code: -1,
                                               userInfo: [NSLocalizedDescriptionKey: "Token fetch failed"]))
                        .eraseToAnyPublisher()
                }
                return self.loginViewModelUseCase.fetchUser()
            }
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                self?.isLoading = false
                if case let .failure(error) = completion {
                    self?.showError = true
                    self?.errorMessage = error.localizedDescription
                    self?.error.send(error)
                }
            }, receiveValue: { [weak self] isUser in
                guard let self = self else { return }
                if isUser {
                    KeychainService.shared.saveGuestLogin(self.isGuestLogin)
                    self.showPosts.send()
                }
            })
            .store(in: &cancellables)
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        guard let domainPart = email.split(separator: "@").last else { return false }
        let domain = domainPart.lowercased()
        return domain.hasSuffix(".com") || domain.hasSuffix(".net") || domain.hasSuffix(".biz")
    }
}
