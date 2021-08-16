//
//  Operation.swift
//  ApodiniMigratorCore
//
//  Created by Eldi Cano on 07.08.21.
//  Copyright © 2021 TUM LS1. All rights reserved.
//

import Foundation

/// Defines the CRUD operation of a given endpoint
public enum Operation: String, CaseIterable, CustomStringConvertible, Value {
    /// The associated endpoint is used for a `create` operation
    case create
    /// The associated endpoint is used for a `read` operation
    case read
    /// The associated endpoint is used for a `update` operation
    case update
    /// The associated endpoint is used for a `delete` operation
    case delete

    /// A textual description of `self`
    public var description: String {
        rawValue
    }
}
