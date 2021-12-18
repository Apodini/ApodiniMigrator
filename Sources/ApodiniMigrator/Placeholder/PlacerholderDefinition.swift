//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2021 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
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
