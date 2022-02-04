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

struct ApodiniGRPCEnum: SomeGRPCEnum {
    let context: ProtoFileContext

    var relativeName: String
    var fullName: String

    var enumCases: [GRPCEnumCase]

    var uniquelyNamedValues: [GRPCEnumCase] {
        enumCases
    }

    var defaultValue: GRPCEnumCase

    init(of type: TypeInformation, context: ProtoFileContext) {
        precondition(type.isEnum, "Cannot instantiate a GRPCEnum from a non enum: \(type.rootType) \(type.typeName)")
        precondition(!type.enumCases.isEmpty, "TypeInformation enum must at least contain one case!")

        // swiftlint:disable:next force_unwrapping
        let identifiers = type.context!.get(valueFor: TypeInformationIdentifierContextKey.self)
        // TODO grpcName not directly usabel, e.g. we must use the old packageName
        let grpcName = identifiers.identifier(for: GRPCName.self)
        // TODO use grpcName?

        self.context = context

        // TODO consider sanitizing, prefixing, sufixing the name etc (Generics Name to uniqueify)?

        self.fullName = type.typeName.buildName(
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

        self.enumCases = type.enumCases
            .map { .init(ApodiniEnumCase($0)) }

        // there is always at least one case!
        self.defaultValue = enumCases.first.unsafelyUnwrapped
    }
}
