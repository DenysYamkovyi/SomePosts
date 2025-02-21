//
//  LoginUseCaseTests.swift
//  LeagueiOSChallenge
//
//  Created by macbook pro on 2025-02-21.
//

import XCTest
import Combine
@testable import LeagueiOSChallenge

// MARK: - Test Models
private struct LoginResponse: Codable {
    let apiKey: String
}

private struct UserResponse: Codable, Equatable {
    let id: Int
    let avatar: String
    let username: String
    let email: String
}

// MARK: - Mock APIService
private final class MockAPIService: APIService {
    var result: Result<Data, Error>!
    
    func request(endpoint: APIEndpoint,
                 method: APIMethod,
                 queryParams: [String : String]?,
                 body: Data?,
                 headers: [String : String]?) -> AnyPublisher<Data, Error> {
        return result.publisher.eraseToAnyPublisher()
    }
}

// MARK: - LoginUseCaseTests
final class LoginUseCaseTests: XCTestCase {
    var cancellables = Set<AnyCancellable>()
    
    // Ensure a clean state before each test
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        cancellables.removeAll()
        super.tearDown()
    }
    
    func testFetchUserTokenSuccess() {
        // Prepare a valid login response with a non-empty token.
        let validResponse = LoginResponse(apiKey: "SOME_VALID_TOKEN")
        guard let responseData = try? JSONEncoder().encode(validResponse) else {
            XCTFail("Failed to encode validResponse")
            return
        }
        
        let mockService = MockAPIService()
        mockService.result = .success(responseData)
        
        let useCase = LoginUseCase(apiService: mockService)
        
        let expectation = XCTestExpectation(description: "fetchUserToken returns true")
        
        useCase.fetchUserToken(email: "test@example.com", password: "password")
            .sink(receiveCompletion: { completion in
                if case let .failure(error) = completion {
                    XCTFail("Expected success, but got error: \(error)")
                }
            }, receiveValue: { success in
                XCTAssertTrue(success, "Expected non-empty token to return true")
                expectation.fulfill()
            })
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testFetchUserTokenFailure() {
        // Prepare a failure result (simulate API error)
        let mockService = MockAPIService()
        mockService.result = .failure(URLError(.badServerResponse))
        
        let useCase = LoginUseCase(apiService: mockService)
        let expectation = XCTestExpectation(description: "fetchUserToken returns error")
        
        useCase.fetchUserToken(email: "test@example.com", password: "password")
            .sink(receiveCompletion: { completion in
                if case .failure(_) = completion {
                    expectation.fulfill()
                } else {
                    XCTFail("Expected failure, but got success")
                }
            }, receiveValue: { _ in
                XCTFail("Expected failure, but got value")
            })
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testFetchUserSuccess() {
        // Prepare a valid user response (as an array).
        let user = UserResponse(id: 1,
                                avatar: "https://i.pravatar.cc/150?u=test",
                                username: "TestUser",
                                email: "test@example.com")
        guard let responseData = try? JSONEncoder().encode([user]) else {
            XCTFail("Failed to encode user array")
            return
        }
        
        let mockService = MockAPIService()
        mockService.result = .success(responseData)
        
        let useCase = LoginUseCase(apiService: mockService)
        let expectation = XCTestExpectation(description: "fetchUser returns true")
        
        useCase.fetchUser()
            .sink(receiveCompletion: { completion in
                if case let .failure(error) = completion {
                    XCTFail("Expected success, but got error: \(error)")
                }
            }, receiveValue: { success in
                XCTAssertTrue(success, "Expected fetchUser to return true")
                expectation.fulfill()
            })
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testFetchUserFailure() {
        // Prepare a failure result for fetchUser.
        let mockService = MockAPIService()
        mockService.result = .failure(URLError(.badServerResponse))
        
        let useCase = LoginUseCase(apiService: mockService)
        let expectation = XCTestExpectation(description: "fetchUser returns error")
        
        useCase.fetchUser()
            .sink(receiveCompletion: { completion in
                if case .failure(_) = completion {
                    expectation.fulfill()
                } else {
                    XCTFail("Expected failure, but got success")
                }
            }, receiveValue: { _ in
                XCTFail("Expected failure, but got value")
            })
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 1.0)
    }
}
