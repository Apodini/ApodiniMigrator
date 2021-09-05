//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2021 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import Foundation

public extension Set {
    /// Returns an array version of self
    var asArray: [Element] {
        Array(self)
    }

    /// Inserts rhs into lhs
    static func += (lhs: inout Self, rhs: Element) {
        lhs.insert(rhs)
    }

    /// Forms an union with another sequence
    static func += <S: Sequence> (lhs: inout Self, rhs: S) where S.Element == Element {
        lhs.formUnion(rhs)
    }
}
