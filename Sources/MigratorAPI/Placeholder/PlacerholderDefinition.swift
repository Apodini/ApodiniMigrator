//
// Created by Andreas Bauer on 15.11.21.
//

import Foundation

@propertyWrapper
public struct PlaceholderDefinition {
    public var wrappedValue: Placeholder

    public var projectedValue: Placeholder {
        wrappedValue
    }

    public init(wrappedValue: Placeholder) {
        self.wrappedValue = wrappedValue
    }
}
