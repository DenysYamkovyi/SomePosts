//
//  PostsListUseCaseTests.swift
//  LeagueiOSChallenge
//
//  Created by macbook pro on 2025-02-21.
//

import XCTest
import Combine
@testable import LeagueiOSChallenge

// MARK: - Test Models

private struct PostResponse: Codable {
    let userId: Int
    let id: Int
    let title: String
    let body: String
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

// MARK: - PostsListUseCaseTests

final class PostsListUseCaseTests: XCTestCase {
    var cancellables = Set<AnyCancellable>()
    
    override func setUp() {
        super.setUp()
        // Save a dummy user in Keychain using the module's UserResponse.
        // Make sure your module's UserResponse conforms to Equatable.
        let dummyUser = UserResponse(
            id: 1,
            avatar: "https://i.pravatar.cc/150?u=test",
            username: "TestUser",
            email: "test@example.com"
        )
        _ = KeychainService.shared.saveUser(dummyUser)
    }
    
    override func tearDown() {
        _ = KeychainService.shared.deleteUser()
        cancellables.removeAll()
        super.tearDown()
    }
    
    func testFetchPostsSuccess() {
        // Prepare a valid PostResponse array.
        let postResponse = PostResponse(userId: 3, id: 26, title: "Test Title", body: "Test Body")
        let postsArray = [postResponse]
        guard let responseData = try? JSONEncoder().encode(postsArray) else {
            XCTFail("Failed to encode postsArray")
            return
        }
        
        // Create a mock APIService that returns the valid JSON.
        let mockAPIService = MockAPIService()
        mockAPIService.result = .success(responseData)
        
        let useCase = PostsListUseCase(apiService: mockAPIService)
        let expectation = XCTestExpectation(description: "fetchPosts returns a non-empty array of PostModel")
        
        useCase.fetchPosts(userId: "3")
            .sink(receiveCompletion: { completion in
                if case let .failure(error) = completion {
                    XCTFail("Expected success, but got error: \(error)")
                }
            }, receiveValue: { postModels in
                XCTAssertEqual(postModels.count, 1, "Expected one post")
                
                // Verify the mapping from PostResponse to PostModel.
                let postModel = postModels.first!
                XCTAssertEqual(postModel.title, "Test Title")
                XCTAssertEqual(postModel.description, "Test Body")
                
                // Check that the user from Keychain was used to set avatar and username.
                if let loadedUser = KeychainService.shared.loadUser() {
                    XCTAssertEqual(postModel.avatar, loadedUser.avatar, "Avatar should match")
                    XCTAssertEqual(postModel.username, loadedUser.username, "Username should match")
                } else {
                    XCTFail("No user found in Keychain")
                }
                
                expectation.fulfill()
            })
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 1.0)
    }
}
