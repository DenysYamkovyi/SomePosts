//
//  PostsListViewController.swift
//  LeagueiOSChallenge
//
//  Created by macbook pro on 2025-02-20.
//

import Combine
import UIKit

protocol PostsListViewControllerViewModel: ObservableObject {
    associatedtype Post: PostTableViewCellViewModel, Hashable
    var posts: [Post] { get }
    var isLoading: Bool { get }
    
    var error: PassthroughSubject<Error, Never> { get }
    
    func getPosts(userId: String)
    func userDidSelect()
    func navigateBackToLogin()
}

final class PostsListViewController<ViewModel>: ViewController, UITableViewDelegate where ViewModel: PostsListViewControllerViewModel  {
    
    private typealias DataSource = UITableViewDiffableDataSource<Section, Row>
    
    private enum Section: Hashable {
        case posts
    }
    
    private enum Row: Hashable {
        case post(ViewModel.Post)
    }
    
    private let viewModel: ViewModel
    private let tableView: UITableView = .init()
    private var activityIndicatorView: UIActivityIndicatorView?
    
    private var dataSource: DataSource?
    private var cancellables: Set<AnyCancellable> = []
    
    init(viewModel: ViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("We don't use storyboards")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.hidesBackButton = true
        setupNavigationBarButton()
        setupDataSource()
        setupSubviews()
        bindToViewModel()
        updateView()
        
        if let userId = KeychainService.shared.loadUser()?.id {
            viewModel.getPosts(userId: "\(userId)")
        }
    }
    
    private func setupNavigationBarButton() {
        let isGuest = KeychainService.shared.loadGuestLogin() ?? false
        let buttonTitle = isGuest ? "Exit" : "Logout"
        let rightBarButton = UIBarButtonItem(title: buttonTitle, style: .plain, target: self, action: #selector(navigationButtonTapped))
        navigationItem.rightBarButtonItem = rightBarButton
    }
    
    @objc private func navigationButtonTapped() {
        let isGuest = KeychainService.shared.loadGuestLogin() ?? false
        
        if isGuest {
            let alert = UIAlertController(title: nil, message: "Thank you for trialing this app", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak self] _ in
                self?.viewModel.navigateBackToLogin()
            }))
            present(alert, animated: true, completion: nil)
        } else {
            viewModel.navigateBackToLogin()
        }
    }
    
    private func setupSubviews() {
        view.addSubview(tableView)
        tableView.bindFrameToSuperviewBounds()
        tableView.delegate = self
    }
    
    private func bindToViewModel() {
        viewModel
            .objectDidChange(on: DispatchQueue.main)
            .sink { [weak self] _ in self?.updateView() }
            .store(in: &cancellables)
        
        viewModel
            .error
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in self?.handleError($0) }
            .store(in: &cancellables)
    }
    
    private func updateView() {
        updateActivityIndicator()
        updateDataSource()
    }
    
    private func updateActivityIndicator() {
        if viewModel.isLoading, activityIndicatorView == nil {
            let activity = UIActivityIndicatorView(style: .large)
            activity.translatesAutoresizingMaskIntoConstraints = false
            activity.startAnimating()
            view.addSubview(activity)
            activity.bindToCenter()
            activityIndicatorView = activity
        } else if activityIndicatorView != nil {
            activityIndicatorView?.stopAnimating()
            activityIndicatorView?.removeFromSuperview()
            activityIndicatorView = nil
        }
    }
    
    private func handleError(_ error: Error) {
        let alertViewController = UIAlertController(
            title: error.localizedDescription,
            message: nil,
            preferredStyle: .alert
        )
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertViewController.addAction(okAction)
        present(alertViewController, animated: true)
    }
    
    // MARK: - Delegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let row = dataSource?.itemIdentifier(for: indexPath) {
            switch row {
            case let .post(item):
                viewModel.userDidSelect()
            }
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // MARK: - Layout
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if let row = dataSource?.itemIdentifier(for: indexPath) {
            switch row {
            case .post(_):
                return 100
            }
        }
        return UITableView.automaticDimension
    }
}

// MARK: - Data Source
private extension PostsListViewController {
    func setupDataSource() {
        tableView.register(PostTableViewCellView.self, forCellReuseIdentifier: PostTableViewCellView.reuseIdentifier)
        let dataSource = UITableViewDiffableDataSource<Section, Row>(tableView: tableView) { tableView, indexPath, row in
            switch row {
            case let .post(item):
                guard let cell = tableView.dequeueReusableCell(withIdentifier: PostTableViewCellView.reuseIdentifier) as? PostTableViewCellView else { fatalError("Unexpected cell type") }
                cell.configure(with: item)
                return cell
            }
        }
        self.dataSource = dataSource
    }
    
    func updateDataSource() {
        guard var snapshot = dataSource?.snapshot() else { return }
        defer { dataSource?.apply(snapshot, animatingDifferences: true) }
        snapshot.deleteAllItems()
        guard !viewModel.isLoading else { return }
        snapshot.appendSections([.posts])
        snapshot.appendItems(viewModel.posts.map(Row.post))
    }
}
