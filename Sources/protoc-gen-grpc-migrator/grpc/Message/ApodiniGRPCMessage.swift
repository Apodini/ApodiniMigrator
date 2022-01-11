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

struct ApodiniGRPCMessage: SomeGRPCMessage {
    let context: ProtoFileContext

    let name: String
    let relativeName: String
    let fullName: String

    let fields: [GRPCMessageField] = []

    // those two fields may be populated in `GRPCMessage`
    var nestedEnums: OrderedCollections.OrderedDictionary<String, GRPCEnum> = [:]
    var nestedMessages: OrderedCollections.OrderedDictionary<String, GRPCMessage> = [:]

    init(of type: TypeInformation, context: ProtoFileContext) {
        precondition(type.isObject, "Cannot instantiate a GRPCMessage from a non object: \(type.rootType) \(type.typeName)")
        // TODO consider sanitizing, prefixing, sufixing the name etc (Generics Name to uniqueify)?

        self.context = context

        let typeName = type.typeName
        self.name = typeName.mangledName // TODO generics?

        self.fullName = typeName.buildName(
            printTargetName: false,
            componentSeparator: ".",
            genericsStart: "Of",
            genericsSeparator: "And",
            genericsDelimiter: ""
        )
        self.relativeName = fullName
            .components(separatedBy: ".")
            .last
            .unsafelyUnwrapped

        // TODO fields
    }
}
