//
//  Configurable.swift
//  LeagueiOSChallenge
//
//  Created by macbook pro on 2025-02-20.
//

protocol Configurable {
    associatedtype ConfigurationItem
    func configure(with item: ConfigurationItem)
}
