# SomePosts
League iOS Challenge

Overview

This project is built as part of the League iOS Challenge. It demonstrates modern iOS development practices using the MVVM + Coordinators (MVVM+C) architecture and Combine for reactive programming. The primary goal is to showcase a robust login flow with token management, API integration, and a modular navigation system using coordinators.

Architecture

MVVM + Coordinators (MVVM+C)

    - MVVM:
    - Models: Represent API responses (e.g., UserResponse, PostResponse).
    - ViewModels: Handle business logic and state management (e.g., LoginViewModel, PostsListViewModel).
    - Views/View Controllers: Bind UI components to view models.
    - Coordinators:
    - Manage navigation flows (e.g., AppCoordinator, LoginCoordinator, PostsListCoordinator).
    - Decouple navigation logic from view controllers, making the app more modular and testable.

Pros

    - Clear separation of concerns
    - Improved testability
    - Scalable and modular navigation

Cons

    - Increased boilerplate code
    - Potential for added complexity in smaller projects

Key Features

Login Screen

    - Biometric Authentication: Integration for fingerprint/face recognition.
    - Login Button Availability: Enabled based on valid input for email and password
    Token Management:
    - Saving the token in the Keychain/ for more security invetigate using the Secure Enclave for cryptographic operations
    - Refreshing tokens when needed

Posts screen
    - Cell Resizing: Ensure dynamic cells resize correctly.

Coordinator Pattern

    - Checks login status and navigates appropriately.
    - Modular navigation flows (e.g., transitioning from the login screen to the posts list)

Handling Errors

Internet status checking

Localization & Accessibility

    - Use of localized strings and constants.
    - Planned adaptations for accessibility, including a black and white theme.

Testing

    - Snapshots: Validate UI components using snapshot tests.

    - Localization: Test for proper string localization.
    - Mock Models: Utilize mock models for view models and API services.
    - Frameworks: Future improvements might include using SwiftSnapshot, SwiftNimble, and SwiftQuick for more expressive tests.



Future Improvements

    Documentation:
    - Expand project documentation with detailed API and architectural explanations.
    - Prepare a comprehensive developer guide.
    
    Pagination & Error Handling:
    - Implement pagination for lists.
    - Enhance error handling across the application.
    
    UI Enhancements:
    - Build out additional UI components.
    - Include placeholder images and consistent loading states.
    
    Testing Enhancements:
    - Increase test coverage with mocks and snapshot testing.
    - Consider using SwiftSnapshot, SwiftNimble, and SwiftQuick for more expressive, behavior-driven tests.
    
    Protocol Abstraction:
    - Define protocols for every view model and view controller to ensure a high level of abstraction and testability.
    
    Localization Framework:
    - Integrate a dedicated framework for handling localization.
    
    Accessibility:
    - Improve accessibility adaptations.
    - Consider a black and white theme for better accessibility support.

