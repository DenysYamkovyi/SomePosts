//
//  TextField.swift
//  LeagueiOSChallenge
//
//  Created by macbook pro on 2025-02-20.
//

import UIKit
import Combine

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

class TextFieldView: UIView {
    private let titleLabel = UILabel()
    private let textField = UITextField()

    private let warningImageView: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "exclamationmark.circle"))
        iv.tintColor = .systemRed
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.isHidden = true
        return iv
    }()
    
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
        addSubview(warningImageView)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        textField.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            // Title label at top
            titleLabel.topAnchor.constraint(equalTo: topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            // Text field below title label
            textField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            textField.leadingAnchor.constraint(equalTo: leadingAnchor),
            // Leave some space for the warning icon on the right
            textField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -30),
            textField.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            // Warning icon anchored to the trailing side of the text field
            warningImageView.centerYAnchor.constraint(equalTo: textField.centerYAnchor),
            warningImageView.leadingAnchor.constraint(equalTo: textField.trailingAnchor, constant: 4),
            warningImageView.widthAnchor.constraint(equalToConstant: 20),
            warningImageView.heightAnchor.constraint(equalToConstant: 20)
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
        if let viewModel = currentViewModel, viewModel.title.lowercased() == "email" {
            let isValid = validateEmail(textField.text ?? "")
            warningImageView.isHidden = isValid
        }
    }
    
    private func validateEmail(_ email: String) -> Bool {
        guard let domainPart = email.split(separator: "@").last else {
            return false
        }
        let domain = domainPart.lowercased()
        return domain.hasSuffix(".com") || domain.hasSuffix(".net") || domain.hasSuffix(".biz")
    }
}

// Conform to Configurable using our TextFieldViewModel
extension TextFieldView: Configurable {
    func configure(with viewModel: TextFieldViewModel) {
        currentViewModel = viewModel
        titleLabel.text = viewModel.title
        textField.placeholder = viewModel.placeholder
        
        if viewModel.title.lowercased() == "email" {
            warningImageView.isHidden = true
        }
    }
}
