//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2021 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
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
