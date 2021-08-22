//
//  Indentation.swift
//  ApodiniMigrator
//
//  Created by Eldi Cano on 23.08.21.
//  Copyright © 2021 TUM LS1. All rights reserved.
//

import Foundation

/// An object representing a spacer / indentation in a swift file
struct Indentation: CustomStringConvertible {
    /// A space string with length of 4
    static let tab = String(repeating: " ", count: 4)
    /// A placeholder to add indentation to lines that start with a `.`, since the current logic of `IndentationFormatter` can't handle those cases
    static let placeholder = "____INDENTATION____"
    /// A placeholder to indicate to `IndentationFormatter` to ignore one level of indentation for the lines that start with `Indentation.skip`
    static let skip = "____SKIP____"

    /// The level of the indentation
    private var level: UInt
    
    /// Complete space of this indentation, repeating `Indentation.tab` `level`-times
    var description: String {
        String(repeating: Self.tab, count: Int(level))
    }
    
    // MARK: - Initializer
    init(_ level: UInt) {
        self.level = level
    }
    
    
    /// Decreases level by one
    mutating func dropLevel() {
        level = level > 0 ? level - 1 : 0
    }
    
    /// Adds indentation to `rhs`
    static func + (lhs: Self, rhs: String) -> String {
        lhs.description + rhs
    }
}
