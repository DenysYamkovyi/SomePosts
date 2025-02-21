//
//  Button.swift
//  LeagueiOSChallenge
//
//  Created by macbook pro on 2025-02-20.
//

import UIKit
import Combine

protocol ButtonViewModel {
    var title: String { get }
    
    var onButtonAction: PassthroughSubject<Void, Never> { get }
}

struct DefaultButtonViewModel: ButtonViewModel {
    var title: String
    var onButtonAction = PassthroughSubject<Void, Never>()
}

// MARK: - ButtonView
class ButtonView: UIView {
    private let button = UIButton(type: .system)
    
    private var currentViewModel: ButtonViewModel?
    private var cancellables = Set<AnyCancellable>()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    required init?(coder: NSCoder) { fatalError("Not implemented") }
    
    private func setupView() {
        addSubview(button)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            button.topAnchor.constraint(equalTo: topAnchor),
            button.leadingAnchor.constraint(equalTo: leadingAnchor),
            button.trailingAnchor.constraint(equalTo: trailingAnchor),
            button.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        button.backgroundColor = .lightGray
        button.setTitleColor(.black, for: .normal)
        button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
    }
    
    @objc private func buttonTapped() {
        currentViewModel?.onButtonAction.send(())
    }
}

// Conform to Configurable using our ButtonViewModel
extension ButtonView: Configurable {
    func configure(with viewModel: ButtonViewModel) {
        currentViewModel = viewModel
        button.setTitle(viewModel.title, for: .normal)
    }
}
