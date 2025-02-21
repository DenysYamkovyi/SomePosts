//
//  LoginViewModelTests.swift
//  LeagueiOSChallenge
//
//  Created by macbook pro on 2025-02-21.
//

import XCTest
import Combine
@testable import LeagueiOSChallenge

// MARK: - Mock LoginViewModelUseCase

private final class MockLoginViewModelUseCase: LoginViewModelUseCase {
    var fetchUserTokenResult: Result<Bool, Error> = .success(true)
    var fetchUserResult: Result<Bool, Error> = .success(true)
    
    func fetchUserToken(email: String, password: String) -> AnyPublisher<Bool, Error> {
        return fetchUserTokenResult.publisher.eraseToAnyPublisher()
    }
    
    func fetchUser() -> AnyPublisher<Bool, Error> {
        return fetchUserResult.publisher.eraseToAnyPublisher()
    }
}

// MARK: - LoginViewModelTests

final class LoginViewModelTests: XCTestCase {
    var cancellables = Set<AnyCancellable>()
    
    override func tearDown() {
        cancellables.removeAll()
        super.tearDown()
    }
    
    /// Test that a valid email and password results in a successful login.
    func testLoginSuccess() {
        let mockUseCase = MockLoginViewModelUseCase()
        // Ensure valid email passes the view model's validation.
        let viewModel = LoginViewModel(loginViewModelUseCase: mockUseCase)
        viewModel.email = "test@example.com"
        viewModel.password = "password"
        
        let expectation = XCTestExpectation(description: "showPosts is emitted on successful login")
        
        viewModel.showPosts
            .sink { expectation.fulfill() }
            .store(in: &cancellables)
        
        viewModel.login()
        
        wait(for: [expectation], timeout: 1.0)
        XCTAssertFalse(viewModel.isLoading, "Loading should be false after login completes")
        XCTAssertFalse(viewModel.showError, "There should be no error on successful login")
    }
    
    /// Test that guest login sets the isGuestLogin flag and emits showPosts.
    func testGuestLoginSuccess() {
        let mockUseCase = MockLoginViewModelUseCase()
        let viewModel = LoginViewModel(loginViewModelUseCase: mockUseCase)
        
        let expectation = XCTestExpectation(description: "showPosts is emitted on successful guest login")
        
        viewModel.showPosts
            .sink { expectation.fulfill() }
            .store(in: &cancellables)
        
        viewModel.guestLogin()
        
        wait(for: [expectation], timeout: 1.0)
        XCTAssertTrue(viewModel.isGuestLogin, "isGuestLogin should be true for guest login")
        XCTAssertFalse(viewModel.isLoading, "Loading should be false after guest login")
        XCTAssertFalse(viewModel.showError, "There should be no error on successful guest login")
    }
    
    /// Test that providing an invalid email prevents login (i.e. showPosts is not emitted).
    func testInvalidEmailPreventsLogin() {
        let mockUseCase = MockLoginViewModelUseCase()
        let viewModel = LoginViewModel(loginViewModelUseCase: mockUseCase)
        // Provide an email that fails validation.
        viewModel.email = "invalid_email"
        viewModel.password = "password"
        
        let expectation = XCTestExpectation(description: "showPosts is not emitted on invalid email")
        expectation.isInverted = true
        
        viewModel.showPosts
            .sink { expectation.fulfill() }
            .store(in: &cancellables)
        
        viewModel.login()
        wait(for: [expectation], timeout: 1.0)
        XCTAssertFalse(viewModel.isLoading, "Login should not start if email is invalid")
    }
    
    /// Test error propagation when fetchUserToken fails.
    func testFetchUserTokenFailure() {
        let mockUseCase = MockLoginViewModelUseCase()
        // Force fetchUserToken to fail.
        mockUseCase.fetchUserTokenResult = .failure(URLError(.badServerResponse))
        let viewModel = LoginViewModel(loginViewModelUseCase: mockUseCase)
        viewModel.email = "test@example.com"
        viewModel.password = "password"
        
        let expectation = XCTestExpectation(description: "Error is emitted on token fetch failure")
        
        viewModel.error
            .sink { _ in expectation.fulfill() }
            .store(in: &cancellables)
        
        viewModel.login()
        
        wait(for: [expectation], timeout: 1.0)
        XCTAssertFalse(viewModel.isLoading, "isLoading should be false after failure")
        XCTAssertTrue(viewModel.showError, "showError should be true on failure")
    }
}
