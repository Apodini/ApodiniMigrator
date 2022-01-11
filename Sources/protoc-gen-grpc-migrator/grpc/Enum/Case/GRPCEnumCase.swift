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

@dynamicMemberLookup
struct GRPCEnumCase {
    private let enumCase: SomeGRPCEnumCase

    init(_ enumCase: SomeGRPCEnumCase) {
        self.enumCase = enumCase
    }

    subscript<T>(dynamicMember member: KeyPath<SomeGRPCEnumCase, T>) -> T {
        enumCase[keyPath: member]
    }

    // TODO tryTyped?
}
