//
//  APIHelper.swift
//  LeagueiOSChallenge
//
//  Copyright © 2024 League Inc. All rights reserved.
//

import Foundation

enum APIError: Error {
    case invalidEndpoint
    case decodeFailure
}

enum APIEndpoint: String {
    case login = "login"

    func getURL() -> URL? {
        let baseUrlString = "https://engineering.league.dev/challenge/api/"
        let urlString = "\(baseUrlString)\(rawValue)"

        return URL(string: urlString)
    }
}

class APIHelper {

    func fetchUserToken(
        username: String,
        password: String) async throws
    -> String
    {
        guard let url = APIEndpoint.login.getURL() else {
            throw APIError.invalidEndpoint
        }

        let authString = "\(username):\(password)"
        let authData = Data(authString.utf8)
        let base64AuthString = "Basic \(authData.base64EncodedString())"
        let urlSessionConfig: URLSessionConfiguration = .default
        urlSessionConfig.httpAdditionalHeaders = ["Authorization": base64AuthString]
        let session = URLSession(configuration: urlSessionConfig)
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase

        let (data, _) = try await session.data(for: URLRequest(url: url))

        if let results = try? decoder.decode(LoginResponse.self, from: data) {
            return results.apiKey
        } else {
            throw APIError.decodeFailure
        }
    }
}
