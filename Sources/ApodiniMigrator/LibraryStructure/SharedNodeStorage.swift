//
// Created by Andreas Bauer on 23.11.21.
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
