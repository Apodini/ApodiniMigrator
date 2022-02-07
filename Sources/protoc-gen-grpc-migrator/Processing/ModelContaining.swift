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
import OrderedCollections

protocol ModelContaining {
    var context: ProtoFileContext { get }
    var migration: MigrationContext { get }

    var fullName: String { get }

    var nestedMessages: OrderedDictionary<String, GRPCMessage> { get set }
    var nestedEnums: OrderedDictionary<String, GRPCEnum> { get set }

    mutating func add(model: TypeInformation, using nameIterator: inout Array<TypeNameComponent>.Iterator, depth: Int)

    func find(for typeName: TypeName, using nameIterator: inout Array<TypeNameComponent>.Iterator, depth: Int) -> ModelSearchResult?
}

extension ModelContaining {
    mutating func add(model: TypeInformation) {
        var typeNameIterator = model.typeName.makeIterator()
        add(model: model, using: &typeNameIterator, depth: 0)
    }

    mutating func add(model: TypeInformation, using nameIterator: inout Array<TypeNameComponent>.Iterator, depth: Int) {
        guard let nextName = nameIterator.next() else {
            fatalError("Run out of iterable elements.")
        }

        if depth == model.typeName.nestedTypes.count { // depth isn't incremented and nestedTypes.count is 'fullName'-1
            assert(nextName.name == model.typeName.mangledName)

            // name must be free in both dictionaries
            precondition(nestedMessages[nextName.name] == nil, "Addition of model would result in a collision with a existent message: \(nextName.name)")
            precondition(nestedEnums[nextName.name] == nil, "Addition of model would result in a collision with a existent enum: \(nextName.name)")

            switch model.rootType {
            case .object:
                nestedMessages[nextName.name] = GRPCMessage(
                    ApodiniGRPCMessage(of: model, context: context, migration: migration)
                )
            case .enum:
                nestedEnums[nextName.name] = GRPCEnum(
                    ApodiniGRPCEnum(of: model, context: context)
                )
            default:
                fatalError("Encountered unexpected root type: \(model.rootType) of type \(model.typeName)")
            }
        } else {
            // map mutating requires exclusive access to `self`. Therefore we can't access
            // the values in the `default:` closure and must compute/store those beforehand
            let fullName = fullName
            let context = context
            let migration = migration

            nestedMessages[
                nextName.name,
                default: GRPCMessage(
                    EmptyGRPCMessage(
                        name: nextName.name,
                        nestedIn: fullName,
                        context: context,
                        migration: migration
                    )
                )
            ].add(model: model, using: &nameIterator, depth: depth + 1)
        }
    }
}

extension ModelContaining {
    func find(for typeName: TypeName) -> ModelSearchResult? {
        var typeNameIterator = typeName.makeIterator()
        return find(for: typeName, using: &typeNameIterator, depth: 0)
    }

    func find(for typeName: TypeName, using nameIterator: inout Array<TypeNameComponent>.Iterator, depth: Int) -> ModelSearchResult? {
        guard let nextName = nameIterator.next() else {
            fatalError("When trying to find model, run out of iterable elements for type \(typeName)!")
        }

        if depth == typeName.nestedTypes.count { // depth isn't incremented and nestedTypes is 'fullName' -1
            assert(nextName.name == typeName.mangledName, "Encountered inconsistent state for type \(typeName).")

            if let message = nestedMessages[nextName.name] {
                assert(nestedEnums[nextName.name] == nil, "Encountered inconsistent state for type \(typeName).")
                return .message(message)
            } else if let `enum` = nestedEnums[nextName.name] {
                assert(nestedMessages[nextName.name] == nil, "Encountered inconsistent state for type \(typeName).")
                return .enum(`enum`)
            }
        } else {
            if let message = nestedMessages[nextName.name] {
                assert(nestedEnums[nextName.name] == nil, "Encountered inconsistent state for type \(typeName).")
                return message.find(for: typeName, using: &nameIterator, depth: depth + 1)
            }
        }

        return nil
    }
}
