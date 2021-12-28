//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2021 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import Foundation

public struct StringFile: GeneratedFile {
    public let fileName: Name
    public let renderableContent: String

    public init(name fileName: Name, content: String) {
        self.fileName = fileName
        self.renderableContent = content
    }

    public init(name fileName: Name, @SourceCodeBuilder content: () -> String) {
        self.fileName = fileName
        self.renderableContent = content()
    }
}
