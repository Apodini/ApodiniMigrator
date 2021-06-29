//
//  ErrorCode.swift
//  ApodiniMigratorCore
//
//  Created by Eldi Cano on 29.06.21.
//  Copyright © 2021 TUM LS1. All rights reserved.
//

import Foundation

/// An error object representing `@Throws` of Apodini
public struct ErrorCode: Value {
    /// `statusCode` of the error
    public let code: Int
    /// A descriptive message associated with the error
    public let message: String
    
    /// Initializer of an `ErrorCode` instance
    public init(code: Int, message: String) {
        self.code = code
        self.message = message
    }
}

/// Array extension for `ApodiniError` support
public extension Array where Element == ErrorCode {
    /// Appends a new `ApodiniError` to `self`
    /// - Parameters:
    ///     - code: `statusCode` of the error
    ///     - message: descriptive message associated with the error
    mutating func addError(_ code: Int, message: String) {
        append(.init(code: code, message: message))
    }
}
