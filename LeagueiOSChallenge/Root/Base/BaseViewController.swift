//
//  BaseViewController.swift
//  MovieIMDB
//
//  Created by macbook pro on 2024-07-22.
//

import UIKit

typealias ViewController = BaseViewController
class BaseViewController: UIViewController {
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

