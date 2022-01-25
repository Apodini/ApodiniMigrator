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

/// Describes an empty grpc message.
/// We use this type in cases, where a added `TypeInformation` is nested into a type
/// which we don't control.
struct EmptyGRPCMessage: SomeGRPCMessage {
    let context: ProtoFileContext

    var name: String
    var relativeName: String
    var fullName: String

    let fields: [GRPCMessageField] = []

    var nestedEnums: OrderedDictionary<String, GRPCEnum> = [:]
    var nestedMessages: OrderedDictionary<String, GRPCMessage> = [:]

    init(name: String, nestedIn baseName: String?, context: ProtoFileContext) {
        self.context = context

        self.name = name

        // TODO is this the same as in the `Namer`?
        self.relativeName = name
        if let baseName = baseName, !baseName.isEmpty {
            self.fullName = baseName + "." + name
        } else {
            self.fullName = name
        }
    }
}
