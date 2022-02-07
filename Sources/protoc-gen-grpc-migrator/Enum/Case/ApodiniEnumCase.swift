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

    let name: String
    let relativeName: String
    let dottedRelativeName: String

    var number: Int

    init(_ enumCase: EnumCase) {
        self.enumCase = enumCase

        self.name = enumCase.name
        self.relativeName = enumCase.name // currently simplified! (e.g. backticks excaping is unhandled)
        self.dottedRelativeName = "." + relativeName

        let identifiers = enumCase.context.get(valueFor: TypeInformationIdentifierContextKey.self)
        self.number = Int(identifiers.identifier(for: GRPCNumber.self).number)
    }
}
