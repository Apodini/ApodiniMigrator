//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2022 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import Foundation
import ApodiniMigrator

@dynamicMemberLookup
struct GRPCMessageField {
    private let field: SomeGRPCMessageField
    var context: ProtoFileContext {
        field.context
    }

    var generateTraverseUsesLocals: Bool {
        !field.isRepeated && field.hasFieldPresence
    }

    init(_ field: SomeGRPCMessageField) {
        self.field = field
    }

    subscript<T>(dynamicMember member: KeyPath<SomeGRPCMessageField, T>) -> T {
        field[keyPath: member]
    }

    func tryTyped<Field: SomeGRPCMessageField>(for type: Field.Type = Field.self) -> Field? {
        field as? Field
    }

    @SourceCodeBuilder
    var propertyInterface: String {
        if let comments = field.sourceCodeComments {
            comments
        }

        if field.unavailable {
            // we do no deprecation warning, as we can handle removed properties
            "@available(*, message: \"This property was removed in the latest version.\")"
        }

        if field.hasFieldPresence {
            "\(context.options.visibility) var \(field.name): \(field.typeName) {"
            Indent {
                "get {"
                Indent("return \(field.privateName) ?? \(field.defaultValue)")
                "}"
                "set {"
                Indent("\(field.privateName) = newValue")
                "}"
            }
            "}"
        } else {
            "\(context.options.visibility) var \(field.name): \(field.storageType) = \(field.defaultValue)"
        }

        if field.hasFieldPresence {
            ""
            "\(context.options.visibility) var \(field.propertyHasName): Bool {"
            Indent("return \(field.privateName) != nil")
            "}"
            ""
            "\(context.options.visibility) mutating func \(field.funcClearName)() {"
            Indent("\(field.privateName) = nil")
            "}"
        }
    }

    @SourceCodeBuilder
    var fieldDecodeCase: String {
        precondition(!field.unavailable, "fieldDecodeCase was called for field \(field.name) which is unavailable!")

        var decoderMethod: String = ""
        var fieldTypeArg: String = ""

        if let change = field.typeUpdate {
            if change.to.isMap {
                decoderMethod = "decodeMapField"
                fieldTypeArg = "fieldType: \(change.to.traitsType(namer: context.namer)).self, "
            } else {
                let modifier = change.to.isRepeated ? "Repeated" : "Singular"
                decoderMethod = "decode\(modifier)\(change.to.deriveProtoGenericType())Field"
                fieldTypeArg = ""
            }
        } else {
            if field.isMap {
                decoderMethod = "decodeMapField"
                fieldTypeArg = "fieldType: \(field.traitsType).self, "
            } else {
                let modifier = field.isRepeated ? "Repeated" : "Singular"
                decoderMethod = "decode\(modifier)\(field.protoGenericType)Field"
                fieldTypeArg = ""
            }
        }

        "case \(field.number): try {"
        Indent {
            let decodeLine = "try decoder.\(decoderMethod)(\(fieldTypeArg)value: &\(field.storedProperty))"

            if let change = field.typeUpdate {
                "var \(field.storedProperty): \(change.to.swiftStorageType(namer: context.namer)) = \(change.to.swiftDefaultValue(namer: context.namer))"
                decodeLine
                "self.\(field.storedProperty) = try \(field.typeName).from(\(field.storedProperty), script: \(change.backwardMigration)"
            } else {
                decodeLine
            }
        }
        "}()"
    }

    @SourceCodeBuilder
    var fieldDecodeCaseStatements: String {
        if field.unavailable {
            if let fallbackValue = field.fallbackValue {
                "\(field.storedProperty) = try \(field.typeName).instance(from: \(fallbackValue))"
            } else {
                "// field \(field.name) was removed and no fallback value was supplied. Handling it like a missing property"
            }
        } else if let change = field.necessityUpdate, change.to == .optional {
            // field value might not be delivered anymore by the web service!
            "if !decodedFieldNumbers.contains(\(field.number)) {"
            Indent("\(field.storedProperty) = try \(field.typeName).instance(from: \(change.necessityMigration))")
            "}"
        } else {
            EmptyComponent()
        }
    }

    @SourceCodeBuilder
    var traverseExpression: String {
        // removed fields won't ever be encoded into the proto message
        precondition(!field.unavailable, "Unavailability of fields must be handled on the outside: \(field.name)!")

        var visitMethod: String = ""
        var traitsArg: String = ""
        var typeMigrationClosure: (String) -> String = { $0 }

        if let change = field.typeUpdate {
            if change.to.isMap {
                visitMethod = "visitMapField"
                traitsArg = "fieldType: \(change.to.traitsType(namer: context.namer)).self, "
            } else {
                let modifier = field.isPacked ? "Packed" : change.to.isRepeated ? "Repeated" : "Singular"
                visitMethod = "visit\(modifier)\(change.to.deriveProtoGenericType())Field"
                traitsArg = ""
            }

            let newTypeName = change.to.swiftType(namer: context.namer)
            typeMigrationClosure = { varName in
                "try \(newTypeName).from(\(varName), script: \(change.forwardMigration))"
            }
        } else {
            if field.isMap {
                visitMethod = "visitMapField"
                traitsArg = "fieldType: \(field.traitsType).self, "
            } else {
                let modifier = field.isPacked ? "Packed" : field.isRepeated ? "Repeated" : "Singular"
                visitMethod = "visit\(modifier)\(field.protoGenericType)Field"
                traitsArg = ""
            }
        }

        let varName = field.hasFieldPresence ? "value" : field.storedProperty

        var usesLocals = false
        var conditional: String = ""
        if field.isRepeated {
            conditional = "!\(varName).isEmpty"
        } else if field.hasFieldPresence {
            conditional = "let value = \(field.storedProperty)"
            usesLocals = true
        } else {
            switch field.type {
            case .string, .bytes:
                conditional = ("!\(varName).isEmpty")
            default:
                conditional = ("\(varName) != \(field.defaultValue)")
            }
        }


        assert(usesLocals == generateTraverseUsesLocals)

        let prefix = usesLocals ? "try { " : ""
        let suffix = usesLocals ? " }()" : ""

        "\(prefix)if \(conditional) {"
        Indent("try visitor.\(visitMethod)(\(traitsArg)value: \(typeMigrationClosure(varName)), fieldNumber: \(field.number))")

        if let change = field.necessityUpdate, change.to == .required {
            let migratedValue = "try \(field.typeName).from(from: \(change.necessityMigration))"

            "} else {"
            Indent("""
                   try visitor.\(visitMethod)(\
                   \(traitsArg)\
                   value: \(typeMigrationClosure(migratedValue)), \
                   fieldNumber: \(field.number)\
                   )
                   """)
        }

        "}\(suffix)"
    }

    @SourceCodeBuilder
    var codableEncodeMethodLine: String {
        let defaultEncodeLine: () -> String = {
            let encodeMethodString = "encode\(field.hasFieldPresence ? "IfPresent": "")"
            return "try container.\(encodeMethodString)(\(field.storedProperty), forKey: .\(field.name)"
        }

        if let change = field.necessityUpdate {
            if change.to != .required {
                defaultEncodeLine()
            } else {
                """
                try container.encode(\
                \(field.storedProperty) ?? (try \(field.typeName).instance(from: \(change.necessityMigration))), \
                forKey: .\(field.name)\
                )
                """
            }
        } else if let change = field.typeUpdate {
            let encodeMethodString = "encode\(change.to.isOptional ? "IfPresent": "")"
            let newTypeName = change.to.swiftType(namer: context.namer)

            """
            try container.\(encodeMethodString)(\
            try \(newTypeName).from(\(field.storedProperty), script: \(change.forwardMigration))\
            forKey: .\(field.name)\
            )
            """
        } else {
            defaultEncodeLine()
        }
    }

    @SourceCodeBuilder
    var codableDecodeInit: String {
        let defaultDecodeLine: () -> String = {
            let decodeMethodString = "decode\(field.hasFieldPresence ? "IfPresent" : "")"
            return "\(field.storedProperty) = try container.\(decodeMethodString)(\(field.typeName).self, forKey: .\(field.name))"
        }

        if field.unavailable {
            if let fallbackValue = field.fallbackValue {
                "\(field.storedProperty) = try \(field.typeName).instance(from: \(fallbackValue))"
            } else {
                "\(field.storedProperty) = nil"
            }
        } else if let change = field.necessityUpdate {
            if change.to != .optional {
                defaultDecodeLine()
            } else {
                """
                \(field.storedProperty) = try container.decodeIfPresent(\
                \(field.typeName).self, \
                forKey: .\(field.name)\
                ) ?? (try \(field.typeName).instance(from: \(change.necessityMigration)))
                """
            }
        } else if let change = field.typeUpdate {
            let decodeMethodString = "decode\(change.to.isOptional ? "IfPresent" : "")"
            let newTypeName = change.to.swiftType(namer: field.context.namer)

            """
            \(field.storedProperty) = try \(field.typeName).from(\
            try container.\(decodeMethodString)(\(newTypeName).self, forKey: .\(field.name),\
            script: \(change.backwardMigration)\
            )
            """
        } else {
            defaultDecodeLine()
        }
    }
}
