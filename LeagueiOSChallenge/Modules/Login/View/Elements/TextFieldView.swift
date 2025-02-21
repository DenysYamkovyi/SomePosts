//
//  TextField.swift
//  LeagueiOSChallenge
//
//  Created by macbook pro on 2025-02-20.
//

import UIKit
import Combine

// MARK: - TextFieldViewModel Protocol
protocol TextFieldViewModel {
    var title: String { get }
    var placeholder: String { get }
    var validator: String { get }
    
    var onEditAction: PassthroughSubject<Void, Never> { get }
}

struct DefaultTextFieldViewModel: TextFieldViewModel {
    var title: String
    var placeholder: String
    var validator: String
    var onEditAction = PassthroughSubject<Void, Never>()
}

// MARK: - TextFieldView
class TextFieldView: UIView {
    private let titleLabel = UILabel()
    private let textField = UITextField()
    
    var text: String {
        return textField.text ?? ""
    }
        
    // Keep a reference to the view model to trigger actions
    private var currentViewModel: TextFieldViewModel?
    
    private var cancellables = Set<AnyCancellable>()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    required init?(coder: NSCoder) { fatalError("Not implemented") }
    
    private func setupView() {
        addSubview(titleLabel)
        addSubview(textField)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        textField.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            textField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            textField.leadingAnchor.constraint(equalTo: leadingAnchor),
            textField.trailingAnchor.constraint(equalTo: trailingAnchor),
            textField.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        textField.keyboardType = .emailAddress
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        textField.layer.borderWidth = 1.0
        textField.layer.borderColor = UIColor.lightGray.cgColor
        textField.layer.cornerRadius = 5.0
        
        textField.addTarget(self, action: #selector(editingChanged), for: .editingChanged)
    }
    
    @objc private func editingChanged() {
        currentViewModel?.onEditAction.send(())
    }
}

// Conform to Configurable using our TextFieldViewModel
extension TextFieldView: Configurable {
    func configure(with viewModel: TextFieldViewModel) {
        currentViewModel = viewModel
        titleLabel.text = viewModel.title
        textField.placeholder = viewModel.placeholder
    }
}
