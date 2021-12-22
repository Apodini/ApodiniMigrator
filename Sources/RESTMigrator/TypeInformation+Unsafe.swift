//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2021 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import Foundation

extension TypeInformation {
    /// TODO explain why this isn't ideal, but isn't any worse than existing stuff!
    var unsafeFileNaming: String {
        switch self {
        case let .reference(key):
            return TypeName(rawValue: key.rawValue).mangledName
        default:
            // TODO file name uniqueness
            return typeName.mangledName
        }
    }

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
