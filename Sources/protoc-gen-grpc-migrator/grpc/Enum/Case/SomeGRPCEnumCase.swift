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

protocol SomeGRPCEnumCase {
    var name: String { get }
    var relativeName: String { get }
    var dottedRelativeName: String { get }

    var sourceCodeComments: String? { get }

    var unavailable: Bool { get }

    var number: Int { get }

    var aliasOf: GRPCEnumCase? { get }
    var aliases: [GRPCEnumCase] { get }
}

extension SomeGRPCEnumCase {
    var sourceCodeComments: String? {
        nil
    }

    var unavailable: Bool {
        false
    }

    var aliasOf: GRPCEnumCase? {
        nil
    }

    var aliases: [GRPCEnumCase] {
        []
    }
}
