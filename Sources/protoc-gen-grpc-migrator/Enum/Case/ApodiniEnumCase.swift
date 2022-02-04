//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2022 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import Foundation
import ApodiniMigrator

struct ApodiniEnumCase: SomeGRPCEnumCase {
    private let enumCase: EnumCase

    var name: String {
        enumCase.name
    }

    // TODO check that naming is consistent with ApodiniGRPC
    var relativeName: String {
        enumCase.name
    }

    var dottedRelativeName: String {
        "." + enumCase.name
    }

    var number: Int

    init(_ enumCase: EnumCase) {
        self.enumCase = enumCase

        let identifiers = enumCase.context.get(valueFor: TypeInformationIdentifierContextKey.self)
        self.number = Int(identifiers.identifier(for: GRPCNumber.self).number)
    }
}
