//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2021 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import Foundation

class Box<Element> {
    var element: Element

    init(_ element: Element) {
        self.element = element
    }
}

@propertyWrapper
public struct SharedNodeStorage<Element> {
    private var storageBox: Box<Element?> = .init(nil)

    public init() {}

    public var wrappedValue: Element {
        guard let element = storageBox.element else {
            fatalError("Value is not present!")
        }
        return element
    }

    public var projectedValue: SharedNodeReference<Element> {
        SharedNodeReference(storageBox: storageBox)
    }
}

@propertyWrapper
public struct SharedNodeReference<Element> {
    fileprivate var storageBox: Box<Element?>

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
