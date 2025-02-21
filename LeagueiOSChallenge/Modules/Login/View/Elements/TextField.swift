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
    
    var onButtonAction: PassthroughSubject<Void, Never> { get }
}

class TextFieldView: View {
    
}
