//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2022 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import Foundation

/// A ``SourceCodeRenderable`` to render swift functions.
///
/// Those can be placed inside ``SourceCodeBuilder``s.
public struct SwiftFunction: SourceCodeRenderable {
    private static let indent: String = "    "

    private let name: String
    private let arguments: [String]
    private let returnType: String?
    private let access: String?
    private let sendable: Bool
    private let async: Bool
    private let `throws` : Bool
    private let whereClause: String?
    private let functionBody: String?

    /// Create a new SwiftFunction.
    ///
    /// - Note: This initializer doesn't require a `functionBody` and thus only generates the function signature.
    ///
    /// - Parameters:
    ///   - name: The function name
    ///   - arguments: Array of function arguments (e.g. `["_ someString: String", "number: Int"]`)
    ///   - returnType: The string representation of a return type. `nil` for `Void`.
    ///   - access: The optional access level as a string representation.
    ///   - sendable: Defines if the function is annotated with `@Sendable`.
    ///   - async: Defines if the function is declared as `async`.
    ///   - throws: Defines if the function is declared as throwing.
    ///   - whereClause: A string representation of a where clause.
    public init(
        name: String,
        arguments: [String] = [],
        returnType: String? = nil,
        access: String? = nil,
        sendable: Bool = false,
        async: Bool = false,
        throws: Bool = false,
        whereClause: String? = nil
    ) {
        self.name = name
        self.arguments = arguments
        self.returnType = returnType
        self.access = access
        self.sendable = sendable
        self.async = async
        self.throws = `throws`
        self.whereClause = whereClause
        self.functionBody = nil
    }

    /// Create a new SwiftFunction.
    /// - Parameters:
    ///   - name: The function name
    ///   - arguments: Array of function arguments (e.g. `["_ someString: String", "number: Int"]`)
    ///   - returnType: The string representation of a return type. `nil` for `Void`.
    ///   - access: The optional access level as a string representation.
    ///   - sendable: Defines if the function is annotated with `@Sendable`.
    ///   - async: Defines if the function is declared as `async`.
    ///   - throws: Defines if the function is declared as throwing.
    ///   - whereClause: A string representation of a where clause.
    ///   - functionBody: A ``SourceCodeBuilder`` closure to render the function body.
    public init(
        name: String,
        arguments: [String] = [],
        returnType: String? = nil,
        access: String? = nil,
        sendable: Bool = false,
        async: Bool = false,
        throws: Bool = false,
        whereClause: String? = nil,
        @SourceCodeBuilder functionBody: () -> String
    ) {
        self.name = name
        self.arguments = arguments
        self.returnType = returnType
        self.access = access
        self.sendable = sendable
        self.async = async
        self.throws = `throws`
        self.whereClause = whereClause
        self.functionBody = functionBody()
    }

    public var renderableContent: String {
        functionHead()

        if let body = functionBody {
            Indent {
                body
            }
            "}" // we assume that "functionHead" generated
        }
    }

    private func functionHead() -> String {
        var head = ""

        if let access = access {
            head += access + " "
        }

        if sendable {
            head += "@Sendable "
        }

        head += "func \(name)("

        var firstArgument = true
        for argument in arguments {
            if !firstArgument {
                head += ","
            } else {
                firstArgument = false
            }

            head += "\n"
            head += "\(Self.indent)\(argument)"
        }
        if !arguments.isEmpty {
            head += "\n"
        }

        head += ")"

        if async {
            head += " async"
        }

        if `throws` {
            head += " throws"
        }

        if let returnType = returnType {
            head += " -> \(returnType)"
        }

        if let whereClause = whereClause {
            head += " \(whereClause)"
        }

        if functionBody != nil {
            head += " {"
        }

        return head
    }
}
