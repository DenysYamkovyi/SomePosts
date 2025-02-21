//
//  LoginViewModel.swift
//  LeagueiOSChallenge
//
//  Created by macbook pro on 2025-02-19.
//

import Combine
import UIKit

final class LoginViewModel: LoginViewControllerViewModel {
    // MARK: - Properties
    var email: String = ""
    var password: String = ""
    let loginText: String
    let guestText: String
    
    @Published var isLoading: Bool = false
    @Published var showError: Bool = false
    @Published var errorMessage: String? = nil
    
    var error: PassthroughSubject<any Error, Never> = .init()
    
    private let apiService: APIService
    
    let showPosts = PassthroughSubject<Void, Never>()
    
    // MARK: - Initializer
    init(apiService: APIService) {
        self.loginText = "Login"
        self.guestText = "Continue as Guest"
        self.apiService = apiService
    }
    
    // MARK: - Public Methods
    func fetchUserToken() -> AnyPublisher<Void, Error> {
        // Validate input and avoid duplicate requests
        guard !isLoading, email.count > 2, password.count > 2 else {
            return Fail(error: NSError(domain: "",
                                       code: -1,
                                       userInfo: [NSLocalizedDescriptionKey: "Invalid credentials"]))
                .eraseToAnyPublisher()
        }
        
        isLoading = true
        showError = false
        errorMessage = nil
        
        // Create the Basic Auth header value.
        let authString = "\(email):\(password)"
        let authData = Data(authString.utf8)
        let base64AuthString = "Basic \(authData.base64EncodedString())"
        
        return apiService.request(
            endpoint: .login,
            method: .get,
            queryParams: nil,
            body: nil,
            headers: ["Authorization": base64AuthString]
        )
        .tryMap { [weak self] data -> Void in
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            let response = try decoder.decode(LoginResponse.self, from: data)
            let token = response.apiKey
            // Save token in Keychain
            _ = KeychainService.shared.saveToken(token)
            self?.showPosts.send()
            return ()
        }
        .receive(on: DispatchQueue.main)
        .handleEvents(receiveCompletion: { [weak self] _ in
            self?.isLoading = false
        })
        .eraseToAnyPublisher()
    }
    
    func guestLogin() -> AnyPublisher<Void, Error> {
        isLoading = true
        return Future<Void, Error> { [weak self] promise in
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                guard let self = self else {
                    promise(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Self is nil"])))
                    return
                }
                self.showPosts.send()
                self.isLoading = false
                promise(.success(()))
            }
        }
        .eraseToAnyPublisher()
    }
}
