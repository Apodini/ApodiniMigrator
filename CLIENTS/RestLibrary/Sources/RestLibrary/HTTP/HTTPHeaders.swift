//
//  Created by ApodiniMigrator on 06.12.21
//  Copyright © 2021 TUM LS1. All rights reserved.
//

import Foundation

/// A `typealias` representing a `key`-`value` pair of a `HTTPHeader`
public typealias HTTPHeaders = [String: String]

/// `HTTPHeaders` extension
public extension HTTPHeaders {
    /// Updates `self` with a new `key`-`value` pair
    /// - Parameters:
    ///    - value: the value of the dictionary entry
    ///    - key: the key of the dictionary entry
    mutating func set(_ value: String, forKey key: String) {
        self[key] = value
    }
    
    /// Updates `Content-Type` field
    /// - Parameters:
    ///    - contentType: the value of the content type, e.g. `application/json`
    mutating func setContentType(to contentType: String) {
        self["Content-Type"] = contentType
    }
}

/// URLRequest extension for `HTTPHeaders` support
public extension URLRequest {
    /// Adds `headers` to `self`
    /// - Parameters:
    ///    - headers: `Headers` to be added to `self`
    mutating func set(_ headers: HTTPHeaders) {
        headers.forEach { addValue($0.value, forHTTPHeaderField: $0.key) }
    }
}
