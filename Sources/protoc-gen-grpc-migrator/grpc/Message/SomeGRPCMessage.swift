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

protocol SomeGRPCMessage {
    var name: String { get }
    var relativeName: String { get }
    var fullName: String { get }
    var sourceCodeComments: String? { get }

    /// If true, this Message was removed in the latest version.
    var unavailable: Bool { get }

    var fields: [GRPCMessageField] { get }
    var sortedFields: [GRPCMessageField] { get }

    var nestedEnums: OrderedDictionary<String, GRPCEnum> { get } // TODO create abstraction!
    var nestedMessages: OrderedDictionary<String, GRPCMessage> { get }
}

extension SomeGRPCMessage {
    var sourceCodeComments: String? {
        nil
    }

    var unavailable: Bool {
        false
    }

    var sortedFields: [GRPCMessageField] {
        fields.sorted(by: \.number)
    }
}
