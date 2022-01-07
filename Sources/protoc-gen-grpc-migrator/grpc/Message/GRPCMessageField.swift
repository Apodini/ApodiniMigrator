//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2022 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import Foundation
import ApodiniMigrator
import SwiftProtobufPluginLibrary

struct GRPCMessageField {
    let descriptor: FieldDescriptor

    let hasFieldPresence: Bool

    let name: String
    let privateName: String
    let storedProperty: String
    let propertyHasName: String
    let funcClearName: String

    let typeName: String
    let storageType: String
    let defaultValue: String
    let traitsType: String

    let comments: String

    let number: Int

    var fieldMapNames: String { // TODO what kind of monstrosity is this?
        // Protobuf Text uses the unqualified group name for the field
        // name instead of the field name provided by protoc.  As far
        // as I can tell, no one uses the fieldname provided by protoc,
        // so let's just put the field name that Protobuf Text
        // actually uses here.
        let protoName: String
        if descriptor.type == .group {
            protoName = descriptor.messageType.name
        } else {
            protoName = descriptor.name
        }

        let jsonName = descriptor.jsonName ?? protoName
        if jsonName == protoName {
            // The proto and JSON names are identical:
            return ".same(proto: \"\(protoName)\")"
        } else {
            let libraryGeneratedJsonName = NamingUtils.toJsonFieldName(protoName)
            if jsonName == libraryGeneratedJsonName {
                // The library will generate the same thing protoc gave, so
                // we can let the library recompute this:
                return ".standard(proto: \"\(protoName)\")"
            } else {
                // The library's generation didn't match, so specify this explicitly.
                return ".unique(proto: \"\(protoName)\", json: \"\(jsonName)\")"
            }
        }
    }

    private var isMap: Bool {
        descriptor.isMap
    }
    private var isPacked: Bool {
        descriptor.isPacked
    }

    // Note: this could still be a map (since those are repeated message fields
    private var isRepeated: Bool {
        descriptor.label == .repeated
    }

    init(descriptor: FieldDescriptor, namer: SwiftProtobufNamer) {
        self.descriptor = descriptor

        precondition(descriptor.realOneof == nil, "OneOfs aren't supported yet") // TODO ever?

        self.hasFieldPresence = descriptor.hasPresence && descriptor.realOneof == nil

        let names = namer.messagePropertyNames(field: descriptor, prefixed: "_", includeHasAndClear: hasFieldPresence)
        self.name = names.name
        self.privateName = names.prefixed
        self.storedProperty = hasFieldPresence ? privateName : name // TODO depends on heap storage thing!
        self.propertyHasName = names.has
        self.funcClearName = names.clear

        typeName = descriptor.swiftType(namer: namer)
        storageType = descriptor.swiftStorageType(namer: namer)
        defaultValue = descriptor.swiftDefaultValue(namer: namer)
        traitsType = descriptor.traitsType(namer: namer)

        comments = descriptor.protoSourceComments()
        
        self.number = Int(descriptor.number)
    }

    @SourceCodeBuilder
    var propertyInterface: String {
        // TODO visibility on all generated thingys
        comments

        // TODO heapStorage thingy?

        if hasFieldPresence {
            "public var \(name): \(typeName) {"
            Indent {
                "get {"
                Indent("return \(privateName) ?? \(defaultValue)")
                "}"
                "set {"
                Indent("\(privateName) = newValue")
                "}"
            }
            "}"
        } else {
            "public var \(name): \(storageType) = \(defaultValue)"
        }

        if hasFieldPresence {
            ""
            "public var \(propertyHasName): Bool {"
            Indent("return \(privateName) != nil")
            "}"
            ""
            "public mutating func \(funcClearName)() {"
            Indent("\(privateName) = nil")
            "}"
        }
    }

    @SourceCodeBuilder
    var fieldDecodeCase: String {
        var decoderMethod: String = ""
        var fieldTypeArg: String = ""

        if isMap {
            decoderMethod = "decodeMapField"
            fieldTypeArg = "fieldType: \(traitsType).self, "
        } else {
            let modifier = isRepeated ? "Repeated" : "Singular"
            decoderMethod = "decode\(modifier)\(descriptor.protoGenericType)Field"
            fieldTypeArg = ""
        }

        "case \(number): try { try decoder.\(decoderMethod)(\(fieldTypeArg)value: &\(storedProperty)) }()"
    }

    var generateTraverseUsesLocals: Bool { // TODO what the hell is this
        return !isRepeated && hasFieldPresence
    }

    @SourceCodeBuilder
    var traverseExpression: String {
        var visitMethod: String = ""
        var traitsArg: String = ""
        if isMap {
            visitMethod = "visitMapField"
            traitsArg = "fieldType: \(traitsType).self, "
        } else {
            let modifier = isPacked ? "Packed" : isRepeated ? "Repeated" : "Singular"
            visitMethod = "visit\(modifier)\(descriptor.protoGenericType)Field"
            traitsArg = ""
        }

        let varName = hasFieldPresence ? "value" : storedProperty

        var usesLocals = false
        var conditional: String = ""
        if isRepeated {
            conditional = "!\(varName).isEmpty"
        } else if hasFieldPresence {
            conditional = "let value = \(storedProperty)"
            usesLocals = true
        } else {
            assert(descriptor.file.syntax == .proto3)

            switch descriptor.type {
            case .string, .bytes:
                conditional = ("!\(varName).isEmpty")
            default:
                conditional = ("\(varName) != \(defaultValue)")
            }
        }


        assert(usesLocals == generateTraverseUsesLocals)

        let prefix = usesLocals ? "try { " : ""
        let suffix = usesLocals ? " }()" : ""

        "\(prefix)if \(conditional) {"
        Indent("try visitor.\(visitMethod)(\(traitsArg)value: \(varName), fieldNumber: \(number))")
        "}\(suffix)"
    }
}
