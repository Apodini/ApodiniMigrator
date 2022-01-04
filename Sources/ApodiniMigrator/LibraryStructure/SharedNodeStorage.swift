//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2022 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import Foundation

/// Box type to handle any data type as a reference.
class Box<Element> {
    var element: Element

    init(_ element: Element) {
        self.element = element
    }
}

/// A `SharedNodeStorage` can be used to store arbitrary data structures across multiple ``LibraryNode``s.
///
/// For example file generator `A` might produce output which is used as input for the file generator `B`.
/// To do this you would declare a ``SharedNodeStorage`` in the ``Migrator`` and declare
/// ``SharedNodeReference``s in the file generators. Those references are set by passing the
/// ``SharedNodeStorage/projectedValue`` to both file generators.
@propertyWrapper
public struct SharedNodeStorage<Element> {
    private var storageBox: Box<Element?> = .init(nil)

    /// Initializes a new `SharedNodeStorage` which a optional initial value.
    /// - Parameter value: The initial ``Element`` value which is optionally supplied.
    public init(_ value: Element? = nil) {
        self.storageBox.element = nil
    }

    /// Initializes a new `SharedNodeStorage` with the `wrappedValue`.
    /// - Parameter wrappedValue: The wrappedValue, supplied by the property syntax.
    public init(_ wrappedValue: Element) {
        self.storageBox.element = wrappedValue
    }

    /// The `wrappedValue`.
    /// - Note: Access to the wrappedValue with result in a `fatalError` if it wasn't previously set.
    public var wrappedValue: Element {
        guard let element = storageBox.element else {
            fatalError("Value is not present!")
        }
        return element
    }

    /// Create a ``SharedNodeReference`` from this storage object.
    public var projectedValue: SharedNodeReference<Element> {
        SharedNodeReference(storageBox: storageBox)
    }
}

/// A reference to a ``SharedNodeStorage``.
@propertyWrapper
public struct SharedNodeReference<Element> {
    fileprivate var storageBox: Box<Element?>

    /// Access to getters and setters of the referenced element.
    public var wrappedValue: Element {
        get {
            guard let element = storageBox.element else {
                fatalError("Value is not present!")
            }
            return element
        }
        set {
            storageBox.element = newValue
        }
    }
}

extension SharedNodeReference {
    /// This initializer is mainly used for testing purpose, to directly initialize a reference with a value.
    init(with value: Element) {
        self.storageBox = Box(value)
    }
}
