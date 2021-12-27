//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2021 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import Foundation
import SwiftProtobuf
import SwiftProtobufPluginLibrary
import ApodiniMigratorCompare
import ApodiniTypeInformation

// TODO plain copy of ObjectMigrator (rework API fundamentals!)

struct MessageMigrator {
    private let message: Descriptor
    /// The SwiftProtobufNamer cache
    private var namer: SwiftProtobufNamer
    /// The identifier of the Message to be matched with migration guide changes
    private let identifier: DeltaIdentifier
    /// All changes applied to the message (according to the above identifier)
    private let changes: [ModelChange]

    /// The swift type name of the Message (as generated by swift-protobuf).
    private let swiftFullName: String

    /// All properties that have been added in the new version
    private var addedProperties: [PropertyChange.AdditionChange] = []
    /// All properties that have been deleted in the new version
    private var deletedProperties: [PropertyChange.RemovalChange] = []
    /// All renaming changes of properties
    private var renamePropertyChanges: [PropertyChange.IdentifierChange] = []
    /// All update changes of properties
    private var updatedProperties: [PropertyChange.UpdateChange] = []

    // TODO private let unsupportedChange: LegacyUnsupportedChange? = nil // TODO ?
    /// A flag that indicates whether the object is present in the new version or not
    // TODO private let notPresentInNewVersion: Bool
    /// All old properties of the object
    private let oldProperties: [TypeProperty] = [] // TODO all TypeInformation properties(?)

    // TODO we currently do not handle
    //  - Visibility!
    //  - one Of
    //  - enums
    //  - nested types!
    //  - necessity (has<> and clear<> methods)

    init(_ message: Descriptor, namer: SwiftProtobufNamer, modelChanges: [ModelChange]) {
        self.message = message
        self.namer = namer

        // TODO identifier? retrieval, uniqueness etc?
        let identifier = DeltaIdentifier(rawValue: message.name.replacingOccurrences(of: "Message", with: ""))
        self.identifier = identifier
        self.changes = modelChanges.filter { $0.id == identifier }

        self.swiftFullName = namer.fullName(message: message)

        // TODO unsupported changes!

        for change in changes {
            guard let modelUpdate = change.modeledUpdateChange,
                  case let .property(propertyChange) = modelUpdate.updated else {
                continue
            }

            if let additionChange = propertyChange.modeledAdditionChange {
                self.addedProperties.append(additionChange)
            } else if let removalChange = propertyChange.modeledRemovalChange {
                self.deletedProperties.append(removalChange)
            } else if let identifierChange = propertyChange.modeledIdentifierChange {
                self.renamePropertyChanges.append(identifierChange)
            } else if let updateChange = propertyChange.modeledUpdateChange {
                self.updatedProperties.append(updateChange)
            }
        }
    }

    func migrate(into generator: inout CodePrinter) throws {
        generator.print("\n\n")

        generator.print("@dynamicMemberLookup\n")
        // TODO this name must orient itself at the migration guide. MUST always be the OLD name!
        generator.print("public struct \(swiftFullName): SwiftProtobufWrapper {\n")
        generator.indent()

        // TODO we don't support enums yet?

        // TODO reengineer such that this isn't public!
        generator.print("public var __wrapped: _PB_GENERATED.\(swiftFullName)\n")
        generator.print("\n")

        generator.print("public init() {\n")
        generator.indent()
        generator.print("__wrapped = .init()\n")
        generator.outdent()
        generator.print("}\n")

        // TODO generate empty initializers?

        /*
         TODO init args generation must be stable!
        generator.print("public init(\n")
        generator.indent()
        // TODO generate optional init args!
        generator.outdent()
        generator.print(") {\n")
        generator.indent()
        generator.print("__wrapped = .init()\n")
        // TODO pass init args to wrapped value
        generator.outdent()
        generator.print("}\n")
         */

        try migrateProperties(into: &generator)

        generator.outdent()
        generator.print("}\n")
    }

    private func migrateProperties(into generator: inout CodePrinter) throws {
        // we do not need to handle added properties

        // TODO can a single property encounter multiple changes?
        //  => e.g. type change and necessity change?
        //  => e.g. name and type change?

        // handling renamed properties
        for change in renamePropertyChanges {
            guard let field = message.fields.first(where: { $0.name == change.to.rawValue }) else {
                fatalError("asdf") // TODO message
            }

            let type = field.swiftType(namer: namer)

            generator.print("\n")
            generator.print("var \(change.from.rawValue): \(type) {\n")
            generator.indent()
            generator.print("__wrapped.\(change.to.rawValue)\n")
            generator.outdent()
            generator.print("}\n")

            // TODO handle necessity
        }

        // handling removed properties
        for change in deletedProperties {
            // TODO deletedProperty will most likely only be a ID!
            //   with gRPC we don't have the description of the previous property!!
            let fallbackValue = change.fallbackValue
            // TODO fallbackValue is typically a int id which is used to decode the fallbackValue from JSON
            // TODO what is if that isn't present?

            // TODO for now we just print a `available` thingy!
            generator.print("\n")
            generator.print("@available(*, deprecated, message: \"This property was removed!\"")
            // TODO we currently DO NOT have the type!
            generator.print("var \(change.id.rawValue): String {\n")
            generator.indent()
            generator.print("fatalError(\"The property \(change.id.rawValue) was deleted!\")")
            generator.outdent()
            generator.print("}\n")

            // TODO handle necessity
        }

        // handling necessity changes
        for change in updatedProperties {
            guard case let .necessity(from, to, migration) = change.updated else {
                continue
            }

            let propertyName = change.id.rawValue

            guard let field = message.fields.first(where: { $0.name == propertyName }) else {
                fatalError("asd") // TODO message
            }

            // TODO how are double optionals handled?

            precondition(from != to, "Illegal migration guide. Matching property necessity types!")

            // We only need to handle the case were we migrate from optional to required, then.
            //  required -> optional is solely a additive change (where swift-protobuf generates the new hasXXX and clearXXX symbols)
            //  optional -> required is a breaking change (hasXXX and clearXXX symbols are removed)
            if case .required = to {
                let type = field.swiftType(namer: namer)

                generator.print("\n")
                generator.print("var \(propertyName): \(type): {\n")
                generator.indent()
                generator.print("get { __wrapped.\(propertyName) }\n")
                generator.print("set {\n")
                generator.indent()
                generator.print("__wrapped.\(propertyName) = newValue\n")
                generator.print("has\(propertyName) = true\n")
                generator.outdent()
                generator.print("}")
                generator.outdent()
                generator.print("}\n")

                // TODO first letter upperCase!
                generator.print("fileprivate(set) var has\(propertyName): Bool = false\n")
                // TODO we can't decode between first set or default value when decoding from write?
                //  hook into `decodeMessage` and iterate through the decoder to check if the field number is present!
                generator.print("mutating func clear\(propertyName)() {\n")
                generator.indent()
                generator.print("__wrapped.\(propertyName) = .init()") // TODO does this default value thing work?
                generator.print("has\(propertyName) = false\n")
                generator.outdent()
                generator.print("}\n")
            }
        }

        for change in updatedProperties {
            guard case let .type(from, to, forwardMigration, backwardMigration, warning) = change.updated else {
                continue
            }

            let propertyName = change.id.rawValue

            // TODO why are type changes always JS script based?
            // TODO conversions scripts always build upon Codable, we don't have that with non standard types?

            guard case let .scalar(fromType) = from,
                  case let .scalar(toType) = to,
                  !fromType.unsupported,
                  !toType.unsupported else {
                fatalError("Non scalar type migrations aren't currently supported!")
            }

            // TODO scalar types might not match to gRPC definition

            // placeholder '#' is for the value
            let forwardMigrationString: String // fromType -> toType
            let backwardMigrationString: String // toType -> fromType

            switch (fromType, fromType.isNumeric, toType, toType.isNumeric) {
            case let (from, true, to, true):
                forwardMigrationString = "\(to.swiftType)(#)"
                backwardMigrationString = "\(from.swiftType)(#)"

            case let (from, true, .string, _):
                forwardMigrationString = "String(#)"
                backwardMigrationString = "\(from.swiftType)(#)!" // TODO force unwrap?
            case let (.string, _, to, true):
                forwardMigrationString = "\(to.swiftType)(#)!" // TODO force unwrap?
                backwardMigrationString = "String(#)"

            case (.bool, _, .string, _):
                forwardMigrationString = "String(#)"
                backwardMigrationString = "Bool(#)!"
            case (.string, _, .bool, _):
                forwardMigrationString = "Bool(#)!"
                backwardMigrationString = "String(#)"

            default:
                fatalError("Unsupported scalar types!")
            }

            guard let field = message.fields.first(where: { $0.name == propertyName }) else {
                fatalError("asd") // TODO message
            }

            generator.print("\n")
            generator.print("var \(propertyName): \(fromType.swiftType) {\n")
            generator.indent()
            generator.print("get { \(backwardMigrationString.replacingOccurrences(of: "#", with: "__wrapped.\(propertyName)")) }\n")
            generator.print("set { __wrapped.\(propertyName) = \(forwardMigrationString.replacingOccurrences(of: "#", with: "newValue")) }\n")
            generator.outdent()
            generator.print("}\n")

            // TODO handle necessity
        }
    }
}

extension PrimitiveType {
    var unsupported: Bool {
        switch self {
        case .data, .date, .null:
            return true
        default:
            return false
        }
    }

    var isNumeric: Bool {
        switch self {
        case .int,
             .int8,
             .int16,
             .int32,
             .int64,
             .uint,
             .uint8,
             .uint16,
             .uint32,
             .uint64,
             .double,
             .float:
            return true
        default:
            return false
        }
    }
}

// TODO this is a plain copy!!
extension FieldDescriptor {
    func swiftType(namer: SwiftProtobufNamer) -> String {
        if case let (keyField, valueField)? = messageType?.mapKeyAndValue {
            let keyType = keyField.swiftType(namer: namer)
            let valueType = valueField.swiftType(namer: namer)
            return "Dictionary<" + keyType + "," + valueType + ">"
        }

        let result: String
        switch type {
        case .double: result = "Double"
        case .float: result = "Float"
        case .int64: result = "Int64"
        case .uint64: result = "UInt64"
        case .int32: result = "Int32"
        case .fixed64: result = "UInt64"
        case .fixed32: result = "UInt32"
        case .bool: result = "Bool"
        case .string: result = "String"
        case .group: result = namer.fullName(message: messageType)
        case .message: result = namer.fullName(message: messageType)
        case .bytes: result = "Data"
        case .uint32: result = "UInt32"
        case .enum: result = namer.fullName(enum: enumType)
        case .sfixed32: result = "Int32"
        case .sfixed64: result = "Int64"
        case .sint32: result = "Int32"
        case .sint64: result = "Int64"
        }

        if label == .repeated {
            return "[\(result)]"
        }
        return result
    }
}
