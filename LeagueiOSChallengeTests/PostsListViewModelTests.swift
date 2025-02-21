//
//  Untitled.swift
//  LeagueiOSChallenge
//
//  Created by macbook pro on 2025-02-21.
//

import XCTest
import Combine
@testable import LeagueiOSChallenge

// MARK: - Mock PostsListViewModelUseCase

private final class MockPostsListViewModelUseCase: PostsListViewModelUseCase {
    var result: Result<[PostModel], Error>!
    
    func fetchPosts(userId: String) -> AnyPublisher<[PostModel], Error> {
        return result.publisher.eraseToAnyPublisher()
    }
}

// MARK: - PostsListViewModelTests

final class PostsListViewModelTests: XCTestCase {
    var cancellables = Set<AnyCancellable>()
    fileprivate var mockUseCase: MockPostsListViewModelUseCase!
    var viewModel: PostsListViewModel!
    
    override func setUp() {
        super.setUp()
        // Set up a dummy user in Keychain for mapping.
        let dummyUser = UserResponse(
            id: 1,
            avatar: "https://i.pravatar.cc/150?u=test",
            username: "TestUser",
            email: "test@example.com"
        )
        _ = KeychainService.shared.saveUser(dummyUser)
        
        mockUseCase = MockPostsListViewModelUseCase()
        viewModel = PostsListViewModel(postsListUseCase: mockUseCase)
    }
    
    override func tearDown() {
        _ = KeychainService.shared.deleteUser()
        cancellables.removeAll()
        mockUseCase = nil
        viewModel = nil
        super.tearDown()
    }
    
    func testGetPostsSuccess() {
        // Create a dummy PostModel using the dummy user from keychain.
        guard let dummyUser = KeychainService.shared.loadUser() else {
            XCTFail("Dummy user not found in Keychain")
            return
        }
        // Create a dummy post.
        let dummyPost = PostModel(title: "Test Title", body: "Test Body", user: dummyUser)
        mockUseCase.result = .success([dummyPost])
        
        let expectation = XCTestExpectation(description: "getPosts updates posts array")
        
        viewModel.getPosts(userId: "1")
        
        // Wait for the posts to be updated.
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            XCTAssertEqual(self.viewModel.posts.count, 1, "Expected one post")
            let postModel = self.viewModel.posts.first!
            XCTAssertEqual(postModel.title, "Test Title")
            XCTAssertEqual(postModel.description, "Test Body")
            // Compare mapped values from the dummy user.
            XCTAssertEqual(postModel.avatar, dummyUser.avatar, "Avatar should match")
            XCTAssertEqual(postModel.username, dummyUser.username, "Username should match")
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testGetPostsFailure() {
        let error = URLError(.badServerResponse)
        mockUseCase.result = .failure(error)
        
        let expectation = XCTestExpectation(description: "getPosts propagates error")
        
        viewModel.error
            .sink { receivedError in
                XCTAssertEqual(receivedError.localizedDescription, error.localizedDescription)
                XCTAssertTrue(self.viewModel.showError, "showError should be true on failure")
                XCTAssertNotNil(self.viewModel.errorMessage, "errorMessage should be set on failure")
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        viewModel.getPosts(userId: "1")
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testUserDidSelectEmitsShowUserInfo() {
        let expectation = XCTestExpectation(description: "showUserInfo event is emitted")
        
        viewModel.showUserInfo
            .sink {
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        viewModel.userDidSelect()
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testNavigateBackToLoginClearsKeychainAndEmitsNavigateBack() {
        // First, save some dummy values to Keychain.
        let dummyUser = UserResponse(
            id: 1,
            avatar: "https://i.pravatar.cc/150?u=test",
            username: "TestUser",
            email: "test@example.com"
        )
        _ = KeychainService.shared.saveUser(dummyUser)
        _ = KeychainService.shared.saveToken("SOME_TOKEN")
        _ = KeychainService.shared.saveGuestLogin(true)
        
        let expectation = XCTestExpectation(description: "navigateBack event is emitted and Keychain is cleared")
        
        viewModel.navigateBack
            .sink {
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        viewModel.navigateBackToLogin()
        
        wait(for: [expectation], timeout: 1.0)
        
        XCTAssertNil(KeychainService.shared.loadUser(), "User should be nil after deletion")
        XCTAssertNil(KeychainService.shared.loadToken(), "Token should be nil after deletion")
        XCTAssertNil(KeychainService.shared.loadGuestLogin(), "Guest login flag should be nil after deletion")
    }
}
