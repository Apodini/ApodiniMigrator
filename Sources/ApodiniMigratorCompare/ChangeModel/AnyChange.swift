//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2021 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import Foundation

/// Represents any change. Protocol for ``Change``.
public protocol AnyChange {
    /// The type of element this change is about.
    associatedtype Element: ChangeableElement

    /// The ``DeltaIdentifier`` of the instance of the changed element.
    var id: DeltaIdentifier { get }
    /// The ``ChangeType``. This maps to cases in the ``Change`` type.
    var type: ChangeType { get }

    /// Breaking classification of the change.
    var breaking: Bool { get }
    /// Solvable (by the Migrator) classification of the change.
    /// This classification might be inaccurate, as the classification is heavily dependent on the api type.
    var solvable: Bool { get }
}

fileprivate extension AnyChange {
    func typed() -> Change<Element> {
        guard let change = self as? Change<Element> else {
            fatalError("Encountered `AnyChange` which isn't of expected type `ChangeEnum`!")
        }
        return change
    }
}

public extension Array where Element: AnyChange {
    /// Retrieves all changes from an array of ``Change``es for a given instance.
    /// - Parameter element: The instance to filter for changes.
    func of(base element: Element.Element) -> [Element] {
        self.filter { $0.id == element.deltaIdentifier }
    }
}
