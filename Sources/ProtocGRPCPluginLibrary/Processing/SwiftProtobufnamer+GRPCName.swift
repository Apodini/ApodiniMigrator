//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2022 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import Foundation
import SwiftProtobufPluginLibrary

extension SwiftProtobufNamer {
    func relativeName(message: ParsedGRPCName) -> String {
        if message.nestedTypes.isEmpty {
            let prefix = GRPCNamingUtils.typePrefix(protoPackage: message.packageName)
            return GRPCNamingUtils.sanitize(messageName: prefix + message.typeName, forbiddenTypeNames: [self.swiftProtobufModuleName])
        } else {
            return GRPCNamingUtils.sanitize(messageName: message.typeName, forbiddenTypeNames: [self.swiftProtobufModuleName])
        }
    }

    func fullName(message: ParsedGRPCName) -> String {
        let relativeName = self.relativeName(message: message)

        guard let containingType = message.containingType else {
            return relativeName
        }

        return fullName(message: containingType) + "." + relativeName
    }

    func relativeName(enum: ParsedGRPCName) -> String {
        if `enum`.nestedTypes.isEmpty {
            let prefix = GRPCNamingUtils.typePrefix(protoPackage: `enum`.packageName)
            return GRPCNamingUtils.sanitize(enumName: prefix + `enum`.typeName, forbiddenTypeNames: [self.swiftProtobufModuleName])
        } else {
            return GRPCNamingUtils.sanitize(enumName: `enum`.typeName, forbiddenTypeNames: [self.swiftProtobufModuleName])
        }
    }

    func fullName(enum: ParsedGRPCName) -> String {
        let relativeName = relativeName(enum: `enum`)

        guard let containingType = `enum`.containingType else {
            return relativeName
        }

        return fullName(enum: containingType) + "." + relativeName
    }
}
