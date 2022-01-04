//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2022 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import Foundation

/// A way of Grouping several ``SourceCodeComponent``s.
/// This can be handy to treat multiple ``SourceCodeComponent``s as a single component (e.g. in combination with the ``Joined`` component).
public struct Group: SourceCodeComponent {
    private let content: [SourceCodeComponent]

    /// Initialize a new `Group`
    /// - Parameter content: The content of the group.
    public init(@SourceCodeComponentBuilder content: () -> [SourceCodeComponent]) {
        self.content = content()
    }

    internal init(content: [SourceCodeComponent]) {
        self.content = content
    }

    public func render() -> [String] {
        content
            .map { $0.render() }
            .flatten()
    }
}
