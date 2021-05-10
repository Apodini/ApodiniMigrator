//
//  File.swift
//  
//
//  Created by Eldi Cano on 07.05.21.
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
        self.comment = Self.base + comment.without(Self.base)
    }
    
    /// Initializer for a `MARKComment` instance
    /// - Parameters:
    ///     - markCommentType: the type of the comment
    init(_ markCommentType: MARKCommentType) {
        self.init(markCommentType.comment)
    }
}
