//
//  APIHelper.swift
//  LeagueiOSChallenge
//
//  Copyright © 2024 League Inc. All rights reserved.
//

import Foundation
import Combine

enum APIError: Error {
    case invalidEndpoint
    case decodeFailure
}

enum APIEndpoint: String {
    case login = "login"
    case users = "users"
    case posts = "posts"
    case albums = "albums"
    case photos = "photos"
}

enum APIMethod: String {
    case get = "GET"
}

protocol APIService {
    func request(
        endpoint: APIEndpoint,
        method: APIMethod,
        queryParams: [String: String]?,
        body: Data?,
        headers: [String: String]?
    ) -> AnyPublisher<Data, Error>
}

final class API: APIService {
    private let urlSession: URLSession
    // Initialize baseUrl as a URL constant.
    private let baseUrl: URL = URL(string: "https://engineering.league.dev/challenge/api/")!
    
    var token: String? {
        get {
            return KeychainService.shared.loadToken()
        }
        set {
            if let newToken = newValue {
                _ = KeychainService.shared.saveToken(newToken)
            } else {
                _ = KeychainService.shared.deleteToken()
            }
        }
    }
    
    init(urlSession: URLSession) {
        self.urlSession = urlSession
    }
    
    func request(
        endpoint: APIEndpoint,
        method: APIMethod,
        queryParams: [String: String]? = nil,
        body: Data? = nil,
        headers: [String: String]? = nil
    ) -> AnyPublisher<Data, Error> {
        // Compose URL using the base URL and endpoint's raw value.
        guard var components = URLComponents(string: baseUrl.absoluteString) else {
            fatalError("Cannot compose URLComponents")
        }
        components.path = (components.path as NSString).appendingPathComponent(endpoint.rawValue)

        if let queryParams = queryParams {
            components.queryItems = queryParams.map { URLQueryItem(name: $0.key, value: $0.value) }
        }

        guard let url = components.url else {
            fatalError("Cannot compose URL")
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        
        // Add custom headers if provided.
        if let headers = headers {
            headers.forEach { key, value in
                request.addValue(value, forHTTPHeaderField: key)
            }
        }
        
        // For endpoints other than login, add the x-access-token header if a token exists.
        if endpoint != .login, let token = self.token {
            request.addValue(token, forHTTPHeaderField: "x-access-token")
        }
        
        // Set HTTP body if provided.
        if let body = body {
            request.httpBody = body
        }
        
        return urlSession.dataTaskPublisher(for: request)
            .tryMap { element -> Data in
                guard let response = element.response as? HTTPURLResponse else {
                    throw URLError(.badServerResponse)
                }
                switch response.statusCode {
                case 401:
                    throw URLError(.userAuthenticationRequired)
                case 200...299:
                    return element.data
                default:
                    throw URLError(.badServerResponse)
                }
            }
            .eraseToAnyPublisher()
    }
}
