//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2022 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import Foundation

extension String {
    // this is basically a `replacingOccurrences(of:with:)`
    // though it considers the indent of a `placeholder` and applies it to the lines of `content`
    mutating func replaceOccurrencesRespectingIndent(of target: String, with replacement: String) {
        while let range = self.range(of: target) {
            let indentString = indent(at: range)
            let indentedReplacement = replacement
                .split(separator: "\n", omittingEmptySubsequences: false)
                .joined(separator: "\n\(indentString)")
            self.replaceSubrange(range, with: indentedReplacement)
        }
    }

    private func indent(at range: Range<String.Index>) -> String {
        var index = self.index(before: range.lowerBound)

        var indent = ""

        while self[index] == " " {
            index = self.index(before: index)
            indent += " "
        }

        if self[index] == "\n" {
            return indent
        }

        return ""
    }
}
