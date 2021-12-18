//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2021 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import Foundation

public struct Group: SourceCodeComponent { // TODO document, only really useful in combination with the Joined operator!
    private let content: [SourceCodeComponent]

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
