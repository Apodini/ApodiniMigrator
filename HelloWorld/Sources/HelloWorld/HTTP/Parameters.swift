//
//  Parameters.swift
//
//  Created by ApodiniMigrator on 25.05.2021
//  Copyright © 2021 TUM LS1. All rights reserved.
//

import Foundation

/// A `typealias` for a `Dictionary` with `String` keys and `LosslessStringConvertible` values.
/// Represents `query` of a `URL`
public typealias Parameters = [String: LosslessStringConvertible]

/// `Parameters` extension
public extension Parameters {
    /// Updates `self` with a new `key`-`value` pair iff `value` is not `nil`
    /// - Parameters:
    ///    - value: the value of the dictionary entry
    ///    - key: the key of the dictionary entry
    mutating func set(_ value: LosslessStringConvertible?, forKey key: String) {
        if let value = value {
            self[key] = value
        }
    }
    
    /// String representation of `Parameters` for URLs that conform to RFC 1808
    func string() -> String {
        var string = map { "\($0.key)=\($0.value.description)" }.joined(separator: "&")
        if !isEmpty {
            string = "?\(string)"
        }
        return string
    }
}

/// `UUID` Conformance to `LosslessStringConvertible`
extension UUID: LosslessStringConvertible {
    public init?(_ description: String) {
        if let uuid = UUID(uuidString: description) {
            self = uuid
        } else {
            return nil
        }
    }
}
