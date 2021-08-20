//
//  Set+Extensions.swift
//  ApodiniMigratorShared
//
//  Created by Eldi Cano on 07.08.21.
//  Copyright © 2021 TUM LS1. All rights reserved.
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
