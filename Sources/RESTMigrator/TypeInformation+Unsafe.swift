//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2021 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import Foundation

extension TypeInformation {
    /// Retrieves the unsafe `mangledName` which is used by the ``RESTMigrator`` for file naming.
    /// This is considered unsafe as we cannot guarantee that we avoid name collisions (e.g. generics or nested types).
    /// Further, we normally cannot reconstruct the `TypeName` from `.reference` key.
    var unsafeFileNaming: String {
        switch self {
        case let .reference(key):
            return TypeName(rawValue: key.rawValue).mangledName
        default:
            return typeName.mangledName
        }
    }

    /// Retrieves the unsafe `typeString` which is used by the ``RESTMigrator` for type naming.
    /// This is considered unsafe as we cannot guarantee that we avoid name collisions (e.g. nested types).
    /// Further, we normally cannot reconstruct the `TypeName` from `.reference` key.
    var unsafeTypeString: String {
        switch self {
        case let .repeated(element):
            return "[\(element.unsafeTypeString)]"
        case let .dictionary(key, value):
            return "[\(key.description): \(value.unsafeTypeString)]"
        case let .optional(wrappedValue):
            return wrappedValue.unsafeTypeString + "?"
        case .enum, .object, .scalar:
            return typeString
        case let .reference(key):
             return TypeName(rawValue: key.rawValue).buildName()
        }
    }
}
