//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2021 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import Foundation

public struct StubLinuxMainFile: GeneratedFile {
    public var fileName: Name = "LinuxMain.swift"

    let filePrefix: String

    public init(@SourceCodeBuilder prefix filePrefix: () -> String = { "" }) {
        self.filePrefix = filePrefix()
    }

    public var renderableContent: String {
        if !filePrefix.isEmpty {
            filePrefix
        }

        """
        #error(\"""
               -----------------------------------------------------
               Please test with `swift test --enable-test-discovery`
               -----------------------------------------------------
               \""")
        """
    }
}
