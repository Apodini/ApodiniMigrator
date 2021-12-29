//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2021 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import Foundation

/// This type can be used to mark a particular ``Change`` as unsupported by the `Migrator`.
public struct UnsupportedChange<Definition: ChangeableElement> {
    /// The change which is unsupported.
    public let change: Change<Definition>
    /// A short textual description why this change is unsupported.
    /// This description may be used to render the change to the user.
    public let description: String
}

public extension Change {
    /// Classifies a given change instance as an ``UnsupportedChange``.
    func classifyUnsupported(description: String) -> UnsupportedChange<Element> {
        UnsupportedChange(change: self, description: description)
    }
}
