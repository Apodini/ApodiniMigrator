//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2021 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import Foundation

/// A protocol for annotations that might appear in a `Swift` file
protocol Annotation: CustomStringConvertible {
    /// String content / comment of this annotation
    var comment: String { get }
}

/// Default `CustomStringConvertible`implementation
extension Annotation {
    /// String representation of an annotation constructed with the specified `indentation` and `comment`
    var description: String {
        comment
    }
}

struct GenericComment: Annotation {
    let comment: String
}

struct EndpointComment: Annotation {
    let comment: String
    
    init(_ handlerName: String, path: String) {
        comment = "/// API call for \(handlerName) at: \(path)"
    }
}

/// A `MARK` comment annotation
struct MARKComment: Annotation {
    /// The `// MARK: - ` string of the comment
    static let base = "// MARK: - "
    
    /// String content / comment of the instance
    let comment: String
    
    /// Initializer for a `MARKComment` instance
    /// - Parameters:
    ///     - comment: The string that follows `// MARK: - `
    init(_ comment: String) {
        self.comment = Self.base + comment.replacingOccurrences(of: Self.base, with: "")
    }
    
    /// Initializer for a `MARKComment` instance
    /// - Parameters:
    ///     - markCommentType: the type of the comment
    init(_ markCommentType: MARKCommentType) {
        self.init(markCommentType.comment)
    }
}

extension MARKComment: Comparable {
    static func < (lhs: MARKComment, rhs: MARKComment) -> Bool {
        lhs.comment < rhs.comment
    }
}
