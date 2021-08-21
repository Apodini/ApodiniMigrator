//
//  Change.swift
//  ApodiniMigratorCompare
//
//  Created by Eldi Cano on 07.08.21.
//  Copyright © 2021 TUM LS1. All rights reserved.
//

import Foundation

/// A protocol that represents a change that can appear in the Migration Guide
public protocol Change: Codable {
    /// Top-level changed element related to the change
    var element: ChangeElement { get }
    /// Type of change
    var type: ChangeType { get }
    /// Indicates whether the change is non-backward compatible
    var breaking: Bool { get }
    /// Indicates whether the change can be handled by `ApodiniMigrator`
    var solvable: Bool { get }
}

// MARK: - Change default implementation
public extension Change {
    /// Element ID of `element`
    var elementID: DeltaIdentifier { element.deltaIdentifier }
}


// MARK: - Array
public extension Array where Element == Change {
    /// Returns all changes of a `DeltaIdentifiable` instance
    func of<D: DeltaIdentifiable>(_ deltaIdentifiable: D) -> [Change] {
        filter { $0.elementID == deltaIdentifiable.deltaIdentifier }
    }
}
