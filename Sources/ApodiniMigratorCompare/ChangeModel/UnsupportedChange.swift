//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2021 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import Foundation

// MARK: UnsupportedChange
public struct UnsupportedChange<Definition: ChangeableElement> {
    public let change: Change<Definition>
    public let description: String
}

public extension Change {
    func classifyUnsupported(description: String) -> UnsupportedChange<Element> {
        UnsupportedChange(change: self, description: description)
    }
}
