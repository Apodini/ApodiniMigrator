//
//  ProjectFilesUpdater.swift
//  ApodiniMigratorShared
//
//  Created by Eldi Cano on 07.08.21.
//  Copyright © 2021 TUM LS1. All rights reserved.
//

import Foundation
import PathKit

enum ProjectFilesUpdater {
    private static let today: Date = {
        Date()
    }()
    private static var active = false
    private static func fileComment(from path: Path) -> [String] {
        let fileName = path.lastComponent
        var target = path.parent()
        
        while target.parent().lastComponent != "Sources" {
            target = target.parent()
        }
        
        let lines =
        """
        //
        //  \(fileName)
        //  \(target.lastComponent)
        //
        //  Created by Eldi Cano on \(Date().string(.date)).
        //  Copyright \u{00A9} \(Date().string(.year)) TUM LS1. All rights reserved.
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
        var current = Path(#file)
        
        while current.lastComponent != "Sources" {
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
                lines.replaceSubrange(0 ..< lastCommentIndex, with: fileComment(from: child))
                try child.write(lines.joined(separator: .lineBreak))
            }
        }
        #endif
    }
}
