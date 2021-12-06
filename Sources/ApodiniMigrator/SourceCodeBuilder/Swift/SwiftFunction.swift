//
// Created by Andreas Bauer on 05.12.21.
//

import Foundation

public struct SwiftFunction: SourceCodeRenderable {
    private let name: String
    private let arguments: [String]
    private let returnType: String?
    private let access: String?
    private let sendable: Bool
    private let async: Bool
    private let `throws` : Bool
    private let whereClause: String?
    private let functionBody: String?

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
            head += "    \(argument)" // TODO idnent character
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
