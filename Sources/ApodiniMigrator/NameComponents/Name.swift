//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2021 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import Foundation

public struct Name: NameComponent {
    var components: [NameComponent]

    var isEmpty: Bool {
        components.isEmpty
    }

    public init(empty: Void) {
        self.components = []
    }

    public func description(with context: MigrationContext) -> String {
        components
            .map { $0.description(with: context ) }
            .joined()
    }

    public var description: String {
        components
            .map { $0.description }
            .joined()
    }
}

extension Name: ExpressibleByStringLiteral {
    public init(stringLiteral value: String) {
        precondition(!value.contains("___"), "Placeholder replacements cannot be constructed via string literals!")
        self.components = [value]
    }
}

extension Name: ExpressibleByStringInterpolation {
    public init(stringInterpolation: NameStringInterpolation) {
        self.components = stringInterpolation.components
    }
}
