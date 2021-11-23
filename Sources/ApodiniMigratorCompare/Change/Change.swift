//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2021 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import Foundation

/// A protocol that represents a change that can appear in the Migration Guide
public protocol Change: Codable {
    /// Top-level changed element related to the change
    var element: ChangeElement { get }
    /// Type of change
    var type: ChangeType { get }
    /// Indicates whether the change is non-backward compatible
    var breaking: Bool { get } // TODO if it is breaking depends on interface (e.g. necessity for grpc?)
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
