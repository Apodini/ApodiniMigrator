//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2021 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import Foundation

public protocol NameComponent: CustomStringConvertible {
    func description(with context: MigrationContext) -> String
}

public extension Array where Element == NameComponent {
    func description(with context: MigrationContext) -> String {
        self
            .map { component in
                component.description(with: context)
            }
            .joined()
    }
}

extension Array where Element == NameComponent {
    public var nameString: String {
        self.map { $0.description }.joined()
    }
}
