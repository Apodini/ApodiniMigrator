//
//  File.swift
//  
//
//  Created by Eldi Cano on 23.05.21.
//

import Foundation

/// A protocol that represents a change that can appear in the Migration Guide
public protocol Change: Codable {
    /// Top-level changed element related to the change
    var element: ChangeElement { get }
    /// Type of change
    var type: ChangeType { get }
    /// The id of the top-level changed element. Property not required, default implementation provided
    var elementID: DeltaIdentifier { get }
    /// An optional property to indicate the id of the targeted element. By default `nil`, concrete `Change` instances initialize it if required
    var targetID: DeltaIdentifier? { get }
    /// Indicates whether the change is non-backward compatible
    var breaking: Bool { get }
    /// Indicates whether the change can be handled by `ApodiniMigrator`
    var solvable: Bool { get }
}

// MARK: - Change default implementation
public extension Change {
    /// Element ID of `element`
    var elementID: DeltaIdentifier { element.deltaIdentifier }
    /// Target ID, by default `nil`
    var targetID: DeltaIdentifier? { nil }
    
    /// Returns the typed version of `self` to a concrete `Change` implementation
    /// - Note: results in `fatalError` if casting fails
    func typed<C: Change>(_ type: C.Type) -> C {
        guard let self = self as? C else {
            fatalError("Failed to cast change to \(C.self)")
        }
        return self
    }
}


// MARK: - Array
extension Array where Element == Change {
    /// Returns all changes of a `DeltaIdentifiable` instance
    func of<D: DeltaIdentifiable>(_ deltaIdentifiable: D) -> [Change] {
        filter { $0.elementID == deltaIdentifiable.deltaIdentifier }
    }
    
    /// Returns all parameter changes of the specified `endpoint`
    func parameterChanges(of endpoint: Endpoint) -> [ParameterChange] {
        (of(endpoint).filter { $0 is ParameterChange } as? [ParameterChange]) ?? []
    }
}
