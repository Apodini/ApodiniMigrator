//
//  ApodiniError.swift
//
//  Created by ApodiniMigrator on 21.05.2021
//  Copyright © 2021 TUM LS1. All rights reserved.
//

import Foundation

/// An error object representing `@Throws` of Apodini
struct ApodiniError: Error {
    /// `statusCode` of the error
    let code: Int
    /// A descriptive message associated with the error
    let message: String
}

/// Array extension for `ApodiniError` support
extension Array where Element == ApodiniError {
    /// Appends a new `ApodiniError` to `self`
    /// - Parameters:
    ///     - code: `statusCode` of the error
    ///     - message: descriptive message associated with the error
    mutating func addError(_ code: Int, message: String) {
        append(.init(code: code, message: message))
    }
}
