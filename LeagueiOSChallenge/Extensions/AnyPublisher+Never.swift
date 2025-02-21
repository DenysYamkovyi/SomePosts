//
//  AnyPublisher+Never.swift
//  LeagueiOSChallenge
//
//  Created by macbook pro on 2025-02-19.
//

import Combine

extension AnyPublisher {
    static func never() -> Self {
        Empty(completeImmediately: false).eraseToAnyPublisher()
    }
}
