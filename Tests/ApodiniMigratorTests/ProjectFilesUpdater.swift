//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2021 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import Foundation
import PathKit

enum ProjectFilesUpdater {
    private static let today: Date = {
        Date()
    }()
    private static var active = true
    private static func fileComment() -> [String] {
        
        let lines =
        """
        //
        // This source file is part of the Apodini open source project
        //
        // SPDX-FileCopyrightText: 2019-2021 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
        //
        // SPDX-License-Identifier: MIT
        //
        """.lines()
        return lines
    }
    
    static func run() throws {
        guard active else {
            return
        }
        
        #if Xcode
        //        var current = Path("/Users/eld/Desktop/ws2021/master_thesis/validation/Sources")
        var current = Path("/Users/eldicano/Desktop/ApodiniMigrator/Tests")
        
        while current.lastComponent != "Tests" {
            current = current.parent()
        }
        let swiftFiles = try current.recursiveSwiftFiles()
        for child in swiftFiles {
            let content: String = try child.read()
            if content.contains("Created by Eldi Cano on") {
                var lines = content.lines()
                var lastCommentIndex = 0
                while lines[lastCommentIndex].starts(with: "//") {
                    lastCommentIndex += 1
                }
                lines.replaceSubrange(0 ..< lastCommentIndex, with: fileComment())
                try child.write(lines.joined(separator: .lineBreak))
            }
        }
        #endif
    }
}
