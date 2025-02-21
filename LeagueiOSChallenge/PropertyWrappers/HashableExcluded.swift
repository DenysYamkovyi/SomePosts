//
//  HashableExcluded.swift
//  LeagueiOSChallenge
//
//  Created by macbook pro on 2025-02-20.
//

import Foundation

/// A property wrapper to exclude a property from the synthesized `Hashable` and `Equatable` conformance
/// on the owning type.
@propertyWrapper
public struct HashableExcluded<Value> {
    public var wrappedValue: Value
    
    public init(wrappedValue: Value) {
        self.wrappedValue = wrappedValue
    }
}

extension HashableExcluded: Hashable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        true
    }

    public func hash(into hasher: inout Hasher) {
        // do nothing
    }
}
