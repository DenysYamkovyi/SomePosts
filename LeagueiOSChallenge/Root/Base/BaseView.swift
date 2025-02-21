//
//  BaseView.swift
//  LeagueiOSChallenge
//
//  Created by macbook pro on 2025-02-19.
//

import UIKit

public typealias View = BaseView
open class BaseView: UIView {
    override public init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
