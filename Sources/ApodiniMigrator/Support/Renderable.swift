//
//  Renderable.swift
//  ApodiniMigrator
//
//  Created by Eldi Cano on 23.08.21.
//  Copyright © 2021 TUM LS1. All rights reserved.
//

import Foundation

/// A protocol for types that render a string content
protocol Renderable {
    /// A functions that returns the string content of a `Renderable` instance
    func render() -> String
}

// MARK: -
extension Renderable {
    /// Returns the formatted content of `render`
    func indentationFormatted() -> String {
        render().indentationFormatted()
    }
}
