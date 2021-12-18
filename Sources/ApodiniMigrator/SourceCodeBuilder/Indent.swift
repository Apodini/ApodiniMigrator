//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2021 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import Foundation

public struct Indent: SourceCodeComponent {
    private let indentString: String
    private let content: [SourceCodeComponent]

    public init(with indentString: String = "    ", _ content: String) {
        self.indentString = indentString
        self.content = [content]
    }

    public init(
        with indentString: String = "    ",
        @SourceCodeComponentBuilder content: () -> [SourceCodeComponent]
    ) {
        self.indentString = indentString
        self.content = content()
    }

    public func render() -> [String] {
        content
            .map { $0.render() }
            .flatten()
            .map { indentString + $0 }
    }
}
