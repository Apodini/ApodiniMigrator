//
//  Array+Value.swift
//  ApodiniMigratorCore
//
//  Created by Andreas Bauer on 23.08.21.
//  Copyright © 2021 TUM LS1. All rights reserved.
//

// MARK: - Array + Value
public extension Array where Element: Value {
    /// Appends rhs to lhs
    static func + (lhs: Self, rhs: Element) -> Self {
        var mutableLhs = lhs
        mutableLhs.append(rhs)
        return mutableLhs
    }

    /// Appends lhs to rhs
    static func + (lhs: Element, rhs: Self) -> Self {
        rhs + lhs
    }

    /// Appends contents of rhs to lhs
    static func + (lhs: Self, rhs: Self) -> Self {
        var mutableLhs = lhs
        mutableLhs.append(contentsOf: rhs)
        return mutableLhs.unique()
    }
}
