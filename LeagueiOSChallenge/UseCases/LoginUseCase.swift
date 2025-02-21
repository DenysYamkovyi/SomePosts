//
//  LoginViewModelUseCase.swift
//  LeagueiOSChallenge
//
//  Created by macbook pro on 2025-02-20.
//

import Combine
import Foundation

struct LoginUseCase: LoginViewModelUseCase {
    private let apiService: APIService
    
    init(apiService: APIService) {
        self.apiService = apiService
    }
    
    func fetchUserToken(email: String, password: String) -> AnyPublisher<Bool, Error> {
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
        .tryMap { data -> Bool in
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            let response = try decoder.decode(LoginResponse.self, from: data)
            let token = response.apiKey
            
            // Save token in Keychain; throw an error if saving fails.
            guard KeychainService.shared.saveToken(token) else {
                throw APIError.decodeFailure
            }
            
            return !token.isEmpty
        }
        .receive(on: DispatchQueue.main)
        .handleEvents(receiveCompletion: { _ in
            // Update state here if needed
        })
        .eraseToAnyPublisher()
    }
    
    func fetchUser() -> AnyPublisher<Bool, Error> {
        return apiService.request(
            endpoint: .users,
            method: .get,
            queryParams: nil,
            body: nil,
            headers: nil
        )
        .tryMap { data -> Bool in
            // Print JSON string for debugging
            if let jsonString = String(data: data, encoding: .utf8) {
                print("JSON String: \(jsonString)")
            } else {
                print("Failed to convert data to a string")
            }
            
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            // Decode an array of users because the JSON is an array.
            let response = try decoder.decode([UserResponse].self, from: data)
            
            // Use the first user (or adjust as needed)
            guard let user = response.first else {
                throw APIError.decodeFailure
            }
            
            // Save the user in Keychain; throw an error if saving fails.
            guard KeychainService.shared.saveUser(user) else {
                throw APIError.decodeFailure
            }
            
            // Return true to indicate a successful user fetch.
            return true
        }
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }
}
