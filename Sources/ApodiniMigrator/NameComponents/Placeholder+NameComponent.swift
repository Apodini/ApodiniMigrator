//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2022 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import Foundation

extension Placeholder: NameComponent {
    public func description(with context: MigrationContext) -> String {
        guard let value = context.placeholderValues[self] else {
            fatalError("Could not find value for placeholder \(self)")
        }

        return value
    }
}
