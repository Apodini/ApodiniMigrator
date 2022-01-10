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

enum ModelSearchResult {
    case `enum`(_ enum: GRPCEnum)
    case message(_ message: GRPCMessage)
}

protocol ModelContaining {
    var fullName: String { get }
    var namer: SwiftProtobufNamer { get }

    var nestedMessages: OrderedDictionary<String, GRPCMessage> { get set }
    var nestedEnums: OrderedDictionary<String, GRPCEnum> { get set }

    mutating func add(model: TypeInformation, using nameIterator: inout Array<TypeNameComponent>.Iterator, depth: Int)

    func find(for typeName: TypeName, using nameIterator: inout Array<TypeNameComponent>.Iterator, depth: Int) -> ModelSearchResult?
}

extension ModelContaining {
    var fullName: String {
        ""
    }
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

        if depth == model.typeName.nestedTypes.count { // depth isn't incremented and nestedTypes is 'fullName' -1
            assert(nextName.name == model.typeName.mangledName)

            // name must be free in both dictionaries
            precondition(nestedMessages[nextName.name] == nil, "Addition of model would result in a collision with a existent message")
            precondition(nestedEnums[nextName.name] == nil, "Addition of model would result in a collision with a existent enum")

            switch model.rootType {
            case .object:
                nestedMessages[nextName.name] = GRPCMessage(ApodiniGRPCMessage(of: model), namer: namer)
            case .enum:
                // TODO add nested enum
                fatalError("Nesting enums isn't supported yet!")
            default:
                fatalError("Encountered unexpected root type: \(model.rootType) of type \(model.typeName)")
            }
        } else {
            // map mutating requires exclusive access to `self`. Therefore we can't access
            // the values in the `default:` closure and must compute those beforehand
            let fullName = fullName
            let namer = namer

            nestedMessages[
                nextName.name,
                default: GRPCMessage(EmptyGRPCMessage(name: nextName.name, nestedIn: fullName, namer: namer), namer: namer)
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
            fatalError("Run out of iterable elements.")
        }

        if depth == typeName.nestedTypes.count { // depth isn't incremented and nestedTypes is 'fullName' -1
            assert(nextName.name == typeName.mangledName)

            if let message = nestedMessages[nextName.name] {
                assert(nestedEnums[nextName.name] == nil)
                return .message(message)
            } else if let `enum` = nestedEnums[nextName.name] {
                assert(nestedMessages[nextName.name] == nil)
                return .enum(`enum`)
            }
        } else {
            if let message = nestedMessages[nextName.name] {
                assert(nestedEnums[nextName.name] == nil)
                return message.find(for: typeName, using: &nameIterator, depth: depth + 1)
            }
        }

        return nil
    }
}
