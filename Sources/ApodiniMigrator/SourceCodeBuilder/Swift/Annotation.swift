//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2022 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import Foundation

/// A protocol for annotations that might appear in a `Swift` file
public protocol Annotation: CustomStringConvertible {
    /// String content / comment of this annotation
    var comment: String { get }
}

/// Default `CustomStringConvertible`implementation
public extension Annotation {
    /// String representation of an annotation constructed with the specified `indentation` and `comment`
    var description: String {
        comment
    }
}


public struct GenericComment: Annotation {
    public let comment: String

    public init(comment: String) {
        self.comment = comment
    }
}


public struct EndpointComment: Annotation {
    public let comment: String

    public init(_ handlerName: String, path: String) {
        comment = "/// API call for \(handlerName) at: \(path)"
    }
}


/// A `MARK` comment annotation
public struct MARKComment: Annotation {
    /// Distinct cases of mark comments that might appear in a file
    public enum CommentType: String {
        case model
        case deprecated
        case codingKeys
        case properties
        case initializer
        case encodable
        case decodable
        case utils
        case endpoints

        public var comment: String {
            rawValue.upperFirst
        }
    }

    /// The `// MARK: - ` string of the comment
    static let base = "// MARK: - "
    
    /// String content / comment of the instance
    public let comment: String
    
    /// Initializer for a `MARKComment` instance
    /// - Parameters:
    ///     - comment: The string that follows `// MARK: - `
    public init(_ comment: String) {
        self.comment = Self.base + comment.replacingOccurrences(of: Self.base, with: "")
    }
    
    /// Initializer for a `MARKComment` instance
    /// - Parameters:
    ///     - markCommentType: the type of the comment
    public init(_ markCommentType: MARKComment.CommentType) {
        self.init(markCommentType.comment)
    }
}

extension MARKComment: Comparable {
    public static func < (lhs: MARKComment, rhs: MARKComment) -> Bool {
        lhs.comment < rhs.comment
    }
}
