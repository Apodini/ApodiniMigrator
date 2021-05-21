//
//  HTTPAuthorization.swift
//
//  Created by ApodiniMigrator on 21.05.2021
//  Copyright © 2021 TUM LS1. All rights reserved.
//

import Foundation

/// The `HTTPAuthorization` request header
public struct HTTPAuthorization {
    /// Location of the authorization
    public enum Location {
        case header
        case query
        case cookie
    }
    
    /// Initializer for `HTTPAuthorization`
    public init(location: Location, value: String) {
        self.location = location
        self.key = "Authorization"
        self.value = value
    }
    
    /// Location of the authorization
    var location: Location
    /// The key of the authorization header
    /// - Note: always `Authorization`
    let key: String
    /// The value of the `Authorization`, e.g. `Basic SGVsbG8gQXBvZGluaU1pZ3JhdG9yIERldmVsb3BlciE=`
    var value: String
    
    /// String representation of the `HTTPAuthorization` as a query
    var query: String {
        key + "=" + value
    }
    
    /// Updates `headers` with own `key`-`value` pair
    func inject(into headers: inout HTTPHeaders) {
        headers[key] = value
    }
}

/// HTTPAuthorization convenience
extension HTTPAuthorization {
    /// A basic `HTTPAuthorization`
    /// - Parameters:
    ///     - username: username
    ///     - password: password
    /// - Note: encodes `username` and `password` in Base-64 encoded string (a basic `HTTPAuthorization` conforming way)
    /// - Returns: a basic `HTTPAuthorization`, with location always `.header`
    static func basic(_ username: String, _ password: String) -> HTTPAuthorization {
        let string = [username, password].joined(separator: ":")
        let base64EncodedString = string.data(using: .utf8)?.base64EncodedString() ?? ""
        return .init(location: .header, value: "Basic \(base64EncodedString)")
    }
}
