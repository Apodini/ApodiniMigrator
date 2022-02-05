//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2022 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import Foundation

public extension String {
    /// Line break
    static var lineBreak: String {
        "\n"
    }
    
    /// `self` wrapped with double quotes
    var doubleQuoted: String {
        "\"\(self)\""
    }
    
    /// `self` wrapped with single quotes
    var singleQuoted: String {
        "\'\(self)\'"
    }
    
    /// Returns a version of self without the last question mark if present
    var dropQuestionMark: String {
        if last == "?" {
            return String(dropLast())
        }
        return self
    }
    
    /// Return the string with an uppercased first character
    var upperFirst: String {
        if let first = first {
            return first.uppercased() + dropFirst()
        }
        return self
    }
    
    /// Return the string with a lowercased first character
    var lowerFirst: String {
        if let first = first {
            return first.lowercased() + dropFirst()
        }
        return self
    }
}
