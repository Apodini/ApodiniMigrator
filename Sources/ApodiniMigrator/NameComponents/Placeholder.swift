//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2021 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import Foundation

public struct Placeholder: CustomStringConvertible {
    public var description: String {
        "___\(name)___"
    }

    public var name: String

    public init(_ name: String) {
        self.name = name
    }
}

extension Placeholder: Equatable {}

extension Placeholder: Hashable {}
